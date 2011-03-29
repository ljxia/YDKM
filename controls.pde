import controlP5.*;

ControlP5 controlP5;
controlP5.Toggle buttonPlay;
controlP5.Toggle buttonRecord;

Boolean recording = false;
Boolean playing = false;

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
  buttonPlay = controlP5.addToggle("play",100,20,60,18);
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
    player = recorder.save();
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
      player.addEffect(lpf);
      //player.play();
    }    
  }

}