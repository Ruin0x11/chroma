# chroma
chroma rework in pure processing.

Adapted from [this](http://macetech.com/blog/node/111) earlier project. All credit for the inital code and animations goes to the original authors.

# Usage
Animations go in `effects.pde`. Music frequencies from line-in, beat detection data and a canvas region are available for use.

While the server is running, the current displayed animation can be controlled through OSC. Send a message to the `/switch` address on port 11662 indicating the id of the animation to swtich to.

`osc.js` example:

```javascript
var oscPort = new osc.WebSocketPort({
    url: "ws://localhost:11662" // URL to your Web Socket server.
});

oscPort.send({
    address: "/switch",
    args: 1
    });
```
