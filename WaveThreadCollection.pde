class WaveThreadCollection
{
  VerletPhysics2D physics;
  ArrayList<WaveThread2D> corethreads;
  
  public WaveThreadCollection(VerletPhysics2D physics, int length, VerletParticle2D origin, float forceScale)
  {
    this.physics = physics;
    this.corethreads = new ArrayList<WaveThread2D>();
        
    for (int i = 0; i<20; i++){
      this.corethreads.add(new WaveThread2D(physics, length, origin, forceScale));
    }
  } 
  
  void update(AudioSource src)
  {
    for (int i = 0; i<corethreads.size(); i++){
      corethreads.get(i).shapeInterpolator.set(src.left.level() * 30 + 1);
      corethreads.get(i).update();
    }
  }
  
  void draw()
  {
    for (int i = 0; i<corethreads.size(); i++){
      corethreads.get(i).draw();
    }
  }
}