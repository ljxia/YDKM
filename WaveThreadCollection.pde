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
    
    VerletParticle2D oo = new VerletParticle2D(origin.add(-100,0));
    VerletParticle2D oa = new VerletParticle2D(origin.add(100,0));
    for (int i = 0; i<20; i++){
      this.originalthreads.add(new WaveThread2D(physics, 25, oo, 0.98));
      this.augmentedthreads.add(new WaveThread2D(physics, 25, oa, 0.98));
    }
  } 
  
  void update(AudioSource src1, AudioSource src2)
  { 
    if (src1 != null)
    {
      for (int i = 0; i<originalthreads.size(); i++){
        originalthreads.get(i).shapeInterpolator.set(src1.left.level() * 30 + 0.9);
        originalthreads.get(i).update();
      }      
    }

    
    if (src2 != null)
    {
      for (int i = 0; i<augmentedthreads.size(); i++){
        augmentedthreads.get(i).shapeInterpolator.set(src2.left.level() * 30 + 0.9);
        augmentedthreads.get(i).update();
      }
    }
    else
    {
      for (int i = 0; i<augmentedthreads.size(); i++){
        augmentedthreads.get(i).shapeInterpolator.set(src1.left.level() * 30 + 0.9);
        augmentedthreads.get(i).update();
      }
    }
    
    
  }
  
  void draw()
  {
    for (int i = 0; i<originalthreads.size(); i++){
      originalthreads.get(i).draw();
    }
    
    for (int i = 0; i<augmentedthreads.size(); i++){
      augmentedthreads.get(i).draw();
    }
  }
}