require './lib/widget.rb'

describe Widget do
  it "has an element" do
    ws = mock()
    ws.stub!(:send).with("document.write('<div id=\"widget_id\" />')")
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
    login_form.element.to_s.should include '<input type="text" name="password" />'
  end
end

describe Field do
  it "has a label and a input" do
    ws = mock()
    ws.stub!(:send)
    field = Field.new(ws, "field name")
    field.element.to_s.should include '<p>field name:</p>'
    field.element.to_s.should include '<input type="text" name="field_name" />'
  end
end
