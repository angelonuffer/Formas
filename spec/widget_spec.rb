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
    login_form.element.to_s.should include '<button onclick="sock.send(\\\'login_form login\\\')">log in</button>'
  end
  it "has a button to sign up" do
    ws = mock()
    ws.stub!(:send)
    login_form = LoginForm.new ws
    login_form.element.to_s.should include '<button onclick="sock.send(\\\'login_form signup\\\')">sign up</button>'
  end
end
