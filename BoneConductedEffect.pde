import ddf.minim.analysis.*;

class BoneConductedEffect implements AudioEffect
{
  private FFT fft;
  private float bandScale[];

  public BoneConductedEffect(int bufferSize, float sampleRate)
  {
    this.fft = new FFT(bufferSize, sampleRate);
    this.fft.linAverages(BAND_NUM);  
    this.bandScale = new float[BAND_NUM];
    for (int i = 0; i< BAND_NUM ; i++) 
    {
      this.bandScale[i] = 1;
    }
  } 
  
  public void setBandScale(int band, float scale)
  {
    if (band < this.bandScale.length && band >= 0)
    {
      this.bandScale[band] = scale;
    }
  }

  void process(float[] samp)
  {                   

    float[] mod = new float[samp.length];
    arraycopy(samp, mod);       

    this.fft.forward(mod);

    for (int i = 0; i < this.fft.avgSize(); i++) 
    {
      this.fft.scaleBand(i,this.bandScale[i]);
    }
    
    this.fft.inverse(mod);

    arraycopy(mod, samp);
  }

  void process(float[] left, float[] right)
  {
    process(left);
    process(right);
  }                      
  
  String toString()
  {
    String output = "";
    for (int i = 0; i<bandScale.length; i++){
      if (i > 0)
      {
        output += "|";
      }               
      output += nf(bandScale[i],1,4).replace(',','.');
    }
    return output;
  } 
  
  void fromString(String data)
  {
    String []pieces = split(data, "|");
    if (pieces.length == 1)
    {
      pieces = split(data, ",");
    }
    if (pieces.length <= bandScale.length)
    {
      for (int i = 0; i<pieces.length; i++){
        bandScale[i] = float(pieces[i]);
      }
    }
    
  }
  
  void updateController(ControlP5 c)
  {
    for (int i = 0; i<allSliders.size(); i++){
      try
      {
        ((Slider)c.controller("EQ" + i)).setValue(bandScale[i]);
      } 
      catch (Exception e)
      {
        return;
      }
    }    
  }
}