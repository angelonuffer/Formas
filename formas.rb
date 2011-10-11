require 'em-websocket'
require './lib/element.rb'
require './lib/widget.rb'

EventMachine.run {

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        widgets = Hash.new
        ws.onopen {
            login_form = LoginForm.new(ws, widgets)
            widgets["login_form"] = login_form
            login_form.put
        }
        ws.onmessage { |message|
            widget_id = message.split[0]
            if widgets.keys.include? widget_id
                widget = widgets[widget_id]
                method_name = message.split[1]
                if widget.widget_public_methods.include? method_name
                    widget.send method_name
                end
            end
        }
    end

}
