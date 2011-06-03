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
    text("When we hear our own voice we hear it not only through the air but also through its vibration when it is conducted inside our skull, and we always hear a different voice from what other people are hearing. This different voice is never revealed to even family members or closest friends. \n\nThis project aims to create a simple tool for one to regenerate his or her voice as it is heard by oneself, so as to illustrate the difference between what we hear or think we are and that other people perceive of us. \n\nParticipate now to get your true voice heard. Type your name in the box to the right then press ENTER to start!", 60, 210, 380, 1000);
    
    
    textFont(titleFont);
    textSize(60);
    fill(30);
    text(username, 630, 260);
    
    
    if (frameCount % 30 <= 15)
    {
       noStroke();
      rect(630 + textWidth(username) + 10, 210, 3, 60);
    }
    
    
    popMatrix();
  }
  
  void dismiss()
  {
    this.active = false;
    recordScreen = new RecordScreen(this.applet, width, height, this.username);
    recordScreen.screenOffset.set(600);
    recordScreen.screenOffset.target(0);
    recordScreen.introOpacity.target(0);
    
    screenOffset.target(-width);
  }
}