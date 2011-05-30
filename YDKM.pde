import processing.opengl.*;
//audio
import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;
//physics
import toxi.geom.*;
import toxi.physics2d.*;

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
int BAND_NUM = 80;

VerletPhysics2D physics;
ArrayList<WaveThread2D> wavethreads;
ArrayList<WaveThread2D> corethreads;

String setting;


void setup()
{
  size(1920,1080, OPENGL);
  hint(DISABLE_OPENGL_2X_SMOOTH);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(30); 
  smooth(); 
  setting = "";
  
  physics = new VerletPhysics2D(null,50, 0, 1);
  physics.setGravity(new Vec2D(0,0));
  physics.setWorldBounds(new Rect(0,0,width,height));
  
  wavethreads = new ArrayList<WaveThread2D>();
  corethreads = new ArrayList<WaveThread2D>();
  
  for (int i = 0; i<20; i++){
    wavethreads.add(new WaveThread2D(physics, 15, new VerletParticle2D(width/2,height-400), 0.4));  // + (i - 3) * 100  
    corethreads.add(new WaveThread2D(physics, 20, new VerletParticle2D(width/2,height-400), 0.99));
  } 
  
  setupControls();
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024);
  recorder = minim.createRecorder(in, "ydkm.wav", true);
  String filename = "ydkm.wav";//"ydkm.wav"
  player = minim.loadFile(filename, 1024);
  playerMod = minim.loadFile(filename, 1024);
  lpf = new LowPassFS(100, in.sampleRate());
  bde = new BoneConductedEffect(player.bufferSize(), player.sampleRate()); 
  fft = new FFT(player.bufferSize(), player.sampleRate()); 
  fftMod = new FFT(playerMod.bufferSize(), playerMod.sampleRate());    
  
  // fft.logAverages(20,2);
  // fftMod.logAverages(20,2);  
  
  fft.linAverages(BAND_NUM);
  fftMod.linAverages(BAND_NUM);
}

void update()
{
  //println(in.left.level());
  physics.update(); 
  for (int i = 0; i<wavethreads.size(); i++){
    wavethreads.get(i).update();
  }
  for (int i = 0; i<corethreads.size(); i++){
    corethreads.get(i).shapeInterpolator.set(player.left.level() * 20 + 1);
    corethreads.get(i).update();
  }
}            

void draw()
{
  update();
  
  
  background(230);
  /*noStroke();
  fill(255,50);
  rect(0,0,width, height); */
  
  controlP5.draw(); 
  
  
  if (player != null && player.isPlaying())
  {
     stroke(30);
     drawAudioSource(player, 20,60, width / 2 - 40, 80);
     
     
     fft.forward(player.mix);
     
     noStroke();
     fill(0,0,220,130); 
     drawFFT(fft,      20, 260, width - 40, 80);
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
     
     noStroke();
     fill(220,0,0,150); 
     
     drawFFT(fftMod,   20, 260, width - 40, 80);
  }

  for (int i = 0; i<wavethreads.size(); i++){
    //wavethreads.get(i).draw();
  }
  for (int i = 0; i<corethreads.size(); i++){
    corethreads.get(i).draw();
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
