import controlP5.*;

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

controlP5.Button recordButton;
controlP5.Button playButton; 

ArrayList<Slider> allSliders;

void setupControls()
{
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
    
  recordButton = controlP5.addButton("record",1000,1020, 520,200,60);
  recordButton.setSprite(recordSprite);
  
  playButton = controlP5.addButton("playpause",2000,1020, 565,200,60);
  playButton.setSprite(playSprite);
  
  
    
  
  //buttonRecord = controlP5.addToggle("record",20,20,60,18);
  //buttonPlay = controlP5.addToggle("play",20 + 80,20,60,18);
  //buttonPlayModified = controlP5.addToggle("play_modified",20 + width/2,20,60,18);
  //sliderLowPassFilter = controlP5.addSlider("lowPassFilterSliderValue",60,2000,1000,500 + width/2,20,100,10); 
  
  
  //controlP5.addToggle("muteNormal",false,20 + 80 + 80,20,18,18);
  //controlP5.addToggle("muteMod",false,width/2 + 20 + 80,20,18,18);
  
  //sliderLowPassFilter.setLabel("Low Pass Filter");  
  
  allSliders = new ArrayList<Slider>();
  
  for (int i = 0; i < BAND_NUM / 4; i++) {
    Slider slider = controlP5.addSlider("EQ" + i,0.9,7,1, 560 + 20 * i,520,15,100);
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
  }
  else
  {
    recordButton.setSprite(stopSprite);
  }   
}

public void playpause() {
  recordScreen.toggleAll(); 
  if (playing)
  {
    playButton.setSprite(pauseSprite);
  }
  else
  {
    playButton.setSprite(playSprite);
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

void keyPressed()
{
  if (key == ' ')
  {
    recordScreen.toggleAll();
  }
  
  else if (key == 't')
  {
    recordScreen.toggleChannel();    
  }
  
  else if (key == '[')
  {
    /*for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).shapeInterpolator.set(wavethreads.get(i).shapeInterpolator.get() *0.5);
    } */
  }
  
  else if (key == ']')
  {
    /*for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).shapeInterpolator.set(wavethreads.get(i).shapeInterpolator.get() *2);
    }*/
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
}

