import ddf.minim.*;
import ddf.minim.effects.*;

// audio 
Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioPlayer player;
AudioPlayer playerMod;
LowPassFS lpf;
BoneConductedEffect bde;

void setup()
{
  size(1280,900);
  frameRate(30); 
  smooth();
  
  setupControls();
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024);
  recorder = minim.createRecorder(in, "ydkm.wav", true);
  player = minim.loadFile("ydkm.wav", 1024);
  playerMod = minim.loadFile("ydkm.wav", 1024);
  lpf = new LowPassFS(100, in.sampleRate());
  bde = new BoneConductedEffect();
}            

void draw()
{
  background(230);
  
  
  if (player != null && player.isPlaying())
  {
     stroke(30);
     drawAudioSource(player, 20,60, width / 2 - 40, 80);
  }
  else
  {
     stroke(255,0,0);
     drawAudioSource(in, 20,60, width / 2 - 40, 80);
  } 
  
  if (playerMod != null)
  {
     stroke(30);
     drawAudioSource(playerMod, 20 + width/2,60, width - 40, 80);
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
  if ( playerMod != null )
  {
    playerMod.close();
  }
  minim.stop();
  
  super.stop();
} 

void keyPressed()
{
  if (key == 'p')
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
}