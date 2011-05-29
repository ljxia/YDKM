import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.effects.*; 
import ddf.minim.analysis.*; 
import toxi.geom.*; 
import toxi.physics2d.*; 
import ddf.minim.analysis.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class YDKM extends PApplet {

//audio



//physics



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
VerletParticle2D origin;
VerletParticle2D comet;
Vec2D lastComet;
VerletParticle2D attractor;
VerletSpring2D attractorSpring;
ArrayList<VerletParticle2D> chain;
ArrayList<Vec2D> trail;

public void setup()
{
  size(1920,1080);
  frameRate(30); 
  smooth(); 
  
  physics = new VerletPhysics2D(null,50, 0, 1);
  physics.setGravity(new Vec2D(0,0));
  physics.setWorldBounds(new Rect(0,0,width,height));
  origin = new VerletParticle2D(width/2,height-300);
  attractor = new VerletParticle2D(width/2,height-300);
  comet = new VerletParticle2D(width/2,height - 300- 100);
  physics.addParticle(origin);
  physics.addParticle(comet);
  physics.addParticle(attractor);
  origin.lock();
  
  attractorSpring = new VerletSpring2D(attractor,comet,3,2);
  physics.addSpring(new VerletSpring2D(origin,comet,15,0.02f));
  physics.addSpring(attractorSpring);
  
  trail = new ArrayList<Vec2D>();
  
  int chainlength = 50;
  chain = new ArrayList<VerletParticle2D>();
  chain.add(comet);
  VerletParticle2D node = null;
  
  
  for (int i = 0; i<chainlength; i++){
    node = new VerletParticle2D(comet);
    physics.addSpring(new VerletSpring2D(node,chain.get(chain.size() - 1),0.5f, 0.07f * (0.1f)));       // - i * 0.00005
    physics.addParticle(node);
    chain.add(node);          
    
    physics.addSpring(new VerletSpring2D(origin,node,60,0.0002f));
    physics.addSpring(new VerletSpring2D(attractor,node,60,0.0002f));
  }
  
  physics.addSpring(new VerletSpring2D(comet,node,30,0.0005f));
  
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

public void draw()
{
  background(230);
  /*noStroke();
  fill(255,50);
  rect(0,0,width, height); */
  
  controlP5.draw();
  
  //update physics
  if (frameCount % 5 == 0)//(mousePressed)//
  {
    attractor.set(origin.add(comet.sub(origin).normalize().rotate(PI/random(0.1f,3.8f)).scale(noise(frameCount) * 70 + 15)));  
    attractor.lock();
    attractorSpring.setStrength(noise(frameCount) * 3 + 0.5f);   
  }
  
  /*if (frameCount % 30 == 0)
  {
    for (int i = 1; i<=3; i++){
      VerletParticle2D middle = chain.get(i * int((chain.size() - 1) / 3));
      if (middle.isLocked())
      {
        middle.unlock();
      }                 
      else
      {
        middle.lock();
      }                    
    }
  }*/
  
  
  /*if (frameCount % 150 == 0)//(mousePressed)//
  {
    //origin.set(chain.get(int(random(chain.size() - 1))));
    origin.lock();  
  }
  else if (frameCount % 15 == 0)//(mousePressed)//
  {
    //origin.set(chain.get(int(random(chain.size() - 1))));
    origin.unlock();  
  }*/

  physics.update(); 
  if (lastComet != null)
  {    
    chain.get(1).set(lastComet);
  }
  lastComet = comet.copy();
  
  trail.add(lastComet.copy());
  if (trail.size() >  30)
  {
    trail.remove(0);
  }
  println(trail.get(trail.size() - 1).x + ", " + trail.get(trail.size() - 1).y);
  //println(trail.size());  
  
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
     
     drawFFT(fftMod,   20 + width/2, 260, width / 2 - 40, 80);
  }

  stroke(170);
  noFill();
  //line(origin.x ,origin.y,comet.x ,comet.y);
  
  stroke(170);
  noFill();
  //line(attractor.x ,attractor.y,comet.x ,comet.y);
  
  noStroke();                                  
  fill(0);
  //ellipse(origin.x ,origin.y,3,3);
  
  fill(255,0,0);
  //ellipse(comet.x ,comet.y,3,3); 
  
  fill(0,0,255);
  //ellipse(attractor.x ,attractor.y,3,3);
  
  pushMatrix();
  translate(origin.x,origin.y);
  //scale(3);
  int rep = 1;
  for (int j = 0; j <  rep; j++){

    fill(100, 30);

    beginShape();  
    //curveVertex(chain.get(1).x - origin.x ,chain.get(1).y - origin.y);
    for (int i = 1; i<chain.size(); i++){
      
      stroke(100, 180);
      //noStroke();
      //line(chain.get(i).x,chain.get(i).y,chain.get(i-1).x,chain.get(i-1).y);
      curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      
    } 
    //curveVertex(chain.get(0).x - origin.x,chain.get(0).y - origin.y);
    
    curveVertex(chain.get(1).x - origin.x ,chain.get(1).y - origin.y);
    
    endShape();


    rotate(PI/20);

    beginShape();
    //curveVertex(chain.get(1).x - origin.x ,chain.get(1).y - origin.y);
    //curveVertex(chain.get(0).x - origin.x,chain.get(0).y - origin.y);
    //curveVertex(chain.get(0).x - origin.x,chain.get(0).y - origin.y);
    fill(255,0,0, 30);
    for (int i = 1; i<chain.size(); i++){
      stroke(255,0,0, 180);
      //noStroke();
      
      //line(chain.get(i).x,chain.get(i).y,chain.get(i-1).x,chain.get(i-1).y);
      curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      /*noStroke(); 
      fill(255,255,0);
      ellipse(chain.get(i).x,chain.get(i).y,2,2); */ 
    }
    curveVertex(chain.get(1).x - origin.x ,chain.get(1).y - origin.y);
    endShape();                                      
    
    rotate(-PI/20); 
    

    
    
    rotate(TWO_PI/rep);
    
  }           
  
  
  popMatrix();          
  
  stroke(255,100,0, 180);
  fill(255,100,0, 130); 
  beginShape();
  for (int i = 1; i<trail.size(); i++){
    curveVertex(trail.get(i).x,trail.get(i).y);
  }
  endShape();
}

public void drawAudioSource(ddf.minim.AudioSource source, int x, int y, int width, int height)
{
  pushMatrix();
  translate(x,y);
  int qHeight = height/4;
  for(int i = 0; i <  source.left.size()-1; i++)
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

public void drawFFT(FFT thisfft, int x, int y, int width, int height)
{     
  pushMatrix();
  translate(x,y);
  float bandwidth = width/thisfft.avgSize();
  for(int i = 0; i <  thisfft.avgSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    noStroke();
    fill(30,255);
    rect(map(i,0,thisfft.avgSize(),0,width), height - thisfft.getAvg(i)*4, bandwidth, thisfft.getAvg(i)*4);
    
    //println(thisfft.getBand(i)*400000);
  }   
  
  popMatrix();
}



public void stop()
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


class BoneConductedEffect implements AudioEffect
{
  private FFT fft;
  private float bandScale[];

  public BoneConductedEffect(int bufferSize, float sampleRate)
  {
    this.fft = new FFT(bufferSize, sampleRate);
    this.fft.linAverages(BAND_NUM);  
    this.bandScale = new float[BAND_NUM];
    for (int i = 0; i<  BAND_NUM ; i++) 
    {
      this.bandScale[i] = 1;
    }
  } 
  
  public void setBandScale(int band, float scale)
  {
    if (band <  this.bandScale.length && band >= 0)
    {
      this.bandScale[band] = scale;
    }
  }

  public void process(float[] samp)
  {                   

    float[] mod = new float[samp.length];
    arraycopy(samp, mod);       

    this.fft.forward(mod);

    for (int i = 0; i <  this.fft.avgSize(); i++) 
    {
      this.fft.scaleBand(i,this.bandScale[i]);
    }
    
    this.fft.inverse(mod);

    arraycopy(mod, samp);

  }

  public void process(float[] left, float[] right)
  {
    process(left);
    process(right);
  }
}
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Toxiclibs example

// A soft pendulum (series of connected springs)

class Chain {

  // Chain properties
  float totalLength;  // How long
  int numPoints;      // How many points
  float strength;     // Strength of springs
  float radius;       // Radius of ball at tail

  // Let's keep an extra reference to the tail particle
  // This is just the last particle in the ArrayList
  VerletParticle2D tail;

  // Some variables for mouse dragging
  PVector offset = new PVector();
  boolean dragged = false;

  // Chain constructor
  Chain(float l, int n, float r, float s) {

    totalLength = l;
    numPoints = n;
    radius = r;
    strength = s;

    float len = totalLength / numPoints;

    // Here is the real work, go through and add particles to the chain itself
    for(int i=0; i <  numPoints; i++) {
      // Make a new particle with an initial starting location
      VerletParticle2D particle=new VerletParticle2D(width/2,i*len);

      // Redundancy, we put the particles both in physics and in our own ArrayList
      physics.addParticle(particle);

      // Connect the particles with a Spring (except for the head)
      if (i>0) {
        VerletParticle2D previous = physics.particles.get(i-1);
        VerletSpring2D spring=new VerletSpring2D(particle,previous,len,strength);
        // Add the spring to the physics world
        physics.addSpring(spring);
      }
    }

    // Keep the top fixed
    VerletParticle2D head=physics.particles.get(0);
    head.lock();

    // Store reference to the tail
    tail = physics.particles.get(numPoints-1);
  }

  // Check if a point is within the ball at the end of the chain
  // If so, set dragged = true;
  public void contains(int x, int y) {
    float d = dist(x,y,tail.x,tail.y);
    if (d <  radius) {
      offset.x = tail.x - x;
      offset.y = tail.y - y;
      tail.lock();
      dragged = true;
    }
  }

  // Release the ball
  public void release() {
    tail.unlock();
    dragged = false;
  }

  // Update tail location if being dragged
  public void updateTail(int x, int y) {
    if (dragged) {
      tail.set(x+offset.x,y+offset.y);
    }
  }

  // Draw the chain
  public void display() {
    // Draw line connecting all points
    for(int i=0; i <  physics.particles.size()-1; i++) {
      VerletParticle2D p1 = physics.particles.get(i);
      VerletParticle2D p2 = physics.particles.get(i+1);
      stroke(0);
      line(p1.x,p1.y,p2.x,p2.y);
    }

    // Draw a ball at the tail
    stroke(0);
    fill(175);
    ellipse(tail.x,tail.y,radius*2,radius*2);
  }
}


ControlP5 controlP5;
controlP5.Toggle buttonPlay;
controlP5.Toggle buttonRecord; 
controlP5.Toggle buttonPlayModified;

Slider sliderLowPassFilter;
Boolean recording = false;
Boolean playing = false;

int lowPassFilterSliderValue = 100;

public void setupControls()
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
  for (int i = 0; i <  BAND_NUM; i++) {
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

public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.controller().id());
  
  if (theEvent.controller().id() >= 100 && theEvent.controller().id() <  200)
  {
    bde.setBandScale(theEvent.controller().id() - 100, theEvent.controller().value());
  }
  
}

public void mouseMoved()
{
  // map the mouse position to the range [60, 2000], an arbitrary range of cutoff frequencies
  
}
public void keyPressed()
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
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#c0c0c0", "YDKM" });
  }
}
