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
  def initialize(ws)
    element = Element.new "div"
    title = Element.new "h2"
    title.append "Login"
    name = Field.new("name")
    password = Field.new("password", "password")
    signup = Element.new "button"
    signup[:onclick] = "sock.send(\\'login_form signup\\')"
    signup.append "sign up"
    login = Element.new "button"
    login[:onclick] = "sock.send(\\'login_form login\\')"
    login.append "log in"
    element.append title
    element.append name
    element.append password
    element.append login
    element.append signup
    super(ws, element, "login_form")
  end
end
