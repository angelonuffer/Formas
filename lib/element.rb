class Element
  def initialize(name)
    @name = name
    @parameters = Hash.new
    @children = Array.new
    @hidden = false
  end
  def to_s
    element_s = "<%s" % @name
    @parameters.each { |key, value| element_s += ' %s="%s"' % [key, value] }
    if @hidden
      element_s += " hidden"
    end
    if @children == []
      element_s += " />"
    else
      element_s += ">"
      @children.each { |element|
        element_s += element.to_s
      }
      element_s += "</%s>" % @name
    end
    element_s
  end
  def []=(key, value)
    @parameters[key] = value
  end
  def [](key)
    @parameters[key]
  end
  def name
    @name
  end
  def parameters
    @parameters
  end
  def children
    @children
  end
  def hidden
    @hidden
  end
  def hidden=(value)
    @hidden = value
  end
  def append(element)
    @children << element
  end
end

class Field < Element
  def initialize(name, type="text")
    super("div")
    label = Element.new "p"
    label.append "%s:" % name
    input = Element.new "input"
    input[:type] = type
    input[:name] = name.gsub(" ", "_")
    append label
    append input
  end
end
