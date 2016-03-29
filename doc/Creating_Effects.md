# Creating Effects
Currently, there are a variety of options that can be used to create effects. The color of each individual light can be changed directly (like the old version) or an image can be downscaled onto the light array. You can use any Processing or library function to create the image. Objects for detecting qualities of the music input can also be used.

## 1. Add an effect.
In `effects.pde`, create a new subtype of the `Effect` class:

```java
class MyEffect extends Effect {
  // optional
  public void init() {
  
  }
  
  public void update() {

  }
}
```

## 2. Code the effect.
`init()` is called once when switching to the effect. Use it to initialize any needed variables.

`update()` steps through a frame of the animation. Use drawing functions to draw in the region between 0 and `PIXEL_WIDTH` and 0 and `PIXEL_HEIGHT` (280 x 200) in this function. The resulting frame will be downscaled to a 10 x 14 image, and that image will be sent as the LED array.

You can use helper classes to encapsulate the behavior of specific parts of the animation. There are many examples in `effects.pde`.

List of global variables:

- `in`: Audio data of the current sample from line-in. Use `in.mix.level()` to get the volume level of the current audio mix of the left and right channels. `in.left` and `in.right` can also be used wherever `in.mix` is used to get the data for the left or right channel alone.
- `fft`: Fast Fourier Transform object. This is used to split up the audio buffer into a number of average frequencies at different frequency ranges. This way, you can check the intensity of a certain range of audio, like bass or treble, and update the animation accordingly. Use `fft.forward(in.mix)` to perform a forward FFT on the current audio mix. Afterwards, use `fft.avgSize()` to get the number of averages and `fft.getAvg(i)` to get the `i`th average. More information [here](http://code.compartmental.net/minim/javadoc/ddf/minim/analysis/FourierTransform.html).
- `beat`: Beat detection object. Each frame, first call `beat.detect(in.mix)`, then call `beat.isKick()`, `beat.isSnare()` or `beat.isHat()` to check if the current audio sample matches a predefined frequency range for typical bass kicks, snares or hi-hats. Use `beat.isOnset(i)` to check if a beat was detected in the `i`th frequency band or `isRange(lo, hi, threshold)` to check if a beat was detected between two frequency bands. More information [here](http://code.compartmental.net/minim/javadoc/ddf/minim/analysis/BeatDetect.html).
- `hueCycleable` and `cycleHue`: When `hueCyclable` is true, you can use the value of `cycleHue` to tint images when the color mode is `HSB`. Set within the image selection functions (see below); used for denoting which images should be tinted.
- `directWrite`: Boolean variable. When true, use the upper-left `LIGHTS_WIDTH` x `LIGHTS_HEIGHT` (14 x 10) region as the pattern to send to the LEDs instead of scaling the 280 x 200 region. Set it to true in `init()` when you want to directly set the values of the lights, or when aliasing causes the light array to look inaccurate. However, when aliasing isn't noticable, simply drawing squares `MAGNITUDE` (20) pixels in length across the 280 x 200 image region is fine.

### 2a. Images.
You can also add tiling or centered images to be used in animations. In the `init()` function, call either `select_randomTileableImg()` or `select_randomCenteredImg()`, then use the image that's loaded into `sourceImage`. If you want to add an image, put its filename into the appropriate places in `initializers.pde`.

## 3. Update the listing.
(To be redone.)

In `chroma.pde`, increment `maxEffects` by 1 and add a listing for your effect in `switchEffect()`:

```java
int maxEffects = 25;

/* ... */

void selectEffect() {
  switch(selectedEffect) { 

  /* ... */
  
  case 25:
    e = new MyEffect();
    break;
  }
  
  e.init();
}
```
