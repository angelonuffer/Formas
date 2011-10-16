require "redis"
require "digest"

class Widget
  def initialize(ws, element, id)
    @ws = ws
    @element = element
    @id = id
    @element[:id] = @id
    @element.hidden = true
  end
  def to_s
    @element.to_s
  end
  def id
    @id
  end
  def element
    @element
  end
  def put
    @ws.send "document.body.innerHTML += '%s'" % @element.to_s
    @ws.send "$('#%s').fadeIn('slow')" % @id
  end
  def put_all widgets
    widgets.each{ |widget|
      @ws.send "document.body.innerHTML += '#{widget.to_s}'"
    }
    fade_in = String.new
    widgets.each{ |widget|
      fade_in += "$('##{widget.id}').fadeIn('slow', function() {"
    }
    fade_in += "})" * widgets.length
    @ws.send fade_in
  end
  def remove_all_widgets
    @ws.send "$('div').fadeOut('slow', function() { $('div').remove(); sock.send('#{@id}:end')})"
  end
end

class LoginForm < Widget
  def initialize(ws, widgets=Hash.new, redis=nil)
    @widgets = widgets
    @redis = redis
    @action = nil
    @username = String.new
    element = Element.new "div"
    title = Element.new "h2"
    title.append "Login"
    name = Field.new("name")
    password = Field.new("password", "password")
    signup = Element.new "button"
    signup[:onclick] = "sock.send(\\'login_form:signup\\')"
    signup.append "sign up"
    login = Element.new "button"
    login[:onclick] = "sock.send("
    login[:onclick] += "\\'login_form:login:\\' + "
    login[:onclick] += "$(\\'input[name=name]\\')[0].value + \\';\\' + "
    login[:onclick] += "$(\\'input[name=password]\\')[0].value)"
    login.append "log in"
    element.append title
    element.append name
    element.append password
    element.append signup
    element.append login
    super(ws, element, "login_form")
  end
  def widget_public_methods
    ["signup", "end", "login"]
  end
  def signup
    @ws.send "$('#%s').fadeOut('slow', function() { sock.send('login_form:end') })" % @id
    @action = :signup
  end
  def end
    @widgets.delete "login_form"
    @ws.send "$('#%s').remove()" % @id
    if @action == :signup
      signup_form = SignupForm.new(@ws, @widgets, @redis)
      @widgets["signup_form"] = signup_form
      signup_form.put
    end
    if @action == :login
      user_bar = UserBar.new @ws, @widgets, @redis, @username
      @widgets["user_bar"] = user_bar
      info_box = InfoBox.new @ws, @widgets, @redis, @username
      @widgets["info_box"] = info_box
      put_all [user_bar, info_box]
    end
  end
  def login username, password
    if not @redis.lrange("users", 0, -1).include? username
      error_box = ErrorBox.new @ws, "Wrong login or password", @widgets
      @widgets["error_box"] = error_box
      error_box.put
      return
    end
    if @redis.get("users:#{username}:password") != Digest::SHA2::hexdigest(password)
      error_box = ErrorBox.new @ws, "Wrong login or password", @widgets
      @widgets["error_box"] = error_box
      error_box.put
      return
    end
    @username = username
    @ws.send "$('#%s').fadeOut('slow', function() { sock.send('login_form:end') })" % @id
    @action = :login
  end
end

class SignupForm < Widget
  def initialize(ws, widgets=Hash.new, redis=nil)
    @widgets = widgets
    @redis = redis
    element = Element.new "div"
    title = Element.new "h2"
    title.append "Signup"
    username = Field.new("username")
    completename = Field.new("complete name")
    email = Field.new("email")
    password = Field.new("password", "password")
    confirmpassword = Field.new("confirm password", "password")
    back = Element.new "button"
    back[:onclick] = "sock.send(\\'signup_form:back\\')"
    back.append "back"
    signup = Element.new "button"
    signup[:onclick] = "sock.send("
    signup[:onclick] += "\\'signup_form:signup:\\' + "
    signup[:onclick] += "$(\\'input[name=username]\\')[0].value + \\';\\' + "
    signup[:onclick] += "$(\\'input[name=complete_name]\\')[0].value + \\';\\' + "
    signup[:onclick] += "$(\\'input[name=email]\\')[0].value + \\';\\' + "
    signup[:onclick] += "$(\\'input[name=password]\\')[0].value + \\';\\' + "
    signup[:onclick] += "$(\\'input[name=confirm_password]\\')[0].value)"
    signup.append "sign up"
    element.append title
    element.append username
    element.append completename
    element.append email
    element.append password
    element.append confirmpassword
    element.append back
    element.append signup
    super(ws, element, "signup_form")
  end
  def widget_public_methods
    ["back", "end", "signup"]
  end
  def back
    @ws.send "$('#%s').fadeOut('slow', function() { sock.send('signup_form:end') })" % @id
    @action = :back
  end
  def end
    @widgets.delete "signup_form"
    @ws.send "$('#%s').remove()" % @id
    if @action == :back
      login_form = LoginForm.new(@ws, @widgets, @redis)
      @widgets["login_form"] = login_form
      login_form.put
    end
  end
  def signup(username, completename, email, password, confirmpassword)
    if @redis.lrange("users", 0, -1).include? username
      @ws.send "$('div#signup_form input[name=username]').css('background-color', 'red')"
      error_box = ErrorBox.new @ws, "Username already exists", @widgets
      @widgets["error_box"] = error_box
      error_box.put
      return
    end
    if password != confirmpassword
      @ws.send "$('div#signup_form input[type=password]').css('background-color', 'red')"
      error_box = ErrorBox.new @ws, "The passwords are not identical", @widgets
      @widgets["error_box"] = error_box
      error_box.put
      return
    end
    @redis.set "users:#{username}:complete_name", completename
    @redis.set "users:#{username}:e-mail", email
    @redis.set "users:#{username}:password", Digest::SHA2.hexdigest(password)
    @redis.rpush "users", username
    back
  end
end

class ErrorBox < Widget
  def initialize ws, message, widgets=Hash.new
    @widgets = widgets
    element = Element.new "div"
    text = Element.new "p"
    text.append message
    close = Element.new "button"
    close[:onclick] = "sock.send(\\'error_box:close\\')"
    close.append "X"
    element.append text
    element.append close
    super ws, element, "error_box"
  end
  def widget_public_methods
    ["close", "end"]
  end
  def close
    @ws.send "$('#error_box').fadeOut('slow', function() { sock.send('error_box:end') })"
  end
  def end
    @widgets.delete "error_box"
    @ws.send "$('#%s').remove()" % @id
  end
end

class UserBar < Widget
  def initialize ws, widgets=Hash.new, redis=nil, username
    @widgets = widgets
    @redis = redis
    @username = username
    element = Element.new "div"
    username = Element.new "span"
    username.append @username
    logout = Element.new "button"
    logout[:onclick] = "sock.send(\\'user_bar:logout\\')"
    logout.append "log out"
    element.append logout
    element.append username
    super ws, element, "user_bar"
  end
  def widget_public_methods
    ["logout", "end"]
  end
  def logout
    remove_all_widgets
  end
  def end
    @widgets.keys.each{ |widget_id| @widgets.delete widget_id }
    login_form = LoginForm.new @ws, @widgets, @redis
    @widgets["login_form"] = login_form
    login_form.put
  end
end

class InfoBox < Widget
  def initialize ws, widgets=Hash.new, redis=nil, username
    @widgets = widgets
    @redis = redis
    @username = username
    email_text = redis.get "users:#{@username}:e-mail"
    email_hash = Digest::MD5.hexdigest email_text
    element = Element.new "div"
    image = Element.new "img"
    image[:src] = "http://www.gravatar.com/avatar/#{email_hash}"
    text_info = Element.new "div"
    name = Element.new "h1"
    name.append(redis.get "users:#{@username}:complete_name")
    email = Element.new "span"
    email.append email_text
    search = Element.new "input"
    search[:type] = "text"
    search[:onkeypress] = "if (event.which == 13) { sock.send(\\'info_box:set_user:\\' + this.value) }"
    text_info.append name
    text_info.append email
    element.append image
    element.append search
    element.append text_info
    super ws, element, "info_box"
  end
  def widget_public_methods
    ["set_user", "end"]
  end
  def set_user name
    @ws.send "$('#info_box').fadeOut('slow', function() { sock.send('info_box:end') })"
    @new_user_name = name
  end
  def end
    @widgets.delete "info_box"
    @ws.send "$('#info_box').remove()"
    info_box = InfoBox.new @ws, @widgets, @redis, @new_user_name
    @widgets["info_box"] = info_box
    info_box.put
  end
end
