// --- EFFECT ---
// RotoZoom
// Rotates an image and zoom in and out
// |        Rodolphe Pineau    RTI-Zone        |
// |         http://www.rti-zone.org/          |
// |   Robotics / Unix / Mac OS X / Astronomy  |

float rotAlpha = 0;
float rot_alpha = 0;
float rotZoom = 80;
float rot_zoom = 0;
float img_zoom = 0;
float yy;
float xx;
PImage rotozoom;
int rotozoom_init_done=0;
int nb_tiles = 4;
float alpha_incr = 2;
float zoom_incr = 1.5;
float zoom_toggle = 1.0;

void effect_RotoZoom() {
  
  if(rotozoom_init_done == 0) {
    println("init rotozoom");
    init_rotozoom();
    rotozoom_init_done = 1;
  }
  
  alpha_incr = in.mix.level()*30;
  zoom_incr = in.mix.level()*2;
  
  rotAlpha += alpha_incr;
  if (rotAlpha > 360) {
    rotAlpha -= 360;
  }
  
  if ( rotZoom < 70 || rotZoom>173)
    zoom_toggle = -zoom_toggle;

  rotZoom += zoom_incr*zoom_toggle;

  rot_alpha = radians(rotAlpha);
  rot_zoom = radians(rotZoom);
  img_zoom = sin(rot_zoom) * 3;
  xx = cos(rot_alpha)*img_zoom*LIGHTS_WIDTH;
  yy = sin(rot_alpha)*img_zoom*LIGHTS_WIDTH;

  int imageSize = rotozoom.width;
  background(0);
  pushMatrix();
  translate((width/2)+xx, (height/4)+yy);
  rotate(rot_alpha);
  scale(img_zoom);
  if (hueCycleable==true) {
  colorMode(HSB,100);
  tint(cycleHue,100,100);
  }
  image(rotozoom,-(imageSize/2),-(imageSize/2),imageSize+xx,imageSize+yy);
  popMatrix();
  
}

// --- EFFECT ---
// Plasma
// 
// |        Rodolphe Pineau    RTI-Zone        |
// |         http://www.rti-zone.org/          |
// |   Robotics / Unix / Mac OS X / Astronomy  |
PImage plasma;
int plasma_init_done = 0;
int[] plasma_pallet = new int[256];
float t=0;
float pscale = 0;

void init_Pallet() 
{
    int R,G,B =0;
    plasma = createImage(width, height/2, RGB);
    for(int i =0; i<256; i++) {
      R = abs(int(127+cos(PI * i /128)*128)) % 256;
      G = abs(int(127+sin(PI * i /128)*128)) % 256;
      B = 0;
      plasma_pallet[i] = color(R, G, B);
    }
    
    plasma_init_done = 1;
}

void effect_Plasma()
{
  float c;
  float min_c =0;
  if(plasma_init_done == 0) {
    init_Pallet();
  }
  
  pscale = 0.6 * pscale + 0.4 * in.mix.level();
  
  for (int y=0; y< height/2; y++) {
    for (int x=0; x< width; x++) {
      c=sin(x / 40.74 + t);
      c+=sin(dist(x, y, (250 * (pscale+0.1) * sin(-t) + PIXEL_HEIGHT), (250 * (pscale+0.1) * cos(-t) + 80)) / 40.74);
      c=abs((127+(c*127)) %  256);
      plasma.set(x,y, plasma_pallet[int(c)]);
    }
  }
  image(plasma,0,0,width,height/2);
  t += 0.1;
}

// --- EFFECT ---
// Mapped Tunnel
// Rotating mapped tunnel
// |        Rodolphe Pineau    RTI-Zone        |
// |         http://www.rti-zone.org/          |
// |   Robotics / Unix / Mac OS X / Astronomy  |


PImage tunnel;
int tunnel_init_done =0;
float smoothlevel = 0;
float[][] angle_lut = new float[PIXEL_HEIGHT][PIXEL_WIDTH];
float[][] depth_lut = new float[PIXEL_HEIGHT][PIXEL_WIDTH];
int texture_width;
int texture_height;
int tunnel_rotated = 0;
int tunnel_zoomed = 0;

void pre_calc_angle_depth_lut() {
  float relative_x;
  float relative_y;
  float angle;
  float depth;
  
  for (int y = 0; y < height/2; y++) {    
    for(int x = 0; x < width; x++) {

      relative_x = x - (width/2);
      relative_y = (height/2) - y;

      if (relative_y == 0) { 
        if (relative_x > 0) 
          angle = -90;
        else 
          angle = 90;
      }
      else
        angle = degrees(atan(relative_x / relative_y));
      
      if (relative_y > 0)
        angle = angle + 180;

      angle_lut[y][x] = angle;
      depth = 65536 / (pow(relative_x,2) + pow(relative_y,2));
      depth_lut[y][x] = depth;
      
    } 
  }
}


void tunnel_init() {
  tunnel = createImage(width, height/2, RGB);
  pre_calc_angle_depth_lut();
  tunnel_init_done = 1;
}

void effect_Mapped_Tunnel()
{
  float texture_x, texture_y;
  if(tunnel_init_done == 0) {
    tunnel_init();
    texture_width = sourcePattern.width;
    texture_height = sourcePattern.height;
  }
  for (int y=0; y< height/2; y++) {
    for (int x=0; x< width; x++) {
      texture_x = abs(angle_lut[y][x] + tunnel_rotated)  % texture_width;
      texture_y = abs(depth_lut[y][x] + tunnel_zoomed) % texture_height;
      
      tunnel.copy(sourcePattern,int(texture_x),int(texture_y),1,1,x,y,1,1);
    }
  }
  if (hueCycleable==true) {
  colorMode(HSB,100);
  tint(cycleHue,100,100);
  }
  image(tunnel,0,0,width,height/2);

  smoothlevel = 0.8 * smoothlevel + 0.2 * in.mix.level();
  tunnel_rotated+=smoothlevel*30;
  tunnel_zoomed+=smoothlevel*14;
}


// --- EFFECT ---
// DownTheHall
// Added by Dean Cheesman (deancheesman.com)
// Generates expanding Hallway on isKick detection
int squareHue = 0;
void effect_square() {
  rectMode(CENTER);
  beat.detect(in.mix);
  
  //background(0);
  //fill(0,10);
  //rect(0,0,PIXEL_WIDTH,PIXEL_HEIGHT);

  if ( beat.isKick() ) {
    Squares.add(new square1(width/2,height/4,squareHue));
    squareHue += 14;
    squareHue %= 100;
  }
  
  for (int i = Squares.size() - 1; i >= 0; i--) {
    square1 thisSquare = (square1) Squares.get(i);
    thisSquare.update();
    if (thisSquare.done()) Squares.remove(i); 
  }
  
}

// Class for Square Hall effect
class square1 {
  
  int xpos, ypos, dropcolor, dropSize;
  boolean finished;
  
  square1 (int x, int y, int c) {
    xpos = x;
    ypos = y;
    dropcolor = c;
    finished = false;
  }
  
  void update() {
    if (!finished) {
      colorMode(HSB, 100);
      noFill();
      strokeWeight(dropWallSize); 
      stroke(dropcolor,100,100);
      rect(xpos,ypos,dropSize,dropSize);
      if (dropSize < 550) {
        dropSize += 15;
      } else {
        finished = true;
      }
      colorMode(RGB, 255);
    }
  }
  
  boolean done() {
    return finished;
  }
}

// --- EFFECT ---
// Bouncers
// Added by Dean Cheesman (deancheesman.com)
// Generates Bouncing pixels on isKick detection
int bounceHue = 0;
void effect_bouncers() {

  beat.detect(in.mix);
  
  fill(0,10); //
  rectMode(CORNER);
  rect(0,0,PIXEL_WIDTH,PIXEL_HEIGHT);
  rectMode(CENTER);
  if ( beat.isKick() ) {
    Bouncers.add(new Bouncer(180,80,bounceHue));
    bounceHue += 4;
    bounceHue %= 100;
  }
  
  for (int i = Bouncers.size() - 1; i >= 0; i--) {
    Bouncer bouncer = (Bouncer) Bouncers.get(i);
    bouncer.update();
    if (bouncer.done()) Bouncers.remove(i); 
  }
  
}

// Class for Square Hall effect
class Bouncer {
  
  int xpos, ypos, dropcolor;
  float vx, vy, age;
  boolean finished;
  
  Bouncer (int x, int y, int c) {
    xpos = x;
    ypos = y;
    dropcolor = c;
    finished = false;
    vx = random(-15,15);
    vy = random(-15,15);
    age = 0;
  }
  
  void update() {
    if (!finished) {
      if(xpos + vx>PIXEL_WIDTH || xpos + vx < 0){
        vx *= -1; 
      }
      if(ypos + vy>PIXEL_HEIGHT || ypos + vy < 0){
        vy *= -1;
      }      
      
      xpos += vx;
      ypos += vy;
      
      colorMode(HSB, 100);
      noStroke();
      fill(dropcolor,100,100);
      rect(xpos,ypos,20,20);
      if (age < 40) {
        age += 1;
      } else {
        finished = true;
      }
      colorMode(RGB, 255);
    }
  }
  
  boolean done() {
    return finished;
  }
}


// --- EFFECT ---
// Suns
// Generates expanding Suns following bass.
// By Marc-Andre Ferland
int numBlobs = 3;

float[] blogPx;
float[] blogPy;

// Movement vector for each blob
float[] blogDx;
float[] blogDy;

int[][] vy,vx;

PGraphics pgSuns;
boolean setupSuns = false;

// Increase this number to make your blobs bigger
float blogbaseSize = 200;
float blogMultSize = 1500;

float suns_smoothfft = 0;

void effect_suns() {
  if(!setupSuns) {
    pgSuns = createGraphics(LIGHTS_WIDTH*10, LIGHTS_HEIGHT*10, JAVA2D);
    vy = new int[numBlobs][pgSuns.height];
    vx = new int[numBlobs][pgSuns.width];

    blogDx = new float[numBlobs];
    blogDy = new float[numBlobs];
    blogPx = new float[numBlobs];
    blogPy = new float[numBlobs];

    for (int i=0; i<numBlobs; ++i) {
      blogDx[i] = random(-1, 1);
      blogDy[i] = random(-1, 1);
      blogPx[i] = random(0, pgSuns.width);
      blogPy[i] = random(0, pgSuns.height);
    }
    setupSuns = true;
  }

  fft.forward(in.mix);

  for (int i=0; i<numBlobs; ++i) {
    blogPx[i]+=blogDx[i];
    blogPy[i]+=blogDy[i];

    // bounce across screen
    if (blogPx[i] < 0) {
      blogDx[i] = abs(blogDx[i]);
    }
    if (blogPx[i] > pgSuns.width) {
      blogDx[i] = abs(blogDx[i]) * (-1);
    }
    if (blogPy[i] < 0) {
      blogDy[i] = abs(blogDy[i]);
    }
    if (blogPy[i] > pgSuns.height) {
      blogDy[i] = abs(blogDy[i]) * (-1);
    }

    for (int x = 0; x < pgSuns.width; x++) {
      vx[i][x] = int(sq(blogPx[i]-x));
    }

    for (int y = 0; y < pgSuns.height; y++) {
      vy[i][y] = int(sq(blogPy[i]-y));
    }
  }

  // draw blobs
  suns_smoothfft = 0.7 * suns_smoothfft + 0.3 * fft.getAvg(0);

  pgSuns.beginDraw();
  pgSuns.loadPixels();
  for (int y = 0; y < pgSuns.height; y++) {
    for (int x = 0; x < pgSuns.width; x++) {
      float m = 1;
      for (int i = 0; i < numBlobs; i++) {
        float blobSize = blogbaseSize + (suns_smoothfft * blogMultSize);
        m += blobSize/(vy[i][y] + vx[i][x]+1);
      }
      pgSuns.pixels[x+y*pgSuns.width] = color(m+x, (x+m+y)/2, 0);
    }
  }
  pgSuns.updatePixels();
  pgSuns.endDraw();

  image(pgSuns, 0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
}

// --- EFFECT ---
// Fire
// By Marc-Andre Ferland
int[][] fire;

// Flame colors
color[] palette;
int[] calc1,calc2,calc3,calc4,calc5;

PGraphics pgFire;

boolean setupFire = false;

void effect_fire() {

  if(!setupFire) {
    pgFire = createGraphics(20, 40, JAVA2D);
    calc1 = new int[pgFire.width];
    calc3 = new int[pgFire.width];
    calc4 = new int[pgFire.width];
    calc2 = new int[pgFire.height];
    calc5 = new int[pgFire.height];

    fire = new int[pgFire.width][pgFire.height];
    palette = new color[255];

    colorMode(HSB, 255);
    // Generate the palette
    for(int x = 0; x < palette.length; x++) {
      //Hue goes from 0 to 85: red to yellow
      //Saturation is always the maximum: 255
      //Lightness is 0..255 for x=0..128, and 255 for x=128..255
      palette[x] = color(x/3, 255, constrain(x*3, 0, 255));
    }
    colorMode(RGB, 255);

    // Precalculate which pixel values to add during animation loop
    // this speeds up the effect by 10fps
    for (int x = 0; x < pgFire.width; x++) {
      calc1[x] = x % pgFire.width;
      calc3[x] = (x - 1 + pgFire.width) % pgFire.width;
      calc4[x] = (x + 1) % pgFire.width;
    }

    for(int y = 0; y < pgFire.height; y++) {
      calc2[y] = (y + 1) % pgFire.height;
      calc5[y] = (y + 2) % pgFire.height;
    }

    setupFire = true;
  }

  fft.forward(in.mix);
  colorMode(HSB, 255);

  // Randomize the bottom row of the fire buffer
  float w = ((float)pgFire.width)/((float)fft.specSize())*2;
  for(int i = 0; i < fft.specSize()/2; i++)
  {
    float h = log(fft.getBand(i)*4)*40+10;
    for(int x = 0; x < w; x++)
      fire[floor(w*i)+x][pgFire.height-1] = int(constrain(random(h, h+60), 0, 255));
  }

  pgFire.beginDraw();
  pgFire.loadPixels();

  int counter = 0;
  // Do the fire calculations for every pixel, from top to bottom
  for (int y = 0; y < pgFire.height; y++) {
    for(int x = 0; x < pgFire.width; x++) {

      fire[x][y] =
        ((fire[calc3[x]][calc2[y]]
        + fire[calc1[x]][calc2[y]]
        + fire[calc4[x]][calc2[y]]
        + fire[calc1[x]][calc5[y]]) << 5) / 129;

      pgFire.pixels[counter] = palette[fire[x][y]];
      counter++;
    }
  }
  pgFire.updatePixels();
  pgFire.endDraw();

  image(pgFire, 0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
  colorMode(RGB, 255);
}


// --- EFFECT ---
// bubbles_cmooney
// Author: Charles Mooney
// www.charlesmooney.com
class Circle {
  float _r, _x, _y, _h;
  float _v;

  Circle(float v) {
    _x = (int)random(PIXEL_WIDTH);
    _y = (int)random(PIXEL_HEIGHT);
    _r = (int)random(40);
    _h = (int)random(255); 
    _v = v;
  }

  void update(float energy) {
   _r = (0.3 * _r) + (0.7 * energy / _v);
  }

  void display() {
    noStroke();
    fill(_h, 255, 255);
    ellipse(_x, _y, _r, _r); 
  }
}

ArrayList circles = new ArrayList();
int max_circles = 3;
int num_bands_circles = 32;

void effect_bubbles_cmooney() {
  fft.forward(in.mix);

  float h = 0.0, energy = 0.0;
  int max_energy_band = 0;
  for(int band = 0; band < num_bands_circles; ++band) {
    if(fft.getAvg(band) > fft.getAvg(max_energy_band))
      max_energy_band = band;
    h += band * fft.getAvg(band);
    energy += fft.getAvg(band);
  }

  colorMode(HSB, 256);
  h = (h / energy) * (256 / num_bands_circles);
  background((h + 128.0) % 256.0, 255, 255);

  max_circles = (int)log(energy);
  if(!(max_circles > 0)) max_circles = 1;
  
  if(circles.size() < max_circles) {
    for(int i = 0; i < max_circles - circles.size(); ++i)
      circles.add(new Circle(random(6) + 2));
  }else if(circles.size() > max_circles) {
    while(circles.size() > max_circles)
      circles.remove((int)random(circles.size())); 
  }


  for(int i = 0; i < circles.size(); ++i) {
    Circle c = (Circle)circles.get(i);
    c.display(); 
    c.update(energy);
  }
}


// --- EFFECT ---
// Very simple Rainbow Spectrum analyzer
// Author: Charles Mooney
// www.charlesmooney.com

int num_bands_rainbow = LIGHTS_WIDTH;
float scaling_factor = 24.0;

void effect_plaid() {
  background(0);
  noStroke();
  colorMode(HSB, 256);

  fft.forward(in.mix);
  rectMode(CORNER);
  for(int band = 0; band < num_bands_rainbow; ++band) {
    float logfft = log(fft.getAvg(band) * 3)*scaling_factor;
    fill(band * 256 / num_bands_rainbow, 255, 255);
    rect(band * (width / num_bands_rainbow), (height / 2) - (logfft),
         width / num_bands_rainbow, (logfft));
  }
}


// --- EFFECT ---
// Spectogram
// Draws a spectrogram, scrolling across the screen
// Author: Charles Mooney
// www.charlesmooney.com

int[] row = new int[32];
Spectrogram spec = new Spectrogram(14, 32);

class Spectrogram {
    Spectrogram(int w, int h) {
      _w = w;
      _h = h;
      _s = new int[_w][_h];
      for(int x = 0; x < _w; ++x)
        for(int y = 0; y < _h; ++y)
          _s[x][y] = 0;
    }

    void addRow(int[] row) {
      shiftDown();
      for(int y = 0; y < _h; ++y)
        _s[0][y] = row[y];
    }
    
    void shiftDown() {
      for(int x = _w-1; x >= 1; --x)
        for(int y = 0; y < _h; ++y)
           _s[x][y] = _s[x-1][y]; 
    }
    
    // Selects a color based on the magnitude, this can easily be changed to alter the appearance.
    void setColor(int magnitude) {
      float r = 255, g = 255, b = 255;
      if(magnitude < 32) {
        r = ((float)magnitude/32.0) * 0;
        g = ((float)magnitude/32.0) * 128;
        b = ((float)magnitude/32.0) * 255;
      } else if(magnitude < 64){
        r = 0   + ((float)(magnitude-32)/32.0) * (100 - 0);
        g = 128 + ((float)(magnitude-32)/32.0) * (255 - 128);
        b = 255 + ((float)(magnitude-32)/32.0) * (128 - 255);        
      } else if(magnitude < 96){
        r = 100 + ((float)(magnitude-32)/32.0) * (255 - 100);
        g = 255 + ((float)(magnitude-32)/32.0) * (255 - 255);
        b = 128 + ((float)(magnitude-32)/32.0) * (0   - 128);        
      } else if(magnitude < 96){
        r = 255 + ((float)(magnitude-32)/32.0) * (255 - 255);
        g = 255 + ((float)(magnitude-32)/32.0) * (255 - 255);
        b = 0 + ((float)(magnitude-32)/32.0) *   (255 - 0);        
      } 
      fill((int)r, (int)g, (int)b);
    }
    
    // Display what is currently stored
    void display() {  
      rectMode(CORNERS);
      
      for(int x = 0; x < _w; ++x)
        for(int y = 0; y < _h; ++y) {     
          setColor(_s[x][y]);
          rect(x*(width/_w), y*(height/_h), (x+1)*(width/_w), (y+1)*(height/_h));
        }
  
    }
    
    int[][] _s;
    int _w, _h;
}

void effect_spectrogram() {
 background(0);
 fft.forward(in.mix);
 
  noStroke();
  for(int i = 0; i < fft.avgSize(); i++)
    row[i] = (int)fft.getAvg(i);

  spec.addRow(row);    
  spec.display();
}


// --- EFFECT ---
// Perlin based
// Red: Kick
// Green: Snare
// Blue: Hats
// By Juan Alonso
float dampenKick = 0;
float dampenSnare = 0;
float dampenHat = 0;
int offset = 0;
void effect_perlin(float divider, float lr, float lg, float lb) {
  beat.detect(in.mix);
  rectMode(CORNER);
  noStroke();
  float i, j;
  float r, g, b;
  background(0);
  if (beat.isKick()) dampenKick = 1;
  if (beat.isSnare()) {
    if (dampenSnare<=0) offset++;
    dampenSnare = 1;
  }
  if (beat.isHat()) dampenHat = 1;
  for (int y = 0; y <= LIGHTS_HEIGHT; y++) {
    j = y * divider;
    for (int x=0; x <= LIGHTS_WIDTH; x++) {      
      i = x*divider;
      r =perlin (j, i,    offset, lr, 0.80)*dampenKick;
      g =perlin (j, i+10, offset, lg, 0.75)*dampenSnare;
      b =perlin (j, i+20, offset, lb, 0.80)*dampenHat;
      fill(r, g, b);
      rect(x*20, y*20, 20, 20);
    }
  }
  if (dampenKick > 0) dampenKick -= 0.05;
  if (dampenSnare > 0) dampenSnare -= 0.2;
  if (dampenHat > 0) dampenHat -= 0.05;
}

float perlin(float j, float i, float offset, float low, float high) {
  float v = noise(j, i, offset);
  if (v < low) return 0;
  v = map(v, low, high, 0, 255);
  if (v> 255) return 255;
  return v;
}



// --- EFFECT ---
int num_bands_quinn = 32;

int [] x = new int[num_bands_quinn];
int [] y = new int[num_bands_quinn];


//Created by Quinn Baetz
//Randomly moves circles, their color corresponds to their associated frequency band.  
//The size of the circle indicates the height of the frequency band.
void effect_quinn() {
  noStroke();
  colorMode(HSB, 256);
  
  fft.forward(in.mix);
  int myMax = 0;
  for(int band = 0; band < num_bands_quinn; ++band) {
    int val = (int)(fft.getAvg(band)*2);
     x[band] += ((int)random(50)-25);
     y[band] += ((int)random(40)-20);
    
     x[band] = min(PIXEL_WIDTH, max(0, x[band]));  
     y[band] = min(PIXEL_HEIGHT, max(0, y[band]));
    
     fill(band * 256 / num_bands_quinn, 255, 2550);
     ellipse(x[band], y[band], val, val);
  }
 }

//Created by Charlie Mooney, changes background color based on spectogram
void effect_spectrogram_max() {
  fft.forward(in.mix);
      
  float h = 0.0, energy = 0.0;
  int max_energy_band = 0;
  for(int band = 0; band < num_bands_quinn; ++band) {
    if(fft.getAvg(band) > fft.getAvg(max_energy_band))
      max_energy_band = band;
    h += band * fft.getAvg(band);
    energy += fft.getAvg(band);
  }

  colorMode(HSB, 256);
  h = (h / energy) * (256 / num_bands_quinn);
  background((h + 128.0) % 256.0, 255, 255);
  noStroke();
  fill(h, 128, 128);
  
  
}



// for use with the mosaic effect
class WanderingSquare {
  int start_x_pos, start_y_pos, end_x_pos, end_y_pos;
  float vec_x, vec_y;
  int square_width;
  int h, s, v;
  int frames_elapsed;
  int total_frames;
  int pulse_square;
  float rot_inc;
  float rotation;
  
  WanderingSquare() {
    square_width = 50 + int(random(0, 20));
    
    int start_state = int(random(0, 3.99));
    
    if(start_state == 0) {
      start_x_pos = int(-float(square_width)/sqrt(2));
      start_y_pos = int(random(-square_width, 139+square_width));
      end_x_pos = int(299+float(square_width)/sqrt(2));
      end_y_pos = int(random(-square_width, 139+square_width));
    }
    else if(start_state == 1) {
      start_x_pos = int(299+float(square_width)/sqrt(2));
      start_y_pos = int(random(-square_width, 139+square_width));
      end_x_pos = int(-float(square_width)/sqrt(2));
      end_y_pos = int(random(-square_width, 139+square_width));
    }
    else if(start_state == 2) {
      start_x_pos = int(random(-square_width, 299+square_width));
      start_y_pos = int(-float(square_width)/sqrt(2));
      end_x_pos = int(random(-square_width, 299+square_width));
      end_y_pos = int(139+float(square_width)/sqrt(2));
    }
    else {
      start_x_pos = int(random(-square_width, 299+square_width));
      start_y_pos = int(139+float(square_width)/sqrt(2));
      end_x_pos = int(random(-square_width, 299+square_width));
      end_y_pos = int(-float(square_width)/sqrt(2));
    }
    total_frames = int(random(6.0, 10.0) * frameRate); // seconds times framerate
    frames_elapsed  = 0;
    rotation = random(0, PI/2);
    rot_inc = random(PI/2, 2*PI)/total_frames;
    vec_x = (end_x_pos - start_x_pos)/float(total_frames);
    vec_y = (end_y_pos - start_y_pos)/float(total_frames);
    
    h = int(random(0, 255));
    s = 100;//78;
    v = 255;
    pulse_square = 0;
  }
  
  void pulse() {
    pulse_square = 5;
  }
  
  void update() {
    noStroke();
    colorMode(HSB, 255);
    fill(h, s, v);
    rotation += rot_inc;
    translate(start_x_pos + vec_x * frames_elapsed,
        start_y_pos + vec_y * frames_elapsed);
    rotate(rotation);
    
    if(pulse_square <= 0) {
      rect(-square_width/2, -square_width/2,
          square_width, square_width);
    }
    
    else {
      rect(-square_width/4, -square_width/4,
          square_width/2, square_width/2);
      pulse_square--;
    }
    
    rotate(-rotation);
    translate(-start_x_pos - vec_x * frames_elapsed,
        -start_y_pos - vec_y * frames_elapsed);
    colorMode(RGB);
    frames_elapsed++;
  }
  
  int getH() {
    return h;
  }
  
  void setH(int new_h) {
    if(new_h >= 0 && new_h <= 255) {
      h = new_h;
    }
  }
  
  int getS() {
    return s;
  }
  
  void setS(int new_s) {
    if(new_s >= 0 && new_s <= 255) {
      s = new_s;
    }
  }
  
  int getV() {
    return v;
  }
  
  boolean isDead() {
    return frames_elapsed > total_frames;
  }
}

// --- EFFECT ---
// Shifting Mosaic
// Generates pulsing squares on beats
// Shifts hues within range of complementary colors
// Created by Ivan Check from Hackerspace Nixipi
int square_limit = 100;
float color_change_prob = 0.4;
int satur = 255;
int hu = int(random(25,230));
int hu_delay_var = 0;
int hu_delay = 10;
int hu_inc = 1;

void effect_shiftingMosaic() {
  beat.detect(in.mix);
  colorMode(RGB);
  
  background(0);
  
  if(WSquares.size() < square_limit && (beat.isKick() || beat.isOnset() || beat.isSnare() || beat.isHat())){
    WSquares.add(new WanderingSquare());
    if(random(0, 1) > .8) {
      WSquares.add(new WanderingSquare());
    }
  }
  
  for (int i = 0; i < WSquares.size(); i++) {
    WanderingSquare wa = (WanderingSquare)(WSquares.get(i));
    if(beat.isHat() || beat.isSnare()) {
      if(wa.getH() >= 100 && wa.getH() < 255)
        wa.pulse();
        
      if(random(0, 1) > 1.0-color_change_prob) {
        wa.setH(int(random((255-hu)-25, (255-hu)+25)));
      }
    }
    if(beat.isKick() || beat.isOnset()) {
      if(wa.getH() >= 0 && wa.getH() < 100)
        wa.pulse();
      if(random(0, 1) > 1.0-color_change_prob) {
        wa.setH(int(random(hu-25, hu+25)));
      }
    }
      
    if(beat.isHat() || beat.isSnare()) {
      if(wa.getH() >= 100 && wa.getH() < 255)
        wa.pulse();
        
      if(random(0, 1) > 1.0-color_change_prob) {
        wa.setH(int(random((255-hu)-25, (255-hu)+25)));
      }
    }
   
   if(random(0, 1) > 1) {
     wa.setH(int(random(0, 255)));
   }
   wa.setS(satur);
    
    wa.update();
    if (wa.isDead()) WSquares.remove(i);
  }
  
  // slowly change the hue
  // you can adjust the settings that are before the function
  if(hu_delay_var >= hu_delay) {
      hu = hu + hu_inc;
      if(hu > 230) {
        hu = 230;
        hu_inc *= -1;
      }
      
      else if(hu < 25) {
        hu = 25;
        hu_inc *= -1;
      }
      
      hu_delay_var = 0;
  }
  hu_delay_var++;
}



/* Effects by macetech */

// --- EFFECT ---
// Raindrops
// Generates expanding droplets on isKick detection
ArrayList Drops;
int dropWallSize = 30;
int dropHue = 0;
void effect_drops() {

  beat.detect(in.mix);
  
  background(0);

  if ( beat.isKick() ) {
    Drops.add(new drop1(int(random(19,299)),int(random(19,139)),dropHue));
    dropHue += 4;
    if (dropHue > 100) dropHue -= 100;
  }
  
  for (int i = Drops.size() - 1; i >= 0; i--) {
    drop1 drop = (drop1) Drops.get(i);
    drop.update();
    if (drop.done()) Drops.remove(i); 
  }
  
}

// Class for Raindrops effect
class drop1 {
  
  int xpos, ypos, dropcolor, dropSize;
  boolean finished;
  
  drop1 (int x, int y, int c) {
    xpos = x;
    ypos = y;
    dropcolor = c;
    finished = false;
  }
  
  void update() {
    if (!finished) {
      colorMode(HSB, 100);
      noFill();
      strokeWeight(dropWallSize); 
      stroke(dropcolor,100,100);
      ellipse(xpos,ypos,dropSize,dropSize);
      if (dropSize < 550) {
        dropSize += 15;
      } else {
        finished = true;
      }
      colorMode(RGB, 255);
    }
  }
  
  boolean done() {
    return finished;
  }
}


// --- EFFECT ---
// Spin image
// Rotates an image and bounces back on isKick
color ledColor;
int rotDegrees = 0;
int spinImage_hue = 0;
void effect_spinImage() {

  //beat.detect(in.mix);  
  
  int imageSize = 400;
  background(0);
  pushMatrix();
  translate(width/2,height/4);

  rotDegrees += 40*in.mix.level();
  //if (beat.isKick()) rotDegrees -= 36;
  if (rotDegrees > 359) rotDegrees -= 360;
  if (rotDegrees < 0) rotDegrees += 360;

  rotate(radians(rotDegrees));
  //if (spinImage_hue++ > 100) spinImage_hue = 0;
  
  if (hueCycleable==true) {
  colorMode(HSB,100);
  tint(cycleHue,100,100);
  }
  image(sourcePattern,-(imageSize/2),-(imageSize/2),imageSize,imageSize);
  colorMode(RGB,255);
  popMatrix();
  
}

// --- EFFECT ---
// Spectrum
// Draws an FFT with peak hold
void effect_spectrum() {
 background(0);
  
 fft.forward(in.mix);
 
  noStroke();
    // draw the linear averages
  int w = int(width/fft.avgSize());
  int h;
  
  for(int i = 0; i < fft.avgSize(); i++)
  {
    fftSmooth[i] = 0.4 * fftSmooth[i] + 0.6 * fft.getAvg(i);
    
    h = int(log(fftSmooth[i]*3)*30);
    if (fftHold[i] < h) {
      fftHold[i] = h;
    }
    
    rectMode(CORNERS);
    fill(255*h/150,0,255-255*h/150);
    rect(i*w*2, height/2, i*w*2 + w*2, height/2 - h);
    fill(0,255,0);
    rect(i*w*2, height/2 - fftHold[i] + 12, i*w*2 + w*2, height/2 - fftHold[i]-12);

    fftHold[i] = fftHold[i] - 1;
    if (fftHold[i] < 0) fftHold[i] = 0;
  }
  
}

// --- EFFECT ---
// Sparkly sparks
// Creates a field of sparks that pulse and travel
ArrayList Sparks;
PVector sparkMotion;
int sparkHue = 0;
int sparkScroll = 0;

void effect_sparks() {

  beat.detect(in.mix);
  
  background(0);

  if ( beat.isKick() ) {
    Sparks.add(new spark1(-30,int(random(0,7))*20+10,sparkHue,30, 1.0, 0.0));
    sparkHue += 1;
    if (sparkHue > 100) sparkHue -= 100;
  }
 
  
  float currentLevel = in.mix.level();
  
  for (int i = Sparks.size() - 1; i >= 0; i--) {
    spark1 spark = (spark1) Sparks.get(i);
    spark.motion = PVector.mult(sparkMotion, 5);
    spark.sparkSize = int(100*currentLevel)+10;
    spark.update();
    if (spark.done()) Sparks.remove(i); 
  }
  
}

// --- EFFECT ---
// Shooting stars
// Stars criscrossing the field
ArrayList Stars;
PVector starMotion;
int starHue = 0;

void effect_stars() {

  beat.detect(in.mix);
  
  background(0);

  if ( beat.isKick() ) {
    
    float rangle = radians(random(0,359));
    float rmag = random(15,25);
    
    float xmot = cos(rangle)*rmag;
    float ymot = sin(rangle)*rmag;
    
    int xinit = 0;
    int yinit = 0;
    
    if (xmot >= 0) {
      xinit = int(random(0,width/2)-30);
    } else {
      xinit = int(random(width/2,width)+30);
    }

    if (ymot >= 0) {
      yinit = -30;
    } else {
      yinit = height/2+30;
    }
    
    Stars.add(new spark1(xinit,yinit,starHue,60,xmot,ymot));
    starHue += 1;
    if (starHue > 100) starHue -= 100;
  }
 
  
  float currentLevel = in.mix.level();
  
  for (int i = Stars.size() - 1; i >= 0; i--) {
    spark1 star = (spark1) Stars.get(i);
    //star.motion = PVector.mult(starMotion, 5);
    //spark.sparkSize = int(100*currentLevel)+10;
    star.update();
    if (star.done()) Stars.remove(i); 
  }
  
}

// Class for Sparks effect
class spark1 {
  
  PVector motion;
  
  int xpos, ypos, sparkColor, sparkSize;
  boolean finished;
  
  spark1 (int x, int y, int c, int s, float xm, float ym) {
    xpos = x;
    ypos = y;
    sparkColor = c;
    sparkSize = s;
    finished = false;
    motion = new PVector(0, 0);
    motion.x = xm;
    motion.y = ym;
  }
  
  void update() {
    if (!finished) {
      colorMode(HSB, 100);
      noStroke();
      fill(sparkColor,100,100);
      if ((xpos > -50) || (xpos < width+50) || (ypos > (height/2-50)) || (ypos < (height+50)))  {
        xpos += motion.x;
        ypos += motion.y;
        ellipse(xpos,ypos,sparkSize,sparkSize);
      } else {
        finished = true;
      }

      colorMode(RGB, 255);
    }
  }
  
  boolean done() {
    return finished;
  }
}

// --- EFFECT ---
// Waveform
// Simple waveform effect
void effect_waveform() {

  background(0);
  
  strokeWeight(30);
  stroke(255,0,0);
  
  for (int i = 0; i < width - 1; i+=5) {

    line (i, in.mix.get(i)*2*height/4+height/4, i+5, in.mix.get(i+5)*2*height/4+height/4);
  }
  
}


// --- EFFECT ---
// Dual VU Meter
// Draws a stereo VU meter


// --- EFFECT ---
// Text
// Author: Ian Pickering

String text = "ACM @ UIUC";
PFont font;
int text_init_done = 0;
int text_x = 14;
int text_y = 8;

void effect_text() {
  directWrite = true;
  if (text_init_done == 0) {
    println("init text");
    init_text();
    text_init_done = 1;
  }
  fill(0, 64);
  rect(-1, -1, 15, 11);
  fill(255);

  if (text_x < 0) {
 
    text(text, text_x + textWidth(text) + 10, text_y);
  }
 
  // if the first copy of the text is completely offscreen, set x to be
  // at the current location of the second copy
  if (text_x <= -textWidth(text) - 2) {
    text_x = text_x + (int)textWidth(text) + 10;
  }
 
  // Draw the text
  text(text, text_x, text_y);
  // move the position one to the left
  if (frame % 3 == 0) {
    text_x--;
  }
}

// --- EFFECT ---
// Mandelbrot
// Author: Ian Pickering


float frac_w = 5;
float frac_h = (frac_w * height) / width;

int frac_pixw = PIXEL_WIDTH;
int frac_pixh = PIXEL_HEIGHT;

PGraphics frac;

float frac_zoom = 1.0;
float frac_zoomdelta = 0.990;

float frac_offx = -0.5;
float frac_offy = -0.5514;

// Start at negative half the width and height
float frac_xmin = frac_w * -0.5;
float frac_ymin = frac_h * -0.5;

boolean setup_frac = false;

// Maximum number of iterations for each point on the complex plane
int frac_maxiterations = 100;

// x goes from xmin to xmax
float frac_xmax = frac_xmin + frac_w;
// y goes from ymin to ymax
float frac_ymax = frac_ymin + frac_h;

// Calculate amount we increment x,y for each pixel
float frac_dx = (frac_xmax - frac_xmin) / (frac_pixw);
float frac_dy = (frac_ymax - frac_ymin) / (frac_pixh);

void effect_mandelbrot() {
  if(!setup_frac) {
    frac = createGraphics(frac_pixw, frac_pixh, JAVA2D);
    setup_frac = true;
  }

  /* frac_xmax = frac_xmin + frac_w; */
  /* frac_ymax = frac_ymin + frac_h; */
  frac_dx = (frac_xmax - frac_xmin) / (frac_pixw);
  frac_dy = (frac_ymax - frac_ymin) / (frac_pixh);

  frac.beginDraw();
  frac.loadPixels();
  
  // Start y
  float y = frac_ymin + frac_offx;
  for (int j = 0; j < frac_pixh; j++) {
    // Start x
    float x = frac_xmin + frac_offy;
    for (int i = 0; i < frac_pixw; i++) {

      // Now we test, as we iterate z = z^2 + cm does z tend towards infinity?
      float a = x;
      float b = y;
      int n = 0;
      while (n < frac_maxiterations) {
        float aa = a * a;
        float bb = b * b;
        float twoab = 2.0 * a * b;
        a = aa - bb + x;
        b = twoab + y;
        // Infinty in our finite world is simple, let's just consider it 16
        if (aa + bb > 16.0) {
          break;  // Bail
        }
        n++;
      }
      // We color each pixel based on how long it takes to get to infinity
      // If we never got there, let's pick the color black
      if (n == frac_maxiterations) {
        frac.pixels[i+j*frac_pixw] = color(0);
      } else {
        // Gosh, we could make fancy colors here if we wanted
        frac.pixels[i+j*frac_pixw] = color(n*10 % 255,(n*10+50) % 255,(n*10+150) % 255);
      }
      x += frac_dx;
    }
    y += frac_dy;
  }
  frac.updatePixels();
  frac.endDraw();
  image(frac, 0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
  frac_xmin *= frac_zoomdelta;
  frac_ymin *= frac_zoomdelta;
  frac_xmax *= frac_zoomdelta;
  frac_ymax *= frac_zoomdelta;
}

// --- EFFECT ---
// Gradient
// Author: Ian Pickering


class gradient1 {
  int Y_AXIS = 1;
  int X_AXIS = 2;
  color c1, c2, b1, b2;
  int pos_x;

  public gradient1(color c) {
    this.c1 = color(0, 255);
    this.c2 = c;
    this.pos_x = -280;
  }

  void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

    noFill();

    if (axis == Y_AXIS) {  // Top to bottom gradient
      for (int i = y; i <= y+h; i++) {
        float inter = map(i, y, y+h, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(x, i, x+w, i);
      }
    }  
    else if (axis == X_AXIS) {  // Left to right gradient
      for (int i = x; i <= x+w; i++) {
        float inter = map(i, x, x+w, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(i, y, i, y+h);
      }
    }
  }

  void update() {
    this.pos_x += 20;
    setGradient(this.pos_x, 0, 280, 200, this.c1, this.c2, X_AXIS);
    /* setGradient(this.pos_x + 280, 0, 40, 200, this.c2, this.c1, X_AXIS); */
  }

  boolean isDone() {
    return this.pos_x > 280;
  }
}

boolean gradient_init_done = false;
ArrayList Gradients = new ArrayList();

void effect_gradient() {
  /* directWrite = true; */
  beat.detect(in.mix);
  background(0);

  if(beat.isKick()) {
    Gradients.add(new gradient1(color(0,0,255)));
  }

  /* for (int i = Gradients.size() - 1; i >= 0; i--) { */
  for (int i=0; i < Gradients.size();  i++) {
    gradient1 thisGradient = (gradient1) Gradients.get(i);
    thisGradient.update();
    if (thisGradient.isDone()) {Gradients.remove (i); i--;} 
  }
    
}

class shimmer1 {
  int xpos, ypos;
  color sqcolor;
  int age;

  int STEP_TIME = 20;
  int HOLD_TIME = 10;
  int MAX_AGE = 160;

  shimmer1(int x, int y, int c) {
    xpos = x;
    ypos = y;
    sqcolor = c;
    age = 0;
  }

  void update() {
    noStroke();
    float fin = 0;
    age++;
    if(age < STEP_TIME) {
      fin = (255/STEP_TIME) * age;
    } else if(age < STEP_TIME + HOLD_TIME) {
      fin = 255;
    } else {
      fin = (255/MAX_AGE) * (MAX_AGE-(age-STEP_TIME*2-HOLD_TIME*2));
    }
    fill(sqcolor, fin);
    rect(xpos,ypos,100,100);
  }

  boolean isDone() {
    return age > MAX_AGE;
  }
}

ArrayList Shimmers = new ArrayList();

void effect_shimmer() {
  beat.detect(in.mix);
  background(0);
  
  if(beat.isKick()) {
    Shimmers.add(new shimmer1(int(random (-30, PIXEL_WIDTH-30)), int(random(-30, PIXEL_HEIGHT-30)), color(252, 243, 185)));
  }
  if(beat.isHat()) {
    Shimmers.add(new shimmer1(int(random (-30, PIXEL_WIDTH-30)), int(random(-30, PIXEL_HEIGHT-30)), color(234, 16, 82)));
  }
  if(beat.isSnare()) {
    Shimmers.add(new shimmer1(int(random (-30, PIXEL_WIDTH-30)), int(random(-30, PIXEL_HEIGHT-30)), color(106, 195, 228)));
  }

  for (int i = Shimmers.size() - 1; i >= 0; i--) {
    shimmer1 thisShimmer = (shimmer1) Shimmers.get(i);
    thisShimmer.update();
    if (thisShimmer.isDone()) Shimmers.remove(i); 
  }
}
