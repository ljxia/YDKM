class Uploader extends Thread
{
  String userName;
  String fileOriginal;
  String fileAugmented;
  String token_url;
  String hostname;
  String configuration;
  AudioExporter audioExporter;
  
  public Uploader(AudioExporter exporter, String username, String fileoriginal, String fileaugmented, String config)
  {
    this.audioExporter = exporter;
    this.userName = username;
    this.fileOriginal = fileoriginal;
    this.fileAugmented = fileaugmented;
    this.configuration = config;
    
    this.hostname = "http://darkudon.appspot.com/";
    this.token_url = "ydkm.token"; 
  }
  
  public void run()
  {               
    this.audioExporter.progress = 5;
    this.audioExporter.message = "PREPARING FOR UPLOAD";
    
    this.upload();
    
    try
    {
      this.audioExporter.progress = 100;
      this.audioExporter.message = "UPLOAD COMPLETE";
      
      this.audioExporter.uploading = false;
      this.audioExporter.finished = true;
      
      println("Upload Done");
      this.join();
    }
    catch(InterruptedException e)
    {
      println("thread interrupted");
    }
  }                                    
  
  private void upload()
  {
    String []query = loadStrings(this.hostname + this.token_url);
    if (query.length > 0)
    {
      String upload_url = query[0];
      println(upload_url);
      
      this.audioExporter.progress = 10;
      this.audioExporter.message = "UPLOADING FILES";
      
      HttpClient httpclient = new DefaultHttpClient();
      HttpPost httppost = new HttpPost(upload_url);
      FileBody originalFileBody = new FileBody(new File(fileOriginal),"audio/x-wav");
      FileBody augmentedFileBody = new FileBody(new File(fileAugmented),"audio/x-wav");
      MultipartEntity reqEntity = new MultipartEntity();

      try
      {
        reqEntity.addPart("username", new StringBody(this.userName));
        reqEntity.addPart("fileOriginal", originalFileBody);
        reqEntity.addPart("fileAugmented", augmentedFileBody);
        reqEntity.addPart("configuration", new StringBody(this.configuration));

        httppost.setEntity(reqEntity);

        //println("executing request " + httppost.getRequestLine());
        HttpResponse response = httpclient.execute(httppost);
        HttpEntity resEntity = response.getEntity();

        println("----------------------------------------");
        println(response.getStatusLine().toString());
        
        org.apache.http.Header[] headers = response.getAllHeaders();
        for (int i = 0; i<headers.length; i++){
          //println(headers[i].getName() + "/" + headers[i].getValue());
          
          if (headers[i].getName().equals("Location"))
          {
            String result_url = headers[i].getValue();
            
            query = loadStrings(result_url);
            if (query.length > 0)
            {                   
              println("=============================");
              println(query[0]); 
              this.audioExporter.submissionHandle = query[0];
            }
          }          
        }
        
        if (resEntity != null) 
        {
            //println("Response content length: " + resEntity.getContentLength());
            BufferedReader reader = new BufferedReader(new InputStreamReader(resEntity.getContent()));

            try 
            {
              String result = reader.readLine();
              //println(result);
            } 
            catch (IOException ex) 
            {
                throw ex;
            } 
            catch (RuntimeException ex) 
            {
                throw ex;
            } 
            finally 
            {
                reader.close();
            }
        }
        if (resEntity != null) {
            resEntity.consumeContent();
        }    
      }
      catch(Exception ex){}
    }
    
  }
}  