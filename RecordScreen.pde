//audio
import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;
//physics
import toxi.geom.*;
import toxi.physics2d.*;

class RecordScreen extends Screen
{
  String username;
  
  // audio 
  Minim minim;
  AudioInput in;
  AudioRecorder recorder;
  AudioPlayer player;
  AudioPlayer playerMod;  
  FFT fft;
  FFT fftMod;
  BoneConductedEffect bde;
  

  VerletPhysics2D physics;
  //ArrayList<WaveThread2D> wavethreads;
  WaveThreadCollection threads;
  
  long lastSwitch = 0; 
  Integrator helpOpacity;
  Integrator introOpacity;
  Integrator screenOffset;
  
  AudioExporter exporter;
  
  RecordScreen(PApplet papplet, int w, int h, String name)
  {
    super(papplet,w,h); 
    this.username = name;
    
    helpOpacity = new Integrator(0,0.2,0.3);
    introOpacity = new Integrator(255,0.2,0.3);
    screenOffset = new Integrator(0,0.1,0.5);
    
    setupPhysics();
    setupAudio();
    
    exporter = null;
  }
  
  void setupPhysics()
  {
    physics = new VerletPhysics2D(null,50, 0, 1);
    physics.setGravity(new Vec2D(0,0));
    physics.setWorldBounds(new Rect(0,0,width,height));

    threads = new WaveThreadCollection(physics, new Vec2D(width * 2/3,height/2 - 100));
  }
  
  void setupAudio()
  {
    minim = new Minim(this.applet);
    in = minim.getLineIn(Minim.STEREO, 1024);
    
    String filename = this.username + ".wav";//"ydkm.wav"
    recorder = minim.createRecorder(in, filename, true);
    
    setupPlayers(savePath(filename));                              
  }                
  
  boolean setupPlayers(String filename)
  {
    File f = new File(filename);
    if (f.exists())
    {
      player = minim.loadFile(filename, 1024);
      playerMod = minim.loadFile(filename, 1024);
      //lpf = new LowPassFS(100, in.sampleRate());
      bde = new BoneConductedEffect(player.bufferSize(), player.sampleRate());
      
      try
      {
        String []config = loadStrings(savePath(this.username + "_freq.config"));
        if (config.length > 0)
        {
          bde.fromString(config[0]);
          println(config[0]);
        }                           
        else
        {
          bde.fromString("1.2,1.5,3.6,4.2,4.6,5.7,5.5,6.5,6.1,3.7,2.3,2.1,2.1,1.9,1.5");
        }
      }
      catch(Exception ex)
      {
        bde.fromString("1.2,1.5,3.6,4.2,4.6,5.7,5.5,6.5,6.1,3.7,2.3,2.1,2.1,1.9,1.5");
      }
      
     
      bde.updateController(controlP5);
       
      fft = new FFT(player.bufferSize(), player.sampleRate()); 
      fftMod = new FFT(playerMod.bufferSize(), playerMod.sampleRate());    

      // fft.logAverages(20,2);
      // fftMod.logAverages(20,2);  

      fft.linAverages(BAND_NUM);
      fftMod.linAverages(BAND_NUM);
      println("Players loaded successfully"); 
      playButton.show();
      shareButton.show();
      
      player.printControls();
      return true;      
    }             
    else
    {
      println("Players not loaded"); 
      playButton.hide();
      return false;
    }
  }
  
  void update()
  {
    super.update();
    
    physics.update();
    
    helpOpacity.update(); 
    introOpacity.update();
    screenOffset.update();       
    
    if (exporter != null && exporter.exporting)
    {
      threads.update(exporter.player, null);
    }
    else if (player != null && playerMod != null && (player.isPlaying() || playerMod.isPlaying()))
    {
      threads.update(player, playerMod);
    }
    else
    {
      threads.update(in, null);
    }
    
    if (exporter != null)
    {
      exporter.update();
    }
    
  } 
  
  void draw(int x, int y)
  {
    pushMatrix();
    translate(x,y);
    translate(screenOffset.get(),0);
    
    controlP5.draw();
    
    textFont(titleFont);
    textSize(50);
    fill(30);
    text("RECORD", 60, 120);
    
    
    textFont(paragraphFont);
    textSize(18);
    fill(120);
    text("You can record a short clip of your voice, be it an excerpt from your favorite novel, or whatever just happens to be on your mind.\n\nAfter you are finished with recording, adjust the audio with the equalizer tool and try to match the recording to the voice as you hear it yourself.\n\nWhen you are all set, you can choose to participate in the online audio gallery of \"You Don't Know Me\" project and upload your recording. It will show up on project website upon approval.", 60, 150, 360, 1000);
    
    if (exporter != null && exporter.exporting)
    {
      threads.draw(exporter.player, null);
    }
    else if (player != null && playerMod != null)
    {
      threads.draw(player, playerMod);
    }
    else
    {
      threads.draw(in, null);
    }    
    
    if (player != null && playerMod != null)
    {
      textFont(titleFont);
      textSize(24);
      if (player.isPlaying() && playerMod.isPlaying())
      {
        
        if (playerMod.isMuted() && !player.isMuted())
        {
          fill(187,0,0);
          text("ORIGINAL", 990, 640);
        }
        else if (!playerMod.isMuted() && player.isMuted())
        {
          fill(0,153,255);
          text("AUGMENTED", 990, 640);
        } 
        
        /*noFill();
                rect(1030, 613, 200,30);   */
        
        if (mousePressed && millis() - lastSwitch > 400)
        {
          if (mouseX >= 990 && mouseX < 1160 && mouseY >= 625 && mouseY <= 640)
          {
            this.toggleChannel(); 
            lastSwitch = millis();
          }
        }
      }
    }
    
    drawHelp();  
    
    noStroke();
    fill(230, introOpacity.get());
    rect(0,0,600, height);
    
    popMatrix();
    
    
    if (exporter != null)
    {
      exporter.draw();
    }
    
  }
  
  void drawHelp()
  {
    fill(160,helpOpacity.get()); 
    textFont(detailFont);
    textSize(10);
    text("USE EQUALIZER TO AUGMENT AUDIO", 560, 660);
    text("TOGGLE PLAYBACK AUDIO SOURCE", 990, 660);
  } 
  
  void stop()
  {
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
  }
  
  void record()
  {
    println("Record");

    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
      //buttonRecord.setLabel("Record");
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
      println("Recording saved");
      
      String filename = savePath(this.username + ".wav");//"ydkm.wav"
      setupPlayers(filename);
            
    }
    else 
    {
      recorder = minim.createRecorder(in, this.username + ".wav", true);
      recorder.beginRecord();
      //buttonRecord.setLabel("Stop");
      recording = true;
      println("Recording started");
    }
  }  
  

  void muteNormal()
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

  void muteMod()
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
  
  void toggleAll()
  {
    if (player != null && playerMod != null)
    {
      if (player.isPlaying() && playerMod.isPlaying())
      {
        player.pause();
        playerMod.pause();
        playing = false;
        helpOpacity.target(0);
      }
      else
      {
        player.loop();
        playerMod.loop(); 
        playerMod.clearEffects();
        playerMod.addEffect(bde);
        playing = true;
        player.mute();
        helpOpacity.target(255);
      }     
    }
  }
  
  void toggleChannel()
  {
    if (player != null && playerMod != null)
    {
      if (!player.isPlaying() && !playerMod.isPlaying())
      {
        this.toggleAll();
      }
      
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

  void toggleIntro()
  {
    if (introOpacity.get() > 127)
    {
      introOpacity.target(0);
      screenOffset.target(0);      
    }
    else
    {
      introOpacity.target(255);
      screenOffset.target(- width*2/3 + width/2);
      
      exportAugmentedAudio();
    }
  }
  
  void exportAugmentedAudio()
  {
    String configString = bde.toString();
    
    PrintWriter output = createWriter(this.username + "_freq.config");
    output.print(configString); 
    output.flush();
    output.close();
    println("Using config:" + configString);
    
    exporter = new AudioExporter(minim, playerMod, bde, this.username + "_aug.wav");
    exporter.uploader = new Uploader(exporter, this.username, savePath(this.username + ".wav"), savePath(this.username + "_aug.wav"), configString);
    exporter.start();
  }
}