class AudioExporter
{
  Minim minim;
  AudioPlayer player;
  AudioRecorder recorder;
  BoneConductedEffect effect;
  String filename;
  
  long startTime;
  boolean exporting;
  boolean uploading;
  boolean finished; 
  
  AudioExporter(Minim minim, AudioPlayer exportPlayer, BoneConductedEffect bce, String filename)
  {
    this.minim = minim;
    this.player = exportPlayer;
    this.effect = bce;
    this.finished = true;
    this.startTime = 0; 
    this.filename = filename;
    this.exporting = false;
    this.uploading = false;
  }
  
  void start()
  {
    if (player != null)
    {
      player.rewind();
      player.pause();
      
      recorder = minim.createRecorder(player, filename, true);
      
      println(player.length());
      player.clearEffects();
      player.addEffect(effect);
      player.play();
      recorder.beginRecord();                      
      
      startTime = millis();
      finished = false;
      this.exporting = true;
      this.uploading = false;
    }
  }
  
  void update()
  {
    if (this.startTime > 0 && !this.finished)
    {
       if (exporting)
       {
         if (!player.isPlaying())
         {
            recorder.endRecord();
            recorder.save();
            exporting = false;
            finished = true;
         }
       }
    }
  }
  
  void draw()
  {
    float progress = 0;
    
    if (exporting)
    {
       progress = map(player.position(),0,player.length(), 0, width - 600);
    }
    
    
    if (exporting || uploading)
    {
      noStroke();
      fill(200);
      rect(300, height - 200, width - 600, 3);

      fill(187,0,0);
      rect(300, height - 200, progress, 3);
    }
    
    
  }
}