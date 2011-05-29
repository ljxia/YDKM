//physics
import toxi.geom.*;
import toxi.physics2d.*;

class WaveThread2D
{
  VerletPhysics2D physics;
  int length;
  VerletParticle2D origin;
  VerletParticle2D comet;
  Vec2D lastComet;
  VerletParticle2D attractor;
  VerletSpring2D attractorSpring;
  VerletSpring2D originSpring;
  
  ArrayList<VerletParticle2D> chain;
  ArrayList<VerletSpring2D> springs; 
  
  float forceScale = 1;
  float shapeScale = 1; 
  int rep = 1; 
  int updateInterval = 5;
  
  public WaveThread2D(VerletPhysics2D physics, int length, VerletParticle2D origin, float forceScale)
  {
    this.physics = physics;
    this.length = length;
    this.origin = origin;
    this.forceScale = forceScale;
     
    this.chain = new ArrayList<VerletParticle2D>();
    this.springs = new ArrayList<VerletSpring2D>();
    
    this.attractor = new VerletParticle2D(this.origin);
    this.comet = new VerletParticle2D(this.origin.add(Vec2D.randomVector().scale(50)));
    this.physics.addParticle(this.origin);
    this.physics.addParticle(this.comet);
    this.physics.addParticle(this.attractor);
    
    this.origin.lock();
    this.attractor.unlock();
    this.comet.unlock();
    
    this.attractorSpring = new VerletSpring2D(this.attractor,this.comet,5,forceScale * 2.1);
    this.originSpring = new VerletSpring2D(this.origin,this.comet,15,forceScale * 0.002);
     
    this.physics.addSpring(this.attractorSpring);
    this.physics.addSpring(this.originSpring);
    
    this.chain.add(comet);
    VerletParticle2D node = null;
    float weight = 1;

    for (int i = 0; i<this.length; i++){
      node = new VerletParticle2D(comet);
      weight += 0.05;
      node.setWeight(weight); 
      //node.setWeight(1/forceScale);
      VerletSpring2D chainSpring = new VerletSpring2D(node,this.chain.get(this.chain.size() - 1),2.5, forceScale * 0.02);
      this.physics.addSpring(chainSpring);       // - i * 0.00005
      this.physics.addParticle(node);
      this.chain.add(node);          
      this.springs.add(chainSpring);
      
      // optional
      this.physics.addSpring(new VerletConstrainedSpring2D(this.origin,node,20,forceScale * 0.0005));
      this.physics.addSpring(new VerletConstrainedSpring2D(this.attractor,node,20,forceScale * 0.0005));   
    }
    
    //spring connecting last node and origin
    this.physics.addSpring(new VerletSpring2D(this.comet,node,2.5,forceScale * 0.0005));
    
    
    this.rep = 1;//ceil(random(6,12));
  } 
  
  void update()
  {
    if (frameCount % updateInterval == 0)//(mousePressed)//
    {
      //print(".");
      this.attractor.set(this.origin.add(this.comet.sub(this.origin).normalize().rotate(PI/random(0.1,5)).scale(noise(frameCount * this.comet.x) * 30 + 15)));  
      
      //this.attractor.set(new Vec2D(mouseX, mouseY));
      this.attractor.lock();
      this.attractorSpring.setStrength(forceScale * (noise(frameCount * this.comet.x) * 0.5 + 0.1));   
    }
    
    /*if (this.lastComet != null)
    {    
      this.chain.get(1).set(this.lastComet);
    }
    this.lastComet = this.comet.copy(); */
  } 
  
  void draw()
  {
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
    for (int j = 0; j < rep; j++)
    {

      /*fill(100, 30);

      beginShape();

      for (int i = 0; i<chain.size(); i++)
      {
        stroke(100, 180);
        //noStroke();
        curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      } 

      endShape(); */

      rotate(PI/20);

      beginShape();
      
      //fill(255,0,0, 30);
      noFill();
      for (int i = 0; i<chain.size(); i++)
      {
        stroke(255,0,0, 180);
        //noStroke();
        curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      }
      endShape();                                      

      rotate(-PI/20); 

      rotate(TWO_PI/rep);

    }           

    popMatrix();
  }

}