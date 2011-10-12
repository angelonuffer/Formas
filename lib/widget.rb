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
  def element
    @element
  end
  def put
    @ws.send "document.body.innerHTML += '%s'" % @element.to_s
    @ws.send "$('#%s').fadeIn('slow')" % @id
  end
end

class LoginForm < Widget
  def initialize(ws, widgets=Array.new)
    @widgets = widgets
    @action = nil
    element = Element.new "div"
    title = Element.new "h2"
    title.append "Login"
    name = Field.new("name")
    password = Field.new("password", "password")
    signup = Element.new "button"
    signup[:onclick] = "sock.send(\\'login_form:signup\\')"
    signup.append "sign up"
    login = Element.new "button"
    login[:onclick] = "sock.send(\\'login_form:login\\')"
    login.append "log in"
    element.append title
    element.append name
    element.append password
    element.append login
    element.append signup
    super(ws, element, "login_form")
  end
  def widget_public_methods
    ["signup", "end"]
  end
  def signup
    @ws.send "$('#%s').fadeOut('slow', function() { sock.send('login_form:end') })" % @id
    @action = :signup
  end
  def end
    @widgets.delete "login_form"
    @ws.send "$('#%s').remove()" % @id
    if @action == :signup
      signup_form = SignupForm.new(@ws, @widgets)
      @widgets["signup_form"] = signup_form
      signup_form.put
    end
  end
end

class SignupForm < Widget
  def initialize(ws, widgets=Array.new)
    @widgets = widgets
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
    element.append signup
    element.append back
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
      login_form = LoginForm.new(@ws, @widgets)
      @widgets["login_form"] = login_form
      login_form.put
    end
  end
  def signup(username, completename, email, password, confirmpassword)
    redis = Redis.new
    if password == confirmpassword and not redis.lrange("users", 0, -1).include? username
      redis.set "users:#{username}:complete_name", completename
      redis.set "users:#{username}:e-mail", email
      redis.set "users:#{username}:password", Digest::SHA2.hexdigest(password)
      redis.rpush "users", username
      back
    end
  end
end
