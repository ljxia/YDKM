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
  ArrayList<Float> springLengths; 
  
  float forceScale = 1;
  float shapeScale = 1; 
  int rep = 1; 
  int updateInterval = 3;
  
  Integrator shapeInterpolator;
  int threadColor;
  
  public WaveThread2D(VerletPhysics2D physics, int length, VerletParticle2D origin, float forceScale)
  {
    this.physics = physics;
    this.length = length;
    this.origin = origin;
    this.forceScale = forceScale;
    
    this.shapeInterpolator = new Integrator(1,0.6,0.3);
     
    this.chain = new ArrayList<VerletParticle2D>();
    this.springs = new ArrayList<VerletSpring2D>();
    this.springLengths = new ArrayList<Float>();
    
    this.attractor = new VerletParticle2D(this.origin);
    this.comet = new VerletParticle2D(this.origin.add(Vec2D.randomVector().scale(50)));
    //this.physics.addParticle(this.origin);
    this.physics.addParticle(this.comet);
    this.physics.addParticle(this.attractor);
    
    this.origin.unlock();
    this.attractor.unlock();
    this.comet.unlock();
    
    this.attractorSpring = new VerletSpring2D(this.attractor, this.comet, 5 * this.shapeInterpolator.get(), forceScale * 2.2);

    this.originSpring = new VerletSpring2D(this.origin, this.comet, 15 * this.shapeInterpolator.get(),  forceScale * 0.002);
    
     
    this.physics.addSpring(this.attractorSpring);
    this.physics.addSpring(this.originSpring);
                                             
    this.springs.add(attractorSpring);
    this.springLengths.add(attractorSpring.getRestLength());
    
    this.springs.add(originSpring);
    this.springLengths.add(originSpring.getRestLength());
    
    this.chain.add(comet);
    VerletParticle2D node = null;
    float weight = 1;
    VerletSpring2D ospring = null;

    for (int i = 0; i<this.length; i++)
    {
      node = new VerletParticle2D(comet);
      weight += 0.06;
      node.setWeight(weight); 
      //node.setWeight(1/forceScale);
      VerletSpring2D chainSpring = new VerletSpring2D(node, this.chain.get(this.chain.size() - 1),  2.5 * this.shapeInterpolator.get(),   forceScale * 0.02);
      this.physics.addSpring(chainSpring);       // - i * 0.00005
      
      this.physics.addParticle(node);
      this.chain.add(node);          
      this.springs.add(chainSpring);
      this.springLengths.add(chainSpring.getRestLength());
      
      // optional
      ospring = new VerletConstrainedSpring2D(this.origin, node, 20 * this.shapeInterpolator.get(),  forceScale * 0.0005);
      this.physics.addSpring(ospring);
      this.springs.add(ospring);
      this.springLengths.add(ospring.getRestLength());
      
      ospring = new VerletConstrainedSpring2D(this.attractor, node, 20 * this.shapeInterpolator.get(),  forceScale * 0.0005);
      
      this.physics.addSpring(ospring);
      this.springs.add(ospring);
      this.springLengths.add(ospring.getRestLength());   
    }
    
    //spring connecting last node and origin
    ospring = new VerletSpring2D(this.comet, node, 2.5 * this.shapeInterpolator.get(), forceScale * 0.0005);
    this.physics.addSpring(ospring);                                                                        
    this.springs.add(ospring);
    this.springLengths.add(ospring.getRestLength());
    
    
    this.rep = 1;//ceil(random(3,7));
    this.updateInterval = 4; //ceil(random(3,20)); 
    
    this.threadColor = color(187,0,0);
  } 
  
  void update()
  {
    this.shapeInterpolator.update();
    
    if (frameCount % updateInterval == 0)//(mousePressed)//
    {
      //print(".");
      this.attractor.set(this.origin.add(this.comet.sub(this.origin).normalize().rotate(PI/random(0.1,5)).scale((noise(frameCount * this.comet.x) * 30 + 15) * this.shapeInterpolator.get())));  
      
      //this.attractor.set(new Vec2D(mouseX, mouseY));
      this.attractor.lock();
      this.attractorSpring.setStrength(forceScale * (noise(frameCount * this.comet.x) * 0.5 + 0.1));   
    }
    
    for (int i = 0; i<springs.size(); i++)
    {
      VerletSpring2D s = springs.get(i);
      s.setRestLength(springLengths.get(i) * this.shapeInterpolator.get());
    }
    
    /*if (this.lastComet != null)
    {    
      this.chain.get(1).set(this.lastComet);
    }
    this.lastComet = this.comet.copy(); */
  } 
  
  void draw()
  {
    /*stroke(170);
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
    //ellipse(attractor.x ,attractor.y,3,3);    */

    pushMatrix();
    translate(origin.x,origin.y);
    /*scale(1.4);*/
    for (int j = 0; j < rep; j++)
    {

      //fill(100, 30);
      
      /*pushMatrix();
      rotateZ(PI/4);
      noFill();
      beginShape();

      for (int i = 0; i<chain.size(); i++)
      {
        stroke(100, 180);
        //noStroke();
        curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      } 

      endShape(); 
      popMatrix(); */
       

      //rotate(PI/20);

      beginShape();
      
      //fill(255,0,0, 30);
      noFill();
      for (int i = 0; i<chain.size(); i++)
      {
        stroke(this.threadColor);
        strokeWeight(1.5);
        //noStroke();
        curveVertex(chain.get(i).x - origin.x ,chain.get(i).y - origin.y);
      }
      endShape();                                      

      //rotate(-PI/20); 

      rotate(TWO_PI/rep);

    }           

    popMatrix();
  }

}