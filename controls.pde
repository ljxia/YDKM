import controlP5.*;

                    
/*ControlP5 controlHome;
String textUsername = "";
Textfield usernameField;        */


ControlP5 controlP5;
controlP5.Toggle buttonPlay;
controlP5.Toggle buttonRecord; 
controlP5.Toggle buttonPlayModified;

Boolean recording = false;
Boolean playing = false;

int lowPassFilterSliderValue = 100;

ControllerSprite recordSprite;
ControllerSprite stopSprite;
ControllerSprite playSprite;
ControllerSprite pauseSprite;
ControllerSprite shareSprite;

controlP5.Button recordButton;
controlP5.Button playButton;
controlP5.Button shareButton; 

ArrayList<Slider> allSliders;

void setupControls()
{                          
  /*controlHome = new ControlP5(this);
  controlHome.setAutoDraw(false);
  controlHome.setColorActive(color(187,0,0));
  controlHome.setColorBackground(color(230));
  controlHome.setColorForeground(color(200,0,0));
  //controlHome.setColorLabel(color(230));
  
  
  usernameField = controlHome.addTextfield("username",60,700,300,20);
  usernameField.setFocus(true); */
  
  controlP5 = new ControlP5(this);
  //controlP5.setAutoInitialization(true);
  
  controlP5.setAutoDraw(false);
  controlP5.setColorActive(color(187,0,0));
  controlP5.setColorBackground(color(230));
  controlP5.setColorForeground(color(200,0,0));
  controlP5.setColorLabel(color(230));
  
  recordSprite = new ControllerSprite(controlP5,loadImage("button_record.png"),200,60);
  recordSprite.setMask(loadImage("button_record_mask.png"));
  recordSprite.enableMask();
  
  stopSprite = new ControllerSprite(controlP5,loadImage("button_stop.png"),200,60);
  stopSprite.setMask(loadImage("button_stop_mask.png"));
  stopSprite.enableMask(); 
  
  playSprite = new ControllerSprite(controlP5,loadImage("button_play.png"),200,60);
  playSprite.setMask(loadImage("button_play_mask.png"));
  playSprite.enableMask();

  pauseSprite = new ControllerSprite(controlP5,loadImage("button_pause.png"),200,60);
  pauseSprite.setMask(loadImage("button_pause_mask.png"));
  pauseSprite.enableMask();
  
  shareSprite = new ControllerSprite(controlP5,loadImage("button_share.png"),200,60);
  shareSprite.setMask(loadImage("button_share_mask.png"));
  shareSprite.enableMask();
    
  recordButton = controlP5.addButton("record",1000,60, 510,200,60);    //1020
  recordButton.setSprite(recordSprite);
  
  playButton = controlP5.addButton("playpause",2000,60, 565,200,60);
  playButton.setSprite(playSprite);
  
  shareButton = controlP5.addButton("share",3000,60, 620,200,60);
  shareButton.setSprite(shareSprite);
  shareButton.hide();
  
  
  allSliders = new ArrayList<Slider>();
  
  for (int i = 0; i < BAND_NUM / 4; i++) {
    Slider slider = controlP5.addSlider("EQ" + i,0.95,7,1, 560 + 20 * i,539,15,100);
    slider.setId(100 + i);
    slider.setValueLabel("");
    slider.setColorValueLabel(color(230));
    slider.hide();
    allSliders.add(slider);
  }
}       

public void record() {
  recordScreen.record();
  if (!recording)
  {
    recordButton.setSprite(recordSprite);
    playButton.show();
    shareButton.show();
  }
  else
  {
    recordButton.setSprite(stopSprite);
    playButton.hide();
    shareButton.hide();
  }   
}

public void playpause() {
  recordScreen.toggleAll(); 
  if (playing)
  {
    playButton.setSprite(pauseSprite);
    recordButton.hide();
    shareButton.hide();
  }
  else
  {
    playButton.setSprite(playSprite);
    recordButton.show();
    shareButton.show();
  }                                    
  
  for (int i = 0; i<allSliders.size(); i++){
    if (playing)
    {
       allSliders.get(i).show();
    }
    else
    {
      allSliders.get(i).hide();
    }
  }
  
  //recordScreen.toggleChannel();
} 

public void share()
{
  recordScreen.toggleIntro();
} 

public void play_modified() {
  //recordScreen.play_modified();
}  

public void muteNormal()
{
  recordScreen.muteNormal();
}

public void muteMod()
{
  recordScreen.muteMod();
}   

// void lowPassFilterSliderValue(float sliderValue) {
//   float cutoff = sliderValue;
//   lpf.setFreq(cutoff);
//   lpf.printCoeff();
// }  

void controlEvent(ControlEvent theEvent) {
  //println(theEvent.controller().id());
  
  if (theEvent.controller().id() >= 100 && theEvent.controller().id() < 200)
  {
    recordScreen.bde.setBandScale(theEvent.controller().id() - 100, theEvent.controller().value());
  }
  
}

void mouseMoved()
{
  // map the mouse position to the range [60, 2000], an arbitrary range of cutoff frequencies
  
} 

void mouseDragged()
{
  /*if (wavethreads.size() > 0)
  {
    wavethreads.get(0).origin.set(new Vec2D(mouseX, mouseY));
    
  }*/
}  

void mousePressed()
{
  if (helpScreen.active)
  {
    helpScreen.dismiss();
  }
}

void keyPressed()
{
  if (homeScreen != null && homeScreen.active)
  {
    if (key >= 'A' && key <= 'Z')
    {
      key = char(key + 97 - 65);
    }
    
    if ((key >= 'a' && key <= 'z') || (key >= '0' && key <= '9') || key == ' ' || key == '.')
    {
      homeScreen.username = homeScreen.username + key;
    }
    else if (key == BACKSPACE || key == DELETE)
    {
      if (homeScreen.username.length() > 0)
      {
         homeScreen.username = homeScreen.username.substring(0, homeScreen.username.length() - 1);
      }
    }
    else if (key == ENTER)
    {
      if (homeScreen.username.length() > 0)
      {
        homeScreen.dismiss();
      }
    }
  }
  else if (recordScreen != null && recordScreen.active)
  {                                                   
    if (key == ' ')
    {
       playpause();
    }
    if (key == 'h' || key == 'H')
    {
      if (helpScreen.active)
      {
        helpScreen.dismiss();
      }
      else
      {
        helpScreen.activate();
      }
      
    }
  }
  
  /*if (false)
  {
     if (key == ' ')
    {
      //recordScreen.toggleAll();
    }

    else if (key == 't')
    {
      recordScreen.toggleChannel();    
    }

    else if (key == 's')
    {
      setting = recordScreen.bde.toString();
    }
    else if (key == 'l')
    {
      recordScreen.bde.fromString(setting);
      recordScreen.bde.updateController(controlP5);
    }
    else if (key == 'r')
    {
      recordScreen.record();
    }
    else if (key == 'i')
    {
      recordScreen.toggleIntro();
    } 
  }*/
  
}

