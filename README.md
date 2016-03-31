# chroma
chroma rework in processing.

Adapted from [this](http://macetech.com/blog/node/111) earlier project. All credit for the inital code and animations goes to the original authors.

## Usage
For local testing, the kernel module `snd_aloop` has to be enabled for music integration to work.

To start the server:

```
./chroma server
```

Navigate to `/list` on port 8000 to retrieve a JSON array of the available animations.

You can send these OSC commands on port 11662 to control the server remotely:

- `/switch`: Takes an integer argument. Switches to the animation with the given id.
- `/enable`: Toggles whether or not to display animations, to prolong the lifespan of the LEDs.

## Contributing
Animations go in `effects.pde`. For information on how to write animations, read [this](../master/doc/Creating_Effects.md).
