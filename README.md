# chroma
chroma rework in processing.

Adapted from [this](http://macetech.com/blog/node/111) earlier project. All credit for the inital code and animations goes to the original authors.

## Installation
Put the following libraries in your `sketchbook/libraries` folder:
- [minim](code.compartmental.net/tools/minim/)
- [oscp5](www.sojamo.de/libraries/oscP5/)
- [SimpleHTTPServer](http://transfluxus.github.io/SimpleHTTPServer/)

## Usage
For local testing, the kernel module `snd_aloop` has to be enabled for music integration to work.

To start the server:

```
./chroma
```

Navigate to `/list` on port 8000 to retrieve a JSON array of the available animations.

You can send these OSC commands on port 11662 to control the server remotely:

- `/switch`: Takes an integer argument. Switches to the animation with the given id.
- `/enable`: Takes an integer argument. On 0, disable displaying animations, to prolong the lifespan of the LEDs. Otherwise, enable animations.

## Contributing
Animations go in `effects.pde`. For information on how to write animations, read [this](../master/doc/Creating_Effects.md).
