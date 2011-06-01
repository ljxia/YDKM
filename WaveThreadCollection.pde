class WaveThreadCollection
{
  VerletPhysics2D physics;
  ArrayList<WaveThread2D> originalthreads;
  ArrayList<WaveThread2D> augmentedthreads;
  
  public WaveThreadCollection(VerletPhysics2D physics, Vec2D origin)
  {
    this.physics = physics;
    this.originalthreads = new ArrayList<WaveThread2D>();
    this.augmentedthreads = new ArrayList<WaveThread2D>();
    
    VerletParticle2D o = new VerletParticle2D(origin); 
    VerletParticle2D oo = new VerletParticle2D(origin.add(-10,0));
    VerletParticle2D oa = new VerletParticle2D(origin.add(10,0));
    
    physics.addParticle(o);
    physics.addParticle(oo);
    physics.addParticle(oa);
    
    o.lock();
    
    
    VerletSpring2D offsetString0 = new VerletSpring2D(oo, oa, 10, 0.1);
    VerletSpring2D offsetString1 = new VerletSpring2D(o, oo, 5, 0.1);
    VerletSpring2D offsetString2 = new VerletSpring2D(o, oa, 5, 0.1);
    
    physics.addSpring(offsetString0);
    physics.addSpring(offsetString1);
    physics.addSpring(offsetString2);
    
    for (int i = 0; i<20; i++){
      this.originalthreads.add(new WaveThread2D(physics, 25, oo, 0.98));
      this.augmentedthreads.add(new WaveThread2D(physics, 25, oa, 0.98));
    }
    
    for (int i = 0; i<augmentedthreads.size(); i++){
      augmentedthreads.get(i).threadColor = color(0,153,255);
    }
    
    
  } 
  
  void update(AudioSource src1, AudioSource src2)
  { 
    if (src1 != null)
    {
      for (int i = 0; i<originalthreads.size(); i++){
        originalthreads.get(i).shapeInterpolator.target(src1.left.level() * 30 + 0.9);
        originalthreads.get(i).update();
      }      
    }

    
    if (src2 != null)
    {
      for (int i = 0; i<augmentedthreads.size(); i++){
        augmentedthreads.get(i).shapeInterpolator.target(src2.left.level() * 30 + 0.9);
        augmentedthreads.get(i).update();
      }
    }
    else if (src1 != null)
    {
      for (int i = 0; i<augmentedthreads.size(); i++){
        augmentedthreads.get(i).shapeInterpolator.target(src1.left.level() * 30 + 0.9);
        augmentedthreads.get(i).update();
      }
    }
    
    
  }
  
  void draw(AudioSource src1, AudioSource src2)
  {
    if (src2 != null && ((AudioPlayer)src2).isPlaying())
    {
      for (int i = 0; i<augmentedthreads.size(); i++){
        augmentedthreads.get(i).draw();
      }
    }

    for (int i = 0; i<originalthreads.size(); i++){
      originalthreads.get(i).draw();
    }
    

  }
}