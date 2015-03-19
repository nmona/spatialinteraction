import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI context;

PImage userImage;
PGraphics bufferImage;
int userID;
int[] userMap;
PImage transparentImage;
color[] userClr = new color[] { 
  color(0, 0, 0),
};
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   
int frameRateCounter = 0;
int snapshotNumber = 120;
PVector pos = new PVector();// stores Center of Mass position
color userColor = color(0,0,0,40); 
color backgroundColor = color(255,255,255,120);
//int[] xpos = new int[50];
int bufferCounter = 10;
int xPos1 = 1;
int xPos2 = 1;

void setup()
{
  size(1280, 960);
  smooth();  
  bufferImage = createGraphics(width, height);
  //ENABLE CONTEXT
  context = new SimpleOpenNI(this);
  // enable depthMap generation 
  context.enableDepth();
  context.setMirror(!context.mirror());
  // enable skeleton generation for all joints
  context.enableUser();
  //buffer();
}

void centerOfMass() {
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    // draw the center of mass
    if(context.getCoM(userList[i],com))
//    {
//      context.convertRealWorldToProjective(com,com2d);
//      fill(0,255,0);
//      ellipse(com2d.x, com2d.y, 20, 20);
//    }
    
    if(frameRateCounter % bufferCounter == 0){
      xPos2 = xPos1;
      xPos1 = int(com2d.x);
      if(xPos1 - xPos2 <= abs(20)){
      bufferImage.image(transparentImage, 0, 0, width, height);
      buffer();
      }
    }
  }
  
}

void buffer() {
  bufferImage.beginDraw();
  bufferImage.colorMode(RGB);
  bufferImage.fill(backgroundColor);
  bufferImage.rect(0, 0, width, height);
  bufferImage.image(transparentImage, 0, 0, width, height);
  bufferImage.endDraw();
  image(bufferImage, 0, 0, width, height);
}

void draw() {

  // update the cam
  context.update();

  userImage = context.userImage();
  userImage.loadPixels();
  fastblur(context.userImage(), 6);
  //userImage.resize(displayWidth, displayHeight);

  transparentImage = new PImage(userImage.width, userImage.height);
  transparentImage.format = ARGB;

  for (int x=0; x<userImage.width; x++)
  {
    for (int y=0; y<userImage.height; y++)
    {
      int loc = x + y*userImage.width;

      color c = userImage.pixels[loc];

      colorMode(HSB);

      if (hue(c) == 0)
      {
      } else {
        colorMode(RGB);
        transparentImage.pixels[loc] = color(userColor);
      }
    }
  }
  centerOfMass();
  image(transparentImage, 0, 0, width, height);
  
  
  if (frameRateCounter % 120 == 0) {
    println("jetzt");
  }
  frameRateCounter = frameRateCounter +1 ;
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
  println("start tracking skeleton");

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

void fastblur(PImage img,int radius)
{
 if (radius<1){
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
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
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

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
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

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}
