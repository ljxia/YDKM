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
VerletParticle2D origin;
VerletParticle2D comet;
Vec2D lastComet;
VerletParticle2D attractor;
VerletSpring2D attractorSpring;
ArrayList<VerletParticle2D> chain;
ArrayList<Vec2D> trail;

void setup()
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
  physics.addSpring(new VerletSpring2D(origin,comet,15,0.02));
  physics.addSpring(attractorSpring);
  
  trail = new ArrayList<Vec2D>();
  
  int chainlength = 50;
  chain = new ArrayList<VerletParticle2D>();
  chain.add(comet);
  VerletParticle2D node = null;
  
  
  for (int i = 0; i<chainlength; i++){
    node = new VerletParticle2D(comet);
    physics.addSpring(new VerletSpring2D(node,chain.get(chain.size() - 1),0.5, 0.07 * (0.1)));       // - i * 0.00005
    physics.addParticle(node);
    chain.add(node);          
    
    physics.addSpring(new VerletSpring2D(origin,node,60,0.0002));
    physics.addSpring(new VerletSpring2D(attractor,node,60,0.0002));
  }
  
  physics.addSpring(new VerletSpring2D(comet,node,30,0.0005));
  
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

void draw()
{
  background(230);
  /*noStroke();
  fill(255,50);
  rect(0,0,width, height); */
  
  controlP5.draw(); 
  
  if (chain != null && chain.size() > 2)
  {
    if (trail.size() == 0 || trail.get(trail.size() - 1).distanceTo(attractor) > 2)
    {
      trail.add(attractor.copy());
    }
    
    if (trail.size() > 50)
    {
      trail.remove(0);
    }
    //println(.x + ", " + trail.get(trail.size() - 1).y);    
  }

  //println(trail.size());
  
  
  //update physics
  if (frameCount % 5 == 0)//(mousePressed)//
  {
    attractor.set(origin.add(comet.sub(origin).normalize().rotate(PI/random(0.1,3.8)).scale(noise(frameCount) * 70 + 15)));  
    attractor.lock();
    attractorSpring.setStrength(noise(frameCount) * 3 + 0.5);   
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
  for (int j = 0; j < rep; j++){

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
  //fill(255,100,0, 130); 
  noFill();
  beginShape();
  for (int i = 1; i<trail.size(); i++){
    //line(trail.get(i).x,trail.get(i).y,trail.get(i-1).x,trail.get(i-1).y);
    //ellipse(trail.get(i).x,trail.get(i).y,5,5);
    curveVertex(trail.get(i).x,trail.get(i).y);
  }
  endShape();
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
