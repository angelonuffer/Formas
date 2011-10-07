class Widget
  def initialize(ws, element, id)
    @ws = ws
    @element = element
    @id = id
    @element[:id] = @id
  end
  def to_s
    @element.to_s
  end
  def element
    @element
  end
  def put
    @ws.send "document.body.innerHTML += '%s'" % @element.to_s
  end
end

class LoginForm < Widget
  def initialize(ws)
    element = Element.new "div"
    title = Element.new "h2"
    title.append "Login"
    name = Field.new(ws, "name")
    password = Field.new(ws, "password", "password")
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

class Field < Widget
  def initialize(ws, name, type="text")
    element = Element.new "div"
    label = Element.new "p"
    label.append "%s:" % name
    input = Element.new "input"
    input[:type] = type
    input[:name] = name.gsub(" ", "_")
    element.append label
    element.append input
    super(ws, element, name)
  end
end
