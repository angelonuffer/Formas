var sock = new WebSocket("ws://localhost:8080")
sock.onmessage = function(evt) {
    eval(evt.data)
}
