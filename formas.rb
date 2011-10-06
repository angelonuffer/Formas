require 'em-websocket'
require './lib/element.rb'
require './lib/widget.rb'

EventMachine.run {

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen {
            login_form = LoginForm.new ws
            login_form.put
        }
    end

}
