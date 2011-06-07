class HelpScreen extends Screen
{
  boolean active;
  boolean shown;
  Integrator overlayOpacity;
  
  HelpScreen(PApplet papplet, int w, int h)
  {
    super(papplet,w,h);
    this.active = false;
    this.shown = false; 
    overlayOpacity = new Integrator(0,0.1,0.5);
  }
  
  void update()
  {
    //super.update();
    overlayOpacity.update();
  }
  
  void draw(int x, int y)
  {                 
    super.draw(x, y);
    
    pushMatrix();
    translate(x,y);
                    

    if (recordScreen != null && recordScreen.active && playing)
    {
      noStroke();
      fill(0,overlayOpacity.get());
      rect(0,0,width,height);

      textFont(detailFont);
      textSize(12);
      float opacity = map(overlayOpacity.get(),0,220,0,255);

      fill(255,opacity);
      rect(560, 355, 20, 20);
      rect(990, 355, 20, 20);

      fill(0, opacity);
      text("1", 560 + 7, 370);
      text("2", 990 + 7, 370);
      text("1", 560 + 7, 370);
      text("2", 990 + 7, 370);

      fill(255,opacity); 

      textFont(paragraphFont);
      textSize(15);
      text("Each slider below represents a frequency segment of your recording, the low frequency on the left. You can change the value to amplify a certain frequency to match the output to the voice of yourself. \n\nIt it possible that you will hear noise when certain low frequency ranges are amplified, please ignore only focus on the voice itself.", 560, 400, 400, 500); 
      text("You can click on the audio source name below to toggle the playback between the original recording and the augmented output. ", 990, 400, 250, 500);

      textFont(detailFont);
      textSize(10);
      text("FREQUENCY: LOW", 560, 660);
      text("HIGH", 930, 660);
      text("NOW PLAYING", 990, 660);
    }
    
   
    if (recordScreen != null && recordScreen.active)
    {
      textFont(detailFont);
      textSize(10);
      
      textAlign(RIGHT);
      
      if (active)
      {
        fill(255);
        text("Click to Close Help", 1270, 20);
      }
      else if (playing)
      {
        fill(80);
        text("Press H for Help", 1270, 20);
      }               
      
      textAlign(LEFT);
    }
    
    popMatrix();
  }
  
  void dismiss()
  {
    overlayOpacity.target(0);
    this.active = false;
  }
  
  void activate()
  {                    
    overlayOpacity.target(220);
    this.active = true;
    this.shown = true;
  }  
}