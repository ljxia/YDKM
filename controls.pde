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
  
  controlP5.setAutoDraw(true);
  controlP5.setColorActive(color(255,50,50));
  controlP5.setColorBackground(color(200));
  controlP5.setColorForeground(color(255,180,180));
  controlP5.setColorLabel(color(30));
  
  buttonRecord = controlP5.addToggle("record",20,20,60,18);
  buttonPlay = controlP5.addToggle("play",20 + 80,20,60,18);
  buttonPlayModified = controlP5.addToggle("play_modified",20 + width/2,20,60,18);
  sliderLowPassFilter = controlP5.addSlider("lowPassFilterSliderValue",60,2000,1000,20 + width/2,200,100,10); 
  
  sliderLowPassFilter.setLabel("Low Pass Filter");
}       

public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.controller().name()); 
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

