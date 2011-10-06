require 'em-websocket'
require './lib/element.rb'
require './lib/widget.rb'

EventMachine.run {

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen {
            div = Element.new "div"
            div.append "Formas"
            widget = Widget.new(ws, div, "formas")
        }
    end
}
