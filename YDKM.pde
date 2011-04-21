import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;

// audio 
Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioPlayer player;
AudioPlayer playerMod;  
FFT fft;
FFT fftMod;
LowPassFS lpf;
BoneConductedEffect bde;
int BAND_NUM = 30;

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
  bde = new BoneConductedEffect(player.bufferSize(), player.sampleRate()); 
  fft = new FFT(player.bufferSize(), player.sampleRate()); 
  fftMod = new FFT(playerMod.bufferSize(), playerMod.sampleRate());    
  
  // fft.logAverages(20,2);
  // fftMod.logAverages(20,2);  
  
  fft.linAverages(BAND_NUM);
  fftMod.linAverages(BAND_NUM);
}            

void draw()
{
  background(230);
  
    
  
  if (player != null && player.isPlaying())
  {
     stroke(30);
     drawAudioSource(player, 20,60, width / 2 - 40, 80);
     
     
     fft.forward(player.mix); 
     drawFFT(fft,      20,           260, width / 2 - 40, 80);
  }
  else
  {
     stroke(255,0,0);
     drawAudioSource(in, 20,60, width / 2 - 40, 80);
  } 
  
  if (playerMod != null && playerMod.isPlaying())
  {
     stroke(30);
     drawAudioSource(playerMod, 20 + width/2,60, width / 2 - 40, 80);
     
     fftMod.forward(playerMod.mix); 
     
     
     
     
     fftMod.scaleBand(0,0.0);
     fftMod.scaleBand(1,0.0);
     fftMod.scaleBand(2,0.0);
     // fftMod.scaleBand(5,0.01);
     // fftMod.scaleBand(6,0.01);
     // fftMod.scaleBand(7,0.01);
     // fftMod.scaleBand(8,0.01);
     // fftMod.scaleBand(9,0.01);
     // fftMod.scaleBand(10,0.01);
     // fftMod.scaleBand(11,0.01);
     // fftMod.scaleBand(12,0.01);
     // fftMod.scaleBand(13,0.01);  
     fftMod.inverse(playerMod.left);
     fftMod.inverse(playerMod.right);
     fftMod.inverse(playerMod.mix);
     
     drawFFT(fftMod,   20 + width/2, 260, width / 2 - 40, 80);
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

void drawFFT(FFT thisfft, int x, int y, int width, int height)
{     
  pushMatrix();
  translate(x,y);
  float bandwidth = width/thisfft.avgSize();
  for(int i = 0; i < thisfft.avgSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    noStroke();
    fill(30,255);
    rect(map(i,0,thisfft.avgSize(),0,width), height - thisfft.getAvg(i)*4, bandwidth, thisfft.getAvg(i)*4);
    
    //println(thisfft.getBand(i)*400000);
  }   
  
  popMatrix();
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
