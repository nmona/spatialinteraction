import processing.opengl.*;
import SimpleOpenNI.*;
import blobDetection.*;

SimpleOpenNI  context;
BlobDetection theBlobDetection;

PImage  userImage;
PGraphics bufferImage;
int userID;
int[] userMap;
PImage rgbImage;
PImage img;
color[] userClr = new color[] { 
  color(255, 0, 0),
};     
PVector last_pos_proj = new PVector(); 
int frameRateCounter = 0;
int delayNumber = 120;

void setup()
{
  size(640, 480);
  background(200, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(1);
  smooth();  

  //ENABLE CONTEXT
  context = new SimpleOpenNI(this);
  // enable depthMap generation 
  context.enableDepth();
  context.setMirror(!context.mirror());
  // enable skeleton generation for all joints
  context.enableUser();

  //BLOB DETECTION
  img = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setThreshold(0.25);

  bufferImage = createGraphics(width, height);
}

void draw()
{
  //background(3,100,255);

  // update the cam
  context.update();
  userImage = context.userImage();
  //img.copy(userImage, 0, 0, userImage.width, userImage.height, 0, 0, img.width, img.height);
  //fastblur(img, 2);

  userImage.loadPixels();

  for (int x=0; x<userImage.width; x++)
  {
    for (int y=0; y<userImage.height; y++)
    {
      int loc = x + y*userImage.width;

      color c = userImage.pixels[loc];

      colorMode(HSB);

      if (hue(c) == 0)
      {
        colorMode(RGB);
        userImage.pixels[loc] = color(255, 255, 255, 0);
      }
    }
  }
  if (frameRateCounter % 120 == 0) 
  {
    bufferImage.beginDraw();
    tint(255, 126);
    bufferImage.image(userImage,0,0);
    bufferImage.endDraw();
    //bufferImage.pixels[loc] = color(255, 255, 255, 0);
  }
  image(bufferImage, 0, 0);
  image(userImage, 0, 0);
  //  userImage.loadPixels();
  //  image(userImage,0,0);
  //theBlobDetection.computeBlobs(img.pixels);
  //drawBlobsAndEdges(true, true);
  //println(theBlobDetection.getBlobNb ());

  /*
  In der Ball Klasse
   int loc = ball.x + ball.y*breite
   colorMode(HSB);
   color c = userImage.pixels[loc];
   if(hue(c) == 0)
   {
   Dann umkehren oder Reset oder oder oder
   }
   colorMode(RGB);
   */
  if (frameRateCounter % 120 == 0) {
    //readFrame();
    println("jetzt");
  }
  frameRateCounter = frameRateCounter +1 ;
}

void readFrame() {
  userImage.loadPixels();
  image(userImage, 0, 0);
  tint(255, 127);
}

void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb (); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0, 255, 0);
        beginShape();
        fill(255, 0, 0);
        for (int m=0; m<b.getEdgeNb (); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
          {
            vertex(eA.x*width, eA.y*height);
            vertex(eB.x*width, eB.y*height);
          }
        }
        endShape();
      }

      // Blobs
      if (drawBlobs)
      {
        noFill();
        strokeWeight(1);
        stroke(255, 0, 0);
        rect(
        b.xMin*width, b.yMin*height, 
        b.w*width, b.h*height
          );
      }
    }
  }
}


void onNewUser(int uID) {
  userID = uID;
  println("tracking");
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0; i<256*div; i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0; y<h; y++) {
    rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0; x<w; x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0; y<h; y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}

