import netP5.*;
import oscP5.*;

PImage effectImage;
PImage sourcePattern;
import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.image.BufferedImage;
import java.awt.*;
import org.imgscalr.*;
import processing.serial.*;
import javax.sound.sampled.*;

// create global objects and variables
Minim minim;
AudioInput in;
//AudioPlayer in;
BeatDetect beat;
FFT fft;
int[] fftHold = new int[32];
float[] fftSmooth = new float[32];
boolean useEmulator = true;

final int LIGHTS_WIDTH = 14;
final int LIGHTS_HEIGHT = 10;
final int MAGNITUDE = 20;
final int MAX_LIGHTS = LIGHTS_WIDTH * LIGHTS_HEIGHT;

final int PIXEL_WIDTH = LIGHTS_WIDTH * MAGNITUDE;
final int PIXEL_HEIGHT = LIGHTS_HEIGHT * MAGNITUDE;

Serial myPort;

BufferedImage resizebuffer;

OscP5 control;
NetAddress myRemoteLocation;

Effect e = new RotoZoomEffect();

void setup() {
  if (useEmulator) {
    myRemoteLocation = new NetAddress("127.0.0.1", 11661);
  } else {
    myPort = new Serial(this, "/dev/ttyACM0", 230400);
  }

  OscProperties myProperties = new OscProperties();
  myProperties.setDatagramSize(10000); 
  myProperties.setListeningPort(11662);
  control = new OscP5(this, myProperties);

  // initialize Minim object
  minim = new Minim(this);

  Mixer.Info[] mixerInfos = AudioSystem.getMixerInfo();
  for (Mixer.Info info : mixerInfos) {
    System.out.println(info);
    if (info.getName().substring(0, 8).equals("Loopback")) {
      minim.setInputMixer(AudioSystem.getMixer(info));
    }
  }

  // select audio source, comment for sample song or recording source
  in = minim.getLineIn(Minim.STEREO, 512);
  //in = minim.loadFile("Gosprom_-_12_-_San_Francisco.mp3",512); // Creative Commons
  //in.play();

  //beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());  
  beat.setSensitivity(300);
  beat.detectMode(BeatDetect.FREQ_ENERGY);

  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(120, 4); // 32 bands

  size(280, 400);  
  frameRate(20);
  smooth(0);

  resizebuffer = new BufferedImage(PIXEL_WIDTH, PIXEL_HEIGHT, BufferedImage.TYPE_INT_RGB);

  sourcePattern = loadImage("acm.png");

  selectEffect();
}

boolean hueCycleable = false;
float cycleHue = 0;

boolean imgSelected = false;
boolean directWrite = false;

int selectedEffect = 0;
int maxEffects = 24;
void draw () {

  if (hueCycleable) {

    cycleHue += 0.2;
    if (cycleHue > 100) cycleHue -= 100;
  }

  // sample effects are drawn in upper PIXEL_WIDTHxPIXEL_HEIGHT half of screen
  colorMode(RGB, 255);
  noTint();

  e.update();

  if (!directWrite) {
    // capture upper half of screen
    effectImage = get(0, 0, PIXEL_WIDTH - 1, PIXEL_HEIGHT - 1);

    // use Scalr resizer which requires BufferedImage
    resizebuffer = (BufferedImage)effectImage.getImage();
    effectImage = new PImage(Scalr.resize(resizebuffer, Scalr.Mode.FIT_EXACT, LIGHTS_WIDTH, LIGHTS_HEIGHT, null));
  } else {
    effectImage = get(0, 0, LIGHTS_WIDTH, LIGHTS_HEIGHT);
  }

  effectImage.loadPixels();

  // output pixelized image to LED array
  sendColors();

  // Put pixelized image in lower half of window
  image(effectImage, 0, height/2, width, height/2);
  if(directWrite) {
    image(effectImage, 0, 0, width, height/2);
  }

  // Draw grid over pixels on bottom half
  drawGrid();
}

// draw grid in lower half
void drawGrid() {
  stroke(139);
  strokeWeight(1);
  for (int i = 1; i < LIGHTS_WIDTH; i++) {
    line(i*MAGNITUDE, PIXEL_HEIGHT, i*MAGNITUDE, PIXEL_HEIGHT*2 - 1);
  }
  for (int i = 0; i < LIGHTS_HEIGHT; i++) {
    line(0, i*MAGNITUDE+PIXEL_HEIGHT, PIXEL_HEIGHT*2 - 1, i*MAGNITUDE+PIXEL_HEIGHT);
  }
}

void selectEffect() {
  switch(selectedEffect) { 

    // macetech effects
  case 0:
    e = new SpinImageEffect();
    break;
  case 1:
    e = new DropsEffect();
    break;
  case 2:
    e = new SpectrumEffect();
    break;
  case 3:
    e = new SparksEffect();
    break;
  case 4:
    e = new WaveformEffect();
    break;
  case 5:
    e = new StarsEffect();
    break;

    // contributed effects
  case 6:
    e = new RotoZoomEffect();
    break;
  case 7:
    e = new DownTheHallEffect();
    break;
  case 8:
    e = new BouncersEffect();
    break;
  case 9:
    e = new FireEffect();
    break;
  case 10:
    e = new SunsEffect();
    break;
  case 11:
    e = new BubblesEffect();
    break;
  case 12:
    e = new PlaidEffect();
    break;
  case 13:
    e = new SpectrogramEffect();
    break;
  case 14:
    e = new PerlinEffect();
    break;
  case 15:
    e = new QuinnEffect();
    break;
  case 16:
    e = new SpectrogramMaxEffect();
    break;
  case 17:
    e = new PlasmaEffect();
    break;
  case 18:
    e = new MappedTunnelEffect();
    break;
  case 19:
    e = new ShiftingMosaicEffect();
    break;
  case 20:
    e = new TextEffect();
    break;
  case 21:
    e = new ColoredGridEffect();
    break;
  case 22:
    e = new GradientEffect();
    break;
  case 23:
    e = new ShimmerEffect();
    break;
  case 24:
    e = new LifeEffect();
    break;
  }
}

// up and down arrow keys to select visual effect
void keyPressed() {
  imgSelected = false;
  hueCycleable = false;
  directWrite = false;

  if (keyCode == UP) {
    if (++selectedEffect > maxEffects) selectedEffect = 0;
    selectEffect();
  } else if (keyCode == DOWN) {
    if (--selectedEffect < 0) selectedEffect = maxEffects;
    selectEffect();
  }

  e.init();
}

// lookup table to map LED locations to chain position
// static procToShift lookup (0-based)
int[] procToShiftLkupStatic = new int[] {
  127, 123, 111, 107, 95, 91, 79, 75, 63, 59, 47, 43, 31, 27, 15, 11, 
  126, 122, 110, 106, 94, 90, 78, 74, 62, 58, 46, 42, 30, 26, 14, 10, 
  125, 121, 109, 105, 93, 89, 77, 73, 61, 57, 45, 41, 29, 25, 13, 9, 
  124, 120, 108, 104, 92, 88, 76, 72, 60, 56, 44, 40, 28, 24, 12, 8, 
  119, 115, 103, 99, 87, 83, 71, 67, 55, 51, 39, 35, 23, 19, 7, 3, 
  118, 114, 102, 98, 86, 82, 70, 66, 54, 50, 38, 34, 22, 18, 6, 2, 
  117, 113, 101, 97, 85, 81, 69, 65, 53, 49, 37, 33, 21, 17, 5, 1, 
  116, 112, 100, 96, 84, 80, 68, 64, 52, 48, 36, 32, 20, 16, 4, 0
};

// create serialized byte array and send to serial port
byte[] imgBytes = new byte[MAX_LIGHTS*3+4];
color ledColor;

void sendColors() {

  int sendIndex = 0;
  colorMode(RGB, 254);

  if (useEmulator) {
    OscMessage myMessage = new OscMessage("/setcolors");

    myMessage.add(8);
    myMessage.add(0);
    myMessage.add("Chroma");
    myMessage.add("something");
    myMessage.add(frameCount);
    myMessage.add(0);
    myMessage.add("Ian Pickering");
    myMessage.add("Chroma for ACM @ UIUC");
    for (int j = LIGHTS_WIDTH - 1; j >= 0; j--) {
      for (int i = 0; i < LIGHTS_HEIGHT; i++) {
        ledColor = effectImage.pixels[j+(i*LIGHTS_WIDTH)];
        myMessage.add(4*red(ledColor));
        myMessage.add(4*green(ledColor));
        myMessage.add(4*blue(ledColor));
      }
    }

    /* send the message */
    control.send(myMessage, myRemoteLocation);
  } else {
    for (int j = 0; j < LIGHTS_WIDTH; j++) {
      for (int i = 0; i < LIGHTS_HEIGHT; i++) {
        sendIndex = procToShiftLkupStatic[i]*3+2;
        ledColor = effectImage.pixels[i];
        imgBytes[sendIndex]=((byte)red(ledColor));
        imgBytes[sendIndex+1]=((byte)green(ledColor));
        imgBytes[sendIndex+2]=((byte)blue(ledColor));
      }
    }
    myPort.write(imgBytes);
  }
  colorMode(RGB, 255);
}

void oscEvent(OscMessage message) {
  try {
    int id = message.get(0).intValue();

    selectedEffect = id;
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

// shutdown
void stop()
{
  // always close Minim audio classes when you are finished with them
  in.close();
  //song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
