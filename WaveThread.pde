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
  ArrayList<VerletString2D> springs;
  
  public WaveThread(VerletPhysics2D physics, int length, VerletParticle2D origin)
  {
    this.physics = physics;
    this.length = length;
    this.origin = origin;
    
    this.origin.lock();      
    
    
    this.chain = new ArrayList<VerletParticle2D>();
    this.springs = new ArrayList<VerletString2D>();
    
    this.attractor = new VerletParticle2D(this.origin);
    this.comet = new VerletParticle2D(this.origin);
    this.physics.addParticle(this.origin);
    this.physics.addParticle(comet);
    this.physics.addParticle(attractor);
    
    this.attractorSpring = new VerletSpring2D(this.attractor,this.comet,3,2);
    this.originSpring = new VerletSpring2D(this.origin,this.comet,15,0.02);
     
    this.physics.addSpring(this.attractorSpring);
    this.physics.addSpring(this.originSpring);
    
    this.chain.add(comet);
    VerletParticle2D node = null;

    for (int i = 0; i<this.length; i++){
      node = new VerletParticle2D(comet);
      VerletString2D chainSpring = new VerletSpring2D(node,this.chain.get(this.chain.size() - 1),0.5, 0.07 * (0.1))
      this.physics.addSpring(chainSpring);       // - i * 0.00005
      this.physics.addParticle(node);
      this.chain.add(node);          
      this.springs.add(chainSpring);
      
      // optional
      this.physics.addSpring(new VerletSpring2D(this.origin,node,60,0.0002));
      this.physics.addSpring(new VerletSpring2D(this.attractor,node,60,0.0002));
    }
    
    //spring connecting last node and origin
    this.physics.addSpring(new VerletSpring2D(comet,node,30,0.0005));
    
  } 
  
  void update()
  {
    if (frameCount % 5 == 0)//(mousePressed)//
    {
      this.attractor.set(this.origin.add(this.comet.sub(this.origin).normalize().rotate(PI/random(0.1,3.8)).scale(noise(frameCount) * 70 + 15)));  
      this.attractor.lock();
      this.attractorSpring.setStrength(noise(frameCount) * 3 + 0.5);   
    }
  } 
  
  void draw()
  {
    
  }

}