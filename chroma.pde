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
int frame = 0;
boolean useEmulator = true;

int LIGHTS_WIDTH = 14;
int LIGHTS_HEIGHT = 10;
int MAGNITUDE = 20;

int PIXEL_WIDTH = LIGHTS_WIDTH * MAGNITUDE;
int PIXEL_HEIGHT = LIGHTS_HEIGHT * MAGNITUDE;

Serial myPort;

BufferedImage resizebuffer;

OscP5 control, emulator;
NetAddress myRemoteLocation;

ArrayList Squares, Bouncers, WSquares;

void setup() {
  if (useEmulator) {
    emulator = new OscP5(this, 11661);
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

  Drops = new ArrayList();
  Squares = new ArrayList();  
  Bouncers = new ArrayList();
  WSquares = new ArrayList();

  resizebuffer = new BufferedImage(PIXEL_WIDTH, PIXEL_HEIGHT, BufferedImage.TYPE_INT_RGB);

  sourcePattern = loadImage("acm.png");

  init_rotozoom();
  init_sparks();
  init_stars();
  init_text();
}

boolean hueCycleable = false;
float cycleHue = 0;

boolean imgSelected = false;

boolean directWrite = false;

int selectedEffect = 0;
int maxEffects = 23;
void draw () {

  if (hueCycleable) {

    cycleHue += 0.2;
    if (cycleHue > 100) cycleHue -= 100;
  }

  // sample effects are drawn in upper PIXEL_WIDTHxPIXEL_HEIGHT half of screen
  colorMode(RGB, 255);
  noTint();

  switch(selectedEffect) { 

    // macetech effects
  case 0:
    select_randomCenteredImg();
    effect_spinImage();
    break;
  case 1:
    effect_drops();
    break;
  case 2:
    effect_spectrum();
    break;
  case 3:
    effect_sparks();
    break;
  case 4:
    effect_waveform();
    break;
  case 5:
    effect_stars();
    break;

    // contributed effects
  case 6:
    select_randomTileableImg();
    effect_RotoZoom();
    break;
  case 7:
    effect_square();
    break;
  case 8:
    effect_bouncers();
    break;
  case 9:
    effect_fire();
    break;
  case 10:
    effect_suns();
    break;
  case 11:
    effect_bubbles_cmooney();
    break;
  case 12:
    effect_plaid();
    break;
  case 13:
    effect_spectrogram();
    break;
  case 14:
    effect_perlin(0.1, 0.4, 0.3, 0.4);
    break;
  case 15:
    effect_quinn();
    break;
  case 16:
    effect_spectrogram_max();
    break;
  case 17:
    effect_Plasma();
    break;
  case 18:
    select_randomTileableImg();
    effect_Mapped_Tunnel();
    break;
  case 19:
    effect_shiftingMosaic();
    break;
  case 20:
    effect_text();
    break;
  case 21:
    effect_mandelbrot();
    break;
  case 22:
    effect_gradient();
    break;
  case 23:
    effect_shimmer();
    break;
  }

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

// up and down arrow keys to select visual effect
void keyPressed() {

  if (keyCode == UP) {
    if (++selectedEffect > maxEffects) selectedEffect = 0;
  } else if (keyCode == DOWN) {
    if (--selectedEffect < 0) selectedEffect = maxEffects;
  }

  imgSelected = false;
  hueCycleable = false;
  directWrite = false;
  rotozoom_init_done = 0;
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
byte[] imgBytes = new byte[140*3+4];

void sendColors() {

  int sendIndex = 0;
  colorMode(RGB, 254);

  if (useEmulator) {

    OscMessage myMessage = new OscMessage("/setcolors");

    myMessage.add(8);
    myMessage.add(123);
    myMessage.add("asd");
    myMessage.add("dsf");
    myMessage.add(frame++);
    myMessage.add(123);
    myMessage.add("dood");
    myMessage.add("zxc");
    for (int j = 13; j >= 0; j--) {
      for (int i = 0; i < 10; i++) {
        ledColor = effectImage.pixels[j+(i*14)];
        myMessage.add(4*red(ledColor));
        myMessage.add(4*green(ledColor));
        myMessage.add(4*blue(ledColor));
      }
    }

    /* send the message */
    emulator.send(myMessage, myRemoteLocation);
  } else {
    for (int j = 0; j < 14; j++) {
      for (int i = 0; i < 10; i++) {
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