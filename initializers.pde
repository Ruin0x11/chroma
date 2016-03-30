String[] tileableImages = new String[]{
  "effect_img_1.png",
  "effect_img_2.png",
  "effect_img_3.png",
  "effect_img_4.png",
  "effect_img_5.png",
  "effect_img_6.png",
  "effect_img_7.png",
  "effect_img_8.png",
  "effect_img_9.png",
  "effect_img_10.png",
};

String[] centeredImages = new String[]{
  "effect_img_1.png",
  "effect_img_2.png",
  "effect_img_3.png",
  "effect_img_4.png",
  "effect_img_5.png",
  "effect_img_6.png",
  "effect_img_7.png",
  "effect_img_8.png",
  "effect_img_9.png",
  "effect_img_10.png",
  "spiral1.png",
  "spiral2.png",
  "spiral3.png",
  "spiral4.png",
  "spiral5.png",
  "acm.png",
};

String[] hueCycleableImages = new String[]{
  "effect_img_2.png",
  "effect_img_6.png",
  "effect_img_7.png",
  "effect_img_10.png",
  "spiral3.png",
  "spiral5.png",
};

void select_randomTileableImg() {
  
  if (!imgSelected) {
  
    hueCycleable = false;
    
    int randSelect = int(random(0, tileableImages.length));
  
    sourcePattern = loadImage(tileableImages[randSelect]);
  
    for(int i = 0; i < hueCycleableImages.length; i++) {
      if(hueCycleableImages[i].equals(tileableImages[randSelect])) {
        hueCycleable = true;
      }
    }

    imgSelected = true;

  }
}

void select_randomCenteredImg() {

  if (!imgSelected) {

    hueCycleable = false;
  
    int randSelect = int(random(0,centeredImages.length));
  
    sourcePattern = loadImage(centeredImages[randSelect]);
  
    for(int i = 0; i < hueCycleableImages.length; i++) {
      if(hueCycleableImages[i].equals(centeredImages[randSelect])) {
        hueCycleable = true;
      }
    }

    imgSelected = true;

  }  
}
