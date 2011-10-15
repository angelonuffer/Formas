require './lib/widget.rb'

describe Widget do
  it "has an element" do
    ws = mock()
    ws.stub!(:send).with("document.body.innerHTML += '<div id=\"widget_id\" hidden />'")
    ws.stub!(:send).with("$('#widget_id').fadeIn('slow')")
    div = Element.new "div"
    widget = Widget.new(ws, div, "widget_id")
    widget.element.should == div
    div[:id].should == "widget_id"
    widget.put
  end
end

describe LoginForm do
  it "has name and password fields" do
    ws = mock()
    ws.stub!(:send)
    login_form = LoginForm.new ws
    login_form.element.to_s.should include '<input type="text" name="name" />'
    login_form.element.to_s.should include '<input type="password" name="password" />'
  end
  it "has a button to log in" do
    ws = mock()
    ws.stub!(:send)
    login_form = LoginForm.new ws
    login_form.element.to_s.should include '<button onclick="sock.send(\\\'login_form:login:\\\''
    login_form.element.to_s.should include ')">log in</button>'
  end
  it "has a button to sign up" do
    ws = mock()
    ws.stub!(:send)
    login_form = LoginForm.new ws
    login_form.element.to_s.should include '<button onclick="sock.send(\\\'login_form:signup\\\')">sign up</button>'
  end
end

describe SignupForm do
  it "has username, complete name, e-mail and password fields" do
    ws = mock()
    ws.stub!(:send)
    signup_form = SignupForm.new ws
    signup_form.element.to_s.should include '<input type="text" name="username" />'
    signup_form.element.to_s.should include '<input type="text" name="complete_name" />'
    signup_form.element.to_s.should include '<input type="text" name="email" />'
    signup_form.element.to_s.should include '<input type="password" name="password" />'
    signup_form.element.to_s.should include '<input type="password" name="confirm_password" />'
  end
end

describe ErrorBox do
  it "has a message" do
    ws = mock()
    error_box = ErrorBox.new ws, "error message"
    error_box.to_s.should include '<p>error message</p>'
  end
end

describe UserBar do
  it "has a logout button" do
    ws = mock()
    ws.stub!(:send)
    user_bar = UserBar.new ws, "username"
    user_bar.to_s.should include '<button onclick="sock.send(\\\'user_bar:logout\\\')">log out</button>'
  end
end
