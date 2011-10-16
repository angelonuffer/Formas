var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket
var sock = new Socket("ws://localhost:8080")
sock.onmessage = function(evt) {
    eval(evt.data)
}
