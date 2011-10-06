require './lib/widget.rb'

describe Widget do
  it "has an element" do
    ws = mock()
    ws.stub!(:send).with("document.write('<div id=\"widget_id\" />')")
    div = Element.new "div"
    widget = Widget.new(ws, div, "widget_id")
    widget.element.should == div
    div[:id].should == "widget_id"
  end
end
