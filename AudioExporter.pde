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
  
  Uploader uploader; 
  
  String message = "";
  float progress;
  String submissionHandle = "";
  
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
    
    this.uploader = null;
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
      
      progress = 0;
      message = "";
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
            uploading = true;
            finished = false;
            
            if (this.uploader != null)
            {
              this.uploader.start();
            }
         }
       }
       else if (uploading)
       {
         if (progress >= 10 && progress < 95)
         {
           if (frameCount % 5 == 0)
           {
             progress += 1;
           }
         }
       }
    }
  }
  
  void draw()
  { 
    if (exporting)
    {
       progress = map(player.position(),0,player.length(), 0, 100);
       message = "PROCESSING FILES";
    }
    
    
    if (exporting || uploading)
    {
      noStroke();
      fill(200);
      rect(300, height - 200, width - 600, 3);

      fill(187,0,0);
      rect(300, height - 200, map(progress,0,100,0,width - 600), 3); 
      
      textFont(detailFont);
      textSize(10);
      text(message, 300, height - 180);
    }
    
    if (startTime > 0 && finished)
    {
      if (!submissionHandle.equals(""))
      {
        String url = "http://turbulence.org/Works/youdontknowme/submission.php?k=" + submissionHandle;
        startTime = 0;
        finished = true;
        link(url);
      }
      
    } 
    else if (startTime <= 0 && finished)
    {
      if (!submissionHandle.equals(""))
      {
        fill(187,0,0);
        textFont(titleFont);
        textSize(50);
        textAlign(CENTER);

        text("THANK YOU FOR PARTICIPATING", width/2, height - 180);

        
        
        //open browser window 
        textFont(paragraphFont);
        textSize(18);
        fill(160);
        
        text("Your submission will open in a new browser window. You can now close the app. \nFor more information, visit http://http://turbulence.org/Works/youdontknowme/", width/2, height - 135);
        
        textAlign(LEFT);
      }
    }

    
  }
}