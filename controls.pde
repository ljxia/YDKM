import controlP5.*;

ControlP5 controlP5;
controlP5.Toggle buttonPlay;
controlP5.Toggle buttonRecord; 
controlP5.Toggle buttonPlayModified;

Slider sliderLowPassFilter;
Boolean recording = false;
Boolean playing = false;

int lowPassFilterSliderValue = 100;

void setupControls()
{
  controlP5 = new ControlP5(this);
  //controlP5.setAutoInitialization(true);
  
  controlP5.setAutoDraw(false);
  controlP5.setColorActive(color(255,50,50));
  controlP5.setColorBackground(color(200));
  controlP5.setColorForeground(color(255,180,180));
  controlP5.setColorLabel(color(30));
  
  buttonRecord = controlP5.addToggle("record",20,20,60,18);
  buttonPlay = controlP5.addToggle("play",20 + 80,20,60,18);
  buttonPlayModified = controlP5.addToggle("play_modified",20 + width/2,20,60,18);
  //sliderLowPassFilter = controlP5.addSlider("lowPassFilterSliderValue",60,2000,1000,500 + width/2,20,100,10); 
  
  
  controlP5.addToggle("muteNormal",false,20 + 80 + 80,20,18,18);
  controlP5.addToggle("muteMod",false,width/2 + 20 + 80,20,18,18);
  
  //sliderLowPassFilter.setLabel("Low Pass Filter");
  for (int i = 0; i < BAND_NUM; i++) {
    controlP5.addSlider("EQ" + i,0,7,1, 20 + i * (width - 40) / BAND_NUM,400,15,200).setId(100 + i);
  }
}       

public void record() { 
  println("Record");
  
  if ( recorder.isRecording() ) 
  {
    recorder.endRecord();
    buttonRecord.setLabel("Record");
    recording = false;
    
    if ( player != null )
    {
        player.close();
    }
    if ( playerMod != null )
    {
        playerMod.close();
    }
    player = recorder.save();
    playerMod = minim.loadFile("ydkm.wav", 1024);
  }
  else 
  {
    recorder = minim.createRecorder(in, "ydkm.wav", true);
    recorder.beginRecord();
    buttonRecord.setLabel("Stop");
    recording = true;
  }  
}

public void play() {
  println("Play");
  if ( player != null )
  {
    if (playing)
    {
       buttonPlay.setLabel("Play");
       playing = false; 

       player.pause();
    }
    else
    {
      buttonPlay.setLabel("Stop");
      playing = true;
      player.loop();
      
      //player.play();
    }    
  }
}  

public void play_modified() {
  if (playerMod != null)
  {
     if (playerMod.isPlaying())
     {
       buttonPlayModified.setLabel("Play");
       playerMod.pause(); 
     }
     else
     {
        buttonPlayModified.setLabel("Stop");
        playerMod.pause();
        playerMod.loop(); 
        //playerMod.addEffect(lpf);
        playerMod.addEffect(bde);
      }
  }
}  

public void muteNormal()
{
  if (player != null)
  {
    if (player.isMuted())
    {
      player.unmute();
    }                 
    else
    {
      player.mute();
    }
  }
}

public void muteMod()
{
  if (playerMod != null)
  {
    if (playerMod.isMuted())
    {
      playerMod.unmute();
    }                 
    else
    {
      playerMod.mute();
    }
  }
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
    bde.setBandScale(theEvent.controller().id() - 100, theEvent.controller().value());
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
    if (player != null && playerMod != null)
    {
      if (player.isPlaying() && playerMod.isPlaying())
      {
        player.pause();
        playerMod.pause();
      }
      else
      {
        player.loop();
        playerMod.loop();
        playerMod.addEffect(bde);
      }     
    }
  }
  
  else if (key == 't')
  {
    if (player != null && playerMod != null)
    {
      if (player.isPlaying() && playerMod.isPlaying())
      {
        if (player.isMuted())
        {
          player.unmute();
          playerMod.mute();
        }
        else
        {
          player.mute();
          playerMod.unmute();
        }
      }     
    }    
  }
  
  else if (key == '[')
  {
    for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).shapeInterpolator.set(wavethreads.get(i).shapeInterpolator.get() *0.5);
    }
  }
  
  else if (key == ']')
  {
    for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).shapeInterpolator.set(wavethreads.get(i).shapeInterpolator.get() *2);
    }
  }
}

