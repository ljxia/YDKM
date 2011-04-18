import ddf.minim.*;
import ddf.minim.effects.*;

// audio 
Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioPlayer player;
//AudioPlayer playerMod;
LowPassFS lpf;

void setup()
{
  size(800,600);
  frameRate(30); 
  smooth();
  
  setupControls();
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024);
  recorder = minim.createRecorder(in, "ydkm.wav", true);
  lpf = new LowPassFS(100, in.sampleRate());
}            

void draw()
{
  background(230);
  
  
  if (player != null && playing)
  {
     stroke(30);
     drawAudioSource(player, 20,60, width - 40, 100);
  }
  else
  {
     stroke(255,0,0);
     drawAudioSource(in, 20,60, width - 40, 100);
  }
  
}

void drawAudioSource(ddf.minim.AudioSource source, int x, int y, int width, int height)
{
  pushMatrix();
  translate(x,y);
  int qHeight = height/4;
  for(int i = 0; i < source.left.size()-1; i++)
  {
    line( map(i,0,source.left.size(),0,width), 
          qHeight + source.left.get(i)*qHeight, 
          map(i+1,0,source.left.size(),0,width), 
          qHeight + source.left.get(i+1)*qHeight);
    line( map(i,0,source.left.size(),0,width), 
          qHeight * 3 + source.right.get(i)*qHeight , 
          map(i+1,0,source.left.size(),0,width), 
          qHeight * 3 + source.right.get(i+1)*qHeight);
  }
  popMatrix();  
}

void lowPassFilterSliderValue(float sliderValue) {
  float cutoff = sliderValue;
  lpf.setFreq(cutoff);
  lpf.printCoeff();
}

void mouseMoved()
{
  // map the mouse position to the range [60, 2000], an arbitrary range of cutoff frequencies
  
} 

void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  if ( player != null )
  {
    player.close();
  }
  minim.stop();
  
  super.stop();
}