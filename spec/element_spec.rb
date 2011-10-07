require './lib/element.rb'

describe Element do
  it "has a name" do
    element = Element.new "a"
    element.name.should == "a"
  end
  it "has a string representation" do
    element = Element.new "a"
    element.to_s.should == "<a />"
    element[:href] = "/"
    element.to_s.should == '<a href="/" />'
    element.append "home page"
    element.to_s.should == '<a href="/">home page</a>'
    div = Element.new "div"
    div.append element
    div.to_s.should == '<div><a href="/">home page</a></div>'
  end
  it "has parameters" do
    element = Element.new "a"
    element[:href] = "/"
    element.parameters.should == {:href => "/"}
  end
  it "has childrens" do
    div = Element.new "div"
    a = Element.new "a"
    div.append a
    div.children.should == [a]
  end
end

describe Field do
  it "has a label and a input" do
    field = Field.new("field name")
    field.to_s.should include '<p>field name:</p>'
    field.to_s.should include '<input type="text" name="field_name" />'
  end
end
