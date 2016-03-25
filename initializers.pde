void init_rotozoom() {
  int src_width=sourcePattern.width;
  int src_height=sourcePattern.height;
  
  rotozoom = createImage(src_width*nb_tiles, src_height*nb_tiles, RGB);

  for(int i = 0; i < nb_tiles; i++) {
    for (int j = 0; j < nb_tiles; j++) {
      rotozoom.copy(sourcePattern,0,0,src_width,src_height,src_width*i,src_height*j, src_width, src_height);
    }
  }
}

void init_sparks() {

  sparkMotion = new PVector(1.0,0);
  Sparks = new ArrayList();

}

void init_stars() {

  starMotion = new PVector(1.0,0);
  Stars = new ArrayList();

}


void select_randomTileableImg() {
  
  if (!imgSelected) {
  
    hueCycleable = false;
    
  int randSelect = int(random(0,11));
  
  switch(randSelect) {
    
   case 0:
    sourcePattern = loadImage("effect_img_1.png");
    break; 

   case 1:
    hueCycleable = true;
    sourcePattern = loadImage("effect_img_2.png");
    break;    

   case 2:
    sourcePattern = loadImage("effect_img_3.png");
    break;

   case 3:
    sourcePattern = loadImage("effect_img_4.png");
    break;

   case 4:
    sourcePattern = loadImage("effect_img_5.png");
    break;

   case 5:
    hueCycleable = true;
    sourcePattern = loadImage("effect_img_6.png");
    break;

   case 6:
   hueCycleable = true;
    sourcePattern = loadImage("effect_img_7.png");
    break;

   case 7:
    sourcePattern = loadImage("effect_img_8.png");
    break;

   case 8:
    sourcePattern = loadImage("effect_img_9.png");
    break;

   case 9:
   hueCycleable = true;
    sourcePattern = loadImage("effect_img_10.png");
    break;    

   case 10:
    sourcePattern = loadImage("acm.png");
    break;    
  }
  
  imgSelected = true;
  
  }
  
}

void select_randomCenteredImg() {

  if (!imgSelected) {
    hueCycleable = false;
  
  int randSelect = int(random(0,16));
  
  switch(randSelect) {
    
   case 0:
    sourcePattern = loadImage("effect_img_1.png");
    break; 

   case 1:
   hueCycleable = true;
    sourcePattern = loadImage("effect_img_2.png");
    break;    

   case 2:
    sourcePattern = loadImage("effect_img_3.png");
    break;

   case 3:
    sourcePattern = loadImage("effect_img_4.png");
    break;

   case 4:
    sourcePattern = loadImage("effect_img_5.png");
    break;

   case 5:
   hueCycleable = true;
    sourcePattern = loadImage("effect_img_6.png");
    break;

   case 6:
   hueCycleable = true;
    sourcePattern = loadImage("effect_img_7.png");
    break;

   case 7:
    sourcePattern = loadImage("effect_img_8.png");
    break;

   case 8:
    sourcePattern = loadImage("effect_img_9.png");
    break;

   case 9:
    sourcePattern = loadImage("effect_img_10.png");
    break;

   case 10:
    sourcePattern = loadImage("spiral1.png");
    break;

   case 11:
    sourcePattern = loadImage("spiral2.png");
    break;      

   case 12:
   hueCycleable = true;
    sourcePattern = loadImage("spiral3.png");
    break;  

   case 13:
    sourcePattern = loadImage("spiral4.png");
    break;  

   case 14:
   hueCycleable = true;
    sourcePattern = loadImage("spiral5.png");
    break;

   case 15:
    sourcePattern = loadImage("acm.png");
    break;    
  
  }

  imgSelected = true;

  }  

}

void init_text() {
    font = createFont("Munro", 10);
    textFont(font);
}
