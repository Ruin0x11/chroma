# chroma
chroma rework in processing.

Adapted from [this](http://macetech.com/blog/node/111) earlier project. All credit for the inital code and animations goes to the original authors.

## Usage
The kernel module `snd_aloop` has to be enabled for music integration to work.

To start the server:

```
./chroma server
```

While the server is running, the current displayed animation can be controlled through OSC. Send a message to the `/switch` address on port 11662 indicating the id of the animation to switch to.

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

## Contributing
Animations go in `effects.pde`. For information on how to write animations, read [this](../master/doc/Creating_Effects.md).
