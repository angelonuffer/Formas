require 'em-websocket'

EventMachine.run {

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen {
            ws.send "document.write('Formas')"
        }
    end
}
