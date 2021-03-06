import processing.opengl.*;

int BAND_NUM = 80;
String setting;

PFont titleFont;
PFont paragraphFont;
PFont detailFont;

String VERSION = "1.0.6";

HomeScreen homeScreen;
RecordScreen recordScreen;
HelpScreen helpScreen;

void setup()
{
  size(1280,720, OPENGL);
  hint(DISABLE_OPENGL_2X_SMOOTH);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(30); 
  smooth(); 
  setting = "";
    
  setupControls(); 
  
  
  homeScreen = new HomeScreen(this, width, height);
  helpScreen = new HelpScreen(this, width, height);
  
  //recordScreen = new RecordScreen(this, width, height, "melody");
  
  titleFont = loadFont("HelveticaNeue-Bold-60.vlw");
  paragraphFont = loadFont("HelveticaNeue-Light-18.vlw");
  detailFont = loadFont("HelveticaNeue-UltraLight-12.vlw");
}

void update()
{
  homeScreen.update();
  if (recordScreen != null)
  {
    recordScreen.update();
  }
  helpScreen.update();  
}            

void draw()
{
  update();              
  background(230);
  
  homeScreen.draw(0,0);
  if (recordScreen != null)
  {
    recordScreen.draw(0,0);
  }
  helpScreen.draw(0,0); 
}

void drawAudioSource(ddf.minim.AudioSource source, int x, int y, int width, int height)
{
  pushMatrix();
  translate(x,y);
  int qHeight = height/4;
  for(int i = 0; i < source.left.size()-1; i++)
  {
    line( map(i,0,source.left.size(),0,width), 
          qHeight + source.left.get(i)*qHeight, 
          map(i+1,0,source.left.size(),0,width), 
          qHeight + source.left.get(i+1)*qHeight);
    line( map(i,0,source.left.size(),0,width), 
          qHeight * 3 + source.right.get(i)*qHeight , 
          map(i+1,0,source.left.size(),0,width), 
          qHeight * 3 + source.right.get(i+1)*qHeight);
  }
  popMatrix();  
} 

void drawFFT(FFT thisfft, int x, int y, int width, int height)
{
  pushMatrix();
  translate(x,y);
  float bandwidth = width/thisfft.avgSize();
  for(int i = 0; i < thisfft.avgSize(); i++)
  {
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    
    rect(map(i,0,thisfft.avgSize(),0,width), height - thisfft.getAvg(i)*4, bandwidth, thisfft.getAvg(i)*4);
    
    //println(thisfft.getBand(i)*400000);
  }   
  
  popMatrix();
}



void stop()
{
  // always close Minim audio classes when you are done with them
  if (recordScreen != null)
  {
    recordScreen.stop();
  }
  
  super.stop();
} 
