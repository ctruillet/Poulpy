PImage img_admin;
PImage img_weather;
PFont titleFont;
PFont generalFont;

float image_sx;
float image_sy;
float posImg_x;
float posImg_y;
float posImgW_x;
float posImgW_y;
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

JSONObject data_json;

FSM fsm;

String lastTimeUpdate = "";

public void setup(){
  size(displayWidth,displayHeight);
  titleFont = loadFont("Cambria-Bold-80.vlw");
  generalFont = loadFont("Candara-40.vlw");
  img_admin = loadImage("AdminU3.png");
  
  try{
    data_json = loadJSONObject("http://localhost:3000/");
  }catch(Exception e){
    data_json = loadJSONObject("data.json");
  }

  img_weather = loadImage("meteo.png");
  fsm = FSM.METEO;
  
  new Thread(new Runnable() { 
            public void run() {
                while (true){
                    try {
                        Thread.sleep(10 * 60 * 1000);
                        try{
                          data_json = loadJSONObject("http://localhost:3000/");
                        }catch(Exception e){
                          data_json = loadJSONObject("data.json");
                        }
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
          });
    lastTimeUpdate = "Derniere Mise à Jour : " + hour() + ":" + minute();
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
  
  
  
  isInDirection = mouseX >= posDir_x && mouseX <= posDir_x+280 && mouseY >= posDir_y && mouseY <= posDir_y + 298;
  isInSecretariatGC = mouseX >= posGC_x && mouseX <= posGC_x+126 && mouseY >= posGC_y && mouseY <= posGC_y + 285;
  isInSecretariatSRI = mouseX >= posSRI_x && mouseX <= posSRI_x+120 && mouseY >= posSRI_y && mouseY <= posSRI_y + 285;
  isInSecretariatSTRI = mouseX >= posSTRI_x && mouseX <= posSTRI_x+140 && mouseY >= posSTRI_y && mouseY <= posSTRI_y + 298;
  isInSecretariat = isInSecretariatGC || isInSecretariatSRI || isInSecretariatSTRI;
  
  if(mouseX >= posBDE_x && mouseX <= posBDE_x+150 && mouseY >= posBDE_y && mouseY <= posBDE_y + 280){
    showBDE();
  }else if(isInDirection || isInSecretariat){
    showAdmin();
  }else if(mouseX >= posImgW_x && mouseX <= posImgW_x+90 && mouseY >= posImgW_y && mouseY <= posImg_y + 90){
    showWeather();
  }else{
    switch(fsm){
      case METEO:
        showWeather();
        break;
      
      case ADMIN:
        showAdmin();
        break;
        
      case BDE:
        showBDE();
        break;
        
      default:
        break;
    }
  }
  
  textFont(titleFont,20);
  text(lastTimeUpdate,10,1020);
  
}

void init(){
  image_sx = displayWidth*1/2;
  image_sy = image_sx * (832/798);
  posImg_x = displayWidth/1.4-image_sx/2;
  posImg_y = displayHeight/2-image_sy/2;
  posImgW_x = displayWidth-95;
  posImgW_y = 5;
  background(color(221,221,221));
  image(img_admin,posImg_x,posImg_y,image_sx,image_sy);
  textAlign(LEFT);
  fill(color(0));
  textFont(titleFont,70);
  text("Info Administration U3",20,100);
  image(img_weather,posImgW_x,posImgW_y,90,90);
}


void mouseClicked(){
  updateData();
  lastTimeUpdate = "Derniere Mise à Jour : " + hour() + ":" + minute();
  
  if(mouseX >= posBDE_x && mouseX <= posBDE_x+150 && mouseY >= posBDE_y && mouseY <= posBDE_y + 280){
    fsm = FSM.BDE;
  }
  
  isInDirection = mouseX >= posDir_x && mouseX <= posDir_x+280 && mouseY >= posDir_y && mouseY <= posDir_y + 298;
  isInSecretariatGC = mouseX >= posGC_x && mouseX <= posGC_x+126 && mouseY >= posGC_y && mouseY <= posGC_y + 285;
  isInSecretariatSRI = mouseX >= posSRI_x && mouseX <= posSRI_x+120 && mouseY >= posSRI_y && mouseY <= posSRI_y + 285;
  isInSecretariatSTRI = mouseX >= posSTRI_x && mouseX <= posSTRI_x+140 && mouseY >= posSTRI_y && mouseY <= posSTRI_y + 298;
  isInSecretariat = isInSecretariatGC || isInSecretariatSRI || isInSecretariatSTRI;
  
  if(isInDirection || isInSecretariat){
    fsm = FSM.ADMIN;
  }
  
  if(mouseX >= posImgW_x && mouseX <= posImgW_x+90 && mouseY >= posImgW_y && mouseY <= posImg_y + 90){
    fsm = FSM.METEO;
  }
}

void showBDE(){
  JSONObject data_bde = data_json.getJSONObject("api").getJSONObject("BDE");
  JSONObject data_bde_conso_elec = data_bde.getJSONObject("conso_elec");
  float conso_elec_bde = data_bde_conso_elec.getFloat("consumption");
  JSONObject data_bde_micronde = data_bde.getJSONObject("micro_onde_0");
  int nb_util_mo_bde = data_bde_micronde.getInt("number_use");
  boolean is_used_mo_bde = data_bde_micronde.getBoolean("is_used");
  JSONObject data_bde_micronde_2 = data_bde.getJSONObject("micro_onde_1");
  int nb_util_mo_bde_2 = data_bde_micronde_2.getInt("number_use");
  boolean is_used_mo_bde_2 = data_bde_micronde_2.getBoolean("is_used");
  float temp_bde = data_bde.getFloat("temperature");
  float hum_bde = data_bde.getFloat("humidity");
  JSONObject data_bde_smoke = data_bde.getJSONObject("detecteur_fumee");
  boolean smoke_detected_bde = data_bde_smoke.getBoolean("smoke");
  
  fill(color(255,0,0,70));
  rect(posBDE_x,posBDE_y,150,280);
  fill(color(0,0,0,30));
  rect(40,displayHeight/6,2*displayWidth/5,2.2*displayHeight/3);
  fill(color(0));
  textAlign(LEFT);
  textFont(generalFont,50);
  text("Info BDE :", 60, 270);
  textFont(generalFont,30);
  text(" - Température : " + str(temp_bde) +" °C", 90,370);
  text(" - Humidité : " + str(hum_bde) + " %", 90,450);
  text(" - Consommation électrique : " + str(conso_elec_bde) + " W", 90,530);
  text(" - Fumée détectée : " + str(smoke_detected_bde), 90,610);
  text(" - Micro-onde 1 :", 90,690);
  text(" - Nombre d'utilisations : " + str(nb_util_mo_bde), 120,730);
  text(" - Est utilisé : " + str(is_used_mo_bde), 120,770);
  text(" - Micro-onde 2 :", 90,850);
  text(" - Nombre d'utilisations : " + str(nb_util_mo_bde_2), 120,890);
  text(" - Est utilisé : " + str(is_used_mo_bde_2), 120,930);
  
}

void showAdmin(){
  JSONObject data_admin = data_json.getJSONObject("api").getJSONObject("Admin");
  String temp_admin = data_admin.getJSONObject("thermometre").getString("temperature");
  float conso_elec_admin = data_admin.getJSONObject("conso_elec").getFloat("consumption");
  boolean smoke_detected_admin = data_admin.getJSONObject("detecteur_fumee").getBoolean("smoke");
  int nb_pers_SRI = data_admin.getJSONObject("SRI").getInt("nb_person");
  int nb_pers_GC = data_admin.getJSONObject("GCGEO").getInt("nb_person");
  int nb_pers_STRI = data_admin.getJSONObject("STRI").getInt("nb_person");
  int nb_pers_DIR = data_admin.getJSONObject("Direction").getInt("nb_person");
  fill(color(255,0,0,70));
  rect(posGC_x,posGC_y,126,285);
  rect(posSRI_x,posSRI_y,120,285);
  rect(posSTRI_x,posSTRI_y,140,153);
  rect(posDir_x, posDir_y,280,298);
  fill(color(0,0,0,30));
  rect(40,displayHeight/6,2*displayWidth/5,2.7*displayHeight/4);
  fill(color(0));
  textAlign(LEFT);
  textFont(generalFont,50);
  text("Info Admin :", 60, 270);
  textFont(generalFont,30);
  text(" - Température : " + temp_admin + " °C", 90,370);
  text(" - Consommation électrique : " + str(conso_elec_admin) + " W", 90,450);
  text(" - Fumée détectée : " + str(smoke_detected_admin), 90,530);
  text(" - Secrétariat SRI : " + str(nb_pers_SRI) + " pers.", 90,610);
  text(" - Secrétariat GCGEO : " + str(nb_pers_GC) + " pers.", 90,690);
  text(" - Secrétariat STRI : " + str(nb_pers_STRI) + " pers.", 90,770);
  text(" - Direction : " + str(nb_pers_DIR) + " pers.", 90,850);
}

void showWeather(){
  JSONObject data_weather = data_json.getJSONObject("api").getJSONObject("weather");
  float temp = data_weather.getFloat("temperature");
  float hum = data_weather.getFloat("humidity");
  float press = data_weather.getFloat("pressure");
  fill(color(255,0,0,50));
  rect(posImgW_x,posImgW_y,90,90);
  fill(color(0,0,0,30));
  rect(40,displayHeight/6,2*displayWidth/5,1.15*displayHeight/3);
  fill(color(0));
  textAlign(LEFT);
  textFont(generalFont,50);
  text("Météo :", 60, 270);
  textFont(generalFont,30);
  text(" - Température : " + str(temp) + " °C", 90,370);
  text(" - Humidité : " + str(hum) + " %", 90,450);
  text(" - Pression : " + str(press) + " Pa", 90,530);
}

void updateData(){
  try{
    data_json = loadJSONObject("http://localhost:3000/");
  }catch(Exception e){
    data_json = loadJSONObject("data.json");
  }
}
