class HomeScreen extends Screen
{
  String username; 
  boolean active;
  Integrator screenOffset;
  
  HomeScreen(PApplet papplet, int w, int h)
  {
    super(papplet,w,h);
    this.active = true; 
    screenOffset = new Integrator(0,0.1,0.5);
    
    username = "";
  }
  
  void update()
  {
    //super.update();
    screenOffset.update();
  }
  
  void draw(int x, int y)
  {
    super.draw(x, y);
    
    pushMatrix();
    translate(x,y);
                    
    translate(screenOffset.get(),0);
    //controlHome.draw();
    
    textFont(titleFont);
    textSize(50);
    fill(187,0,0);
    text("YOU DON'T\nKNOW ME", 60, 120);


    textFont(paragraphFont);
    textSize(18);
    fill(120);
    text("When we hear our own voice we hear it not only through the air but also as bone conducted vibration as it travels inside our skull, and we always hear a different voice from what other people are hearing. This different voice is never revealed to even family members or closest friends. \n\nThis project aims to create a simple tool for one to regenerate his or her voice as it is heard by oneself, so as to illustrate the difference between what we hear or think we are and that other people perceive of us. \n\nParticipate now to get your true voice heard. Type your name in the box to the right then press ENTER to start!", 60, 210, 380, 1000);
    
    textFont(detailFont);
    textSize(12);
    fill(180);
    text("Ver " + VERSION, 60, height - 30);
    
    textAlign(CENTER);
    textFont(titleFont);
    textSize(60);
    fill(30);
    text(username, 850, 310);
    textAlign(LEFT);
    
    if (frameCount % 30 <= 15)
    {
      noStroke();
      rect(850 + (textWidth(username) / 2) + 10, 260, 3, 60);
    }
    
    
    popMatrix();
  }
  
  void dismiss()
  {
    this.active = false;
    recordScreen = new RecordScreen(this.applet, width, height, this.username);
    recordScreen.active = true;
    
    recordScreen.screenOffset.set(600);
    recordScreen.screenOffset.target(0);
    recordScreen.introOpacity.target(0);
    
    
    screenOffset.target(-width);
    
  }
}