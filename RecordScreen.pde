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
  
  RecordScreen(PApplet papplet, int w, int h, String name)
  {
    super(papplet,w,h); 
    this.username = name;
    
    setupPhysics();
    setupAudio();
  }
  
  void setupPhysics()
  {
    physics = new VerletPhysics2D(null,50, 0, 1);
    physics.setGravity(new Vec2D(0,0));
    physics.setWorldBounds(new Rect(0,0,width,height));

    threads = new WaveThreadCollection(physics, new Vec2D(width * 3/4,height/2));
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
      fft = new FFT(player.bufferSize(), player.sampleRate()); 
      fftMod = new FFT(playerMod.bufferSize(), playerMod.sampleRate());    

      // fft.logAverages(20,2);
      // fftMod.logAverages(20,2);  

      fft.linAverages(BAND_NUM);
      fftMod.linAverages(BAND_NUM);
      println("Players loaded successfully");
      return true;      
    }             
    else
    {
      println("Players not loaded");
      return false;
    }
  }
  
  void update()
  {
    super.update();
    
    physics.update();
    
    /*for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).update();
    } */                   
    
    if (player != null && playerMod != null)
    {
      threads.update(player, playerMod);
    }
    else
    {
      threads.update(in, null);
    }
    
  } 
  
  void draw(int x, int y)
  {
    controlP5.draw(); 
    threads.draw();
    /*if (player != null && player.isPlaying())
    {
       stroke(30);
       drawAudioSource(player, 20,60, width / 2 - 40, 80);

       fft.forward(player.mix);

       noStroke();
       fill(0,0,220,130); 
       drawFFT(fft,      20, 260, width - 40, 80);
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

       noStroke();
       fill(220,0,0,150); 

       drawFFT(fftMod,   20, 260, width - 40, 80);
    }*/

    /*for (int i = 0; i<wavethreads.size(); i++){
      wavethreads.get(i).draw();
    } */
    
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
  
  void play()
  {
    println("Play");
    if ( player != null )
    {
      if (playing)
      {
         buttonPlay.setLabel("Play");
         playing = false; 

         player.pause();
      }
      else
      {
        buttonPlay.setLabel("Stop");
        playing = true;
        player.loop();

        //player.play();
      }    
    }
  } 
  
  void play_modified() {
    if (playerMod != null)
    {
       if (playerMod.isPlaying())
       {
         buttonPlayModified.setLabel("Play");
         playerMod.pause(); 
       }
       else
       {
          buttonPlayModified.setLabel("Stop");
          playerMod.pause();
          playerMod.loop(); 
          //playerMod.addEffect(lpf);
          playerMod.addEffect(bde);
        }
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
      }
      else
      {
        player.loop();
        playerMod.loop();
        playerMod.addEffect(bde);
      }     
    }
  }
  
  void toggleChannel()
  {
    if (player != null && playerMod != null)
    {
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
}