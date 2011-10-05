class Element
  def initialize(name)
    @name = name
    @parameters = Hash.new
    @children = Array.new
  end
  def to_s
    element_s = "<%s" % @name
    @parameters.each { |key, value| element_s += ' %s="%s"' % [key, value] }
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
  def name
    @name
  end
  def parameters
    @parameters
  end
  def children
    @children
  end
  def append(element)
    @children << element
  end
end
