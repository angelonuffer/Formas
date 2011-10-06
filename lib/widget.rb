class Widget
  def initialize(ws, element, id)
    @ws = ws
    @element = element
    @id = id
    @element[:id] = @id
    ws.send "document.write('%s')" % @element.to_s
  end
  def element
    @element
  end
end
