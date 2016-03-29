/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;

OscP5 oscP5;
boolean largemode = true;
int numboxes = 140;
int numlargeboxes = 140;
color[] colors = new color[numboxes];
PFont f;
boolean displayText = true;
boolean debugText = false;

int pid=0;
String name="";
String streamclass="";
int framenumber=1;

void setup() {
  size(430, 600);
  frameRate(60);
  f = loadFont("AmericanTypewriter-48.vlw");
  textFont(f, 24);
  /* start oscP5, listening for incoming messages at port 12000 */
  OscProperties myProperties = new OscProperties();
  myProperties.setDatagramSize(10000); 
  myProperties.setListeningPort(11661);
  oscP5 = new OscP5(this, myProperties);
  usage();
}

void usage() {
  println("lights_emulator: \n\t t - toggle text\n\t d - debug text\n\t l - large mode (6x8)");
}

void draw() {
  background(0);
  float bordertop = 25;
  int bwidth = 5;
  int bheight = 5;
  int length = 24;
  float fontsize = 24;
  if (largemode) {
    bwidth = 10;
    bheight = 15; 
    length = 140;
    fontsize = 16;
  }
  float boxwidth = width/bwidth; //hard coded!
  float boxheight = height/bheight;
  
  for (int i=0; i<length; i++) {
    int a = i;//actualorder[i];
    int column = i%bwidth;
    int row = i/bwidth;
    fill(colors[a]);
    rect(column*boxwidth, bordertop+row*boxheight, boxwidth, boxheight);
    if (displayText) {
      fill(255, 140);
      textFont(f, fontsize);
      textAlign(CENTER, CENTER);
      text(""+(i), column*boxwidth+boxwidth/2, bordertop+row*boxheight+boxheight/2);
    }
    if (debugText) {
      textFont(f, 20);
      textAlign(RIGHT, BOTTOM);
      text(""+(a), (column+1)*boxwidth-3, bordertop+(row+1)*boxheight-3);
    }
  }
  
  textFont(f,20);
  fill(255,255,255);
  textAlign(LEFT, TOP);
  text("Name: "+name+" pid: "+pid+" frame: "+framenumber, 3, 3);
}


void keyPressed() {
  if (key == 't') {
    displayText = !displayText;
  } 
  else if (key == 'd') {
    debugText = !debugText;
  }
  else if (key == 'l') {
    largemode = !largemode;
  }
}




/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  try {
    /* print the address pattern and the typetag of the received OscMessage */
    //print("### received an osc message.");
    //print(" addrpattern: "+theOscMessage.addrPattern());
    //println(" typetag: "+theOscMessage.typetag());
    //header stuff
    int headerlength = theOscMessage.get(0).intValue();
    pid = theOscMessage.get(1).intValue();
    name = theOscMessage.get(2).stringValue();
    streamclass = theOscMessage.get(3).stringValue();
    framenumber = theOscMessage.get(4).intValue();    
    
    int len = theOscMessage.arguments().length - headerlength;
    for (int i=0; i<min(len/3, numboxes); i++) {
      int r = int(theOscMessage.get(i*3+0+headerlength).floatValue() / 4);
      int g = int(theOscMessage.get(i*3+1+headerlength).floatValue() / 4);
      int b = int(theOscMessage.get(i*3+2+headerlength).floatValue() / 4);
      colors[i] = color(r, g, b);
      //println("Color: "+r+","+g+","+b+".");
    }
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}