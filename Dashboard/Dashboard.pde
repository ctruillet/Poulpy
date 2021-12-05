PImage img_admin;
PFont titleFont;
PFont generalFont;

float image_sx;
float image_sy;
float posImg_x;
float posImg_y;
float posBDE_x;
float posBDE_y;
float posSRI_x;
float posSRI_y;
float posSTRI_x;
float posSTRI_y;
float posGC_x;
float posGC_y;
float posDir_x;
float posDir_y;

boolean isInSecretariatGC;
boolean isInSecretariatSRI;
boolean isInSecretariatSTRI;
boolean isInSecretariat;
boolean isInDirection;

public void setup(){
  size(displayWidth,displayHeight);
  titleFont = loadFont("Cambria-Bold-80.vlw");
  generalFont = loadFont("Candara-40.vlw");
  img_admin = loadImage("AdminU3.png");
}

public void draw(){
  
  init();
  
  posBDE_x = posImg_x * 6.5/4;
  posBDE_y = posImg_y * 17/11;  
  posSRI_x = posImg_x * 5.42/4;
  posSRI_y = posImg_y * 17/11;
  posGC_x = posImg_x * 4.85/4;
  posGC_y = posImg_y * 17/11;
  posSTRI_x = posImg_x * 4.92/4;
  posSTRI_y = posImg_y * 13.72;
  posDir_x = posImg_x *11.7/11;
  posDir_y = posImg_y * 7.65;  
  
  if(mouseX >= posBDE_x && mouseX <= posBDE_x+150 && mouseY >= posBDE_y && mouseY <= posBDE_y + 280){
    showBDE();
  }
  
  isInDirection = mouseX >= posDir_x && mouseX <= posDir_x+280 && mouseY >= posDir_y && mouseY <= posDir_y + 298;
  isInSecretariatGC = mouseX >= posGC_x && mouseX <= posGC_x+126 && mouseY >= posGC_y && mouseY <= posGC_y + 285;
  isInSecretariatSRI = mouseX >= posSRI_x && mouseX <= posSRI_x+120 && mouseY >= posSRI_y && mouseY <= posSRI_y + 285;
  isInSecretariatSTRI = mouseX >= posSTRI_x && mouseX <= posSTRI_x+140 && mouseY >= posSTRI_y && mouseY <= posSTRI_y + 298;
  isInSecretariat = isInSecretariatGC || isInSecretariatSRI || isInSecretariatSTRI;
  
  if(isInDirection || isInSecretariat){
    showAdmin();
  }
  
}

void init(){
  image_sx = displayWidth*1/2;
  image_sy = image_sx * (832/798);
  posImg_x = displayWidth/1.4-image_sx/2;
  posImg_y = displayHeight/2-image_sy/2;
  background(color(221,221,221));
  image(img_admin,posImg_x,posImg_y,image_sx,image_sy);
  textAlign(LEFT);
  fill(color(0));
  textFont(titleFont,70);
  text("Info Administration U3",20,100);
}

void showBDE(){
  fill(color(255,0,0,50));
  rect(posBDE_x,posBDE_y,150,280);
  fill(color(0,0,0,30));
  rect(40,displayHeight/6,2*displayWidth/5,2*displayHeight/3);
  fill(color(0));
  textAlign(LEFT);
  textFont(generalFont,50);
  text("Info BDE :", 60, 270);
  textFont(generalFont,40);
  text(" - Température : ----", 90,370);
  text(" - Consommation électrique : ----", 90,470);
  text(" - Détecteur de fumée : ----", 90,570);
  text(" - Micro-onde 1 : ----", 90,670);
  text(" - Micro-onde 2 : ----", 90,770);
}

void showAdmin(){
  fill(color(255,0,0,50));
  rect(posGC_x,posGC_y,126,285);
  rect(posSRI_x,posSRI_y,120,285);
  rect(posSTRI_x,posSTRI_y,140,153);
  rect(posDir_x, posDir_y,280,298);
  fill(color(0,0,0,30));
  rect(40,displayHeight/6,2*displayWidth/5,3.1*displayHeight/4);
  fill(color(0));
  textAlign(LEFT);
  textFont(generalFont,50);
  text("Info Admin :", 60, 270);
  textFont(generalFont,40);
  text(" - Température : ----", 90,370);
  text(" - Consommation électrique : ----", 90,470);
  text(" - Détecteur de fumée : ----", 90,570);
  text(" - Secrétariat SRI : ----", 90,670);
  text(" - Secrétariat GC : ----", 90,770);
  text(" - Secrétariat STRI : ----", 90,870);
  text(" - Direction : ----", 90,970);
}
