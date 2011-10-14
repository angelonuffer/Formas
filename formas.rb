require 'em-websocket'
require './lib/element.rb'
require './lib/widget.rb'

EventMachine.run {

    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        widgets = Hash.new
        redis = Redis.new
        ws.onopen {
            login_form = LoginForm.new(ws, widgets, redis)
            widgets["login_form"] = login_form
            login_form.put
        }
        ws.onmessage { |message|
            command = message.split ":"
            widget_id = command[0]
            if widgets.keys.include? widget_id
                widget = widgets[widget_id]
                method_name = command[1]
                if widget.widget_public_methods.include? method_name
                    parameters = command[2]
                    if parameters == nil
                        parameters = Array.new
                    else
                        parameters = parameters.split(";")
                    end
                    widget.send(method_name, *parameters)
                end
            end
        }
    end

}
