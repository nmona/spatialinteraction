//SWARM
import java.util.Vector;
import controlP5.*;
ControlP5 controlP5;

World gWorld;
//int gScreenSize = 800;
float gWorldSize = 10.0;
float gDisplayScale = (float)1440 / gWorldSize;

color gWorldColor = color(0, 0, 0 );
int gAgentCount = 1000;

//CONTOUR
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
int frameRateCounter = 0;
int snapshotNumber = 5;

void setup()
{  
  gWorld = new World(gWorldSize, gAgentCount);
  
  controlP5 = new ControlP5(this);
//  controlP5.addSlider("simStep",0.0,1.0,10,10,10,100,14).setId(1);
//  controlP5.addSlider("mass",0.01,2.0,10,10,30,100,14).setId(2);
//  controlP5.addSlider("brownian",0.0,2.0,10,10,50,100,14).setId(3);
//  controlP5.addSlider("prefVel",0.0,2.0,10,10,70,100,14).setId(4);
//  controlP5.addSlider("prefAmount",0.0,2.0,10,10,90,100,14).setId(5);
//  controlP5.addSlider("cohesion",0.0,2.0,10,10,110,100,14).setId(6);
//  controlP5.addSlider("evasion",0.0,2.0,10,10,130,100,14).setId(7);
//  controlP5.addSlider("alignment",0.0,2.0,10,10,150,100,14).setId(8); ///



  size(1280, 960);
  smooth();  
  bufferImage = createGraphics(width, height);
  
  //ENABLE CONTEXT
  context = new SimpleOpenNI(this);
  // enable depthMap generation 
  context.enableDepth();
  //context.setMirror(!context.mirror());
  // enable skeleton generation for all joints
  context.enableUser();
}

void buffer() {
  bufferImage.beginDraw();
  bufferImage.colorMode(RGB);
  bufferImage.fill(255, 255, 255, 180);
  bufferImage.rect(0, 0, width, height);
  bufferImage.image(transparentImage, 0, 0, width, height);
  bufferImage.endDraw();
}

void draw() {
  println(width, height);
  // update the cam
  context.update();

  userImage = context.userImage();
  userImage.loadPixels();
  fastblur(context.userImage(), 6);
 
  //println(userImage.width, userImage.height);

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
        transparentImage.pixels[loc] = color(40, 40, 40);
      }
    }
  }
  if (frameRateCounter % snapshotNumber == 0) 
  {
    buffer();
  }

  image(bufferImage, 0, 0, width, height);  
  image(transparentImage, 0, 0, width, height);



  gWorld.update();
  gWorld.display();


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

// -----------------------------------------------------------------



class World
{   
  float mTimeStep;
  float mSize;
  color mColor;
  Agent[] mAgents;
  Grid mGrid;  

  World( float pSize, int pAgentCount )
  { 
    mTimeStep = 0.05;
    mSize = pSize;
    mColor = color(255,255,255);  //background color
    
    createAgents(pAgentCount);
    createNeighborSpace();
  }
   
  void update()
  {
    mGrid.update(mAgents); //grid wird gebildet in welt
    
    for(int i=0; i<mAgents.length; ++i) mAgents[i].act(); 
    for(int i=0; i<mAgents.length; ++i) mAgents[i].update(); 
  }
  
  void display()
  {
   fill(mColor); //background
   rect(0, 0, width, height); //background
   
   for(int i=0; i<mAgents.length; ++i) mAgents[i].display();  //Agents darstellen
  }
  
  Vector getNeighbors(Agent pAgent) //schat ob Agent in Nähe, innerhalb Grid
  {
    return mGrid.getNeighbors(pAgent);
  }

  void createAgents(int pAgentCount) //Agents werden Kreiiert
  {
    mAgents = new Agent[pAgentCount];
    float[] agentPos = new float[2];    
    for(int i=0; i<mAgents.length; ++i) 
    {
      agentPos[0] = random(0.0, gWorldSize); //zufällige Position innerhalb Welt
      agentPos[1] = random(0.0, gWorldSize);
      mAgents[i] = new Agent(i, agentPos);
    }
  }
 
  
  void createNeighborSpace() //Grid wird iniitiert
  {
    mGrid = new Grid(mSize, 40);
  }  
}

class Grid //Grid Eigenschaften
{
  float mCellSize;
  int mCellCount;
  GridCell[][] mCells;
  
  Grid(float pSize, int pCellCount)
  {
    mCellCount = pCellCount;
    mCellSize = pSize / (float) mCellCount;
    mCells = new GridCell[mCellCount][mCellCount];
    
    for(int y=0; y<mCellCount; ++y)
    {
      for(int x=0; x<mCellCount; ++x)
      {
        mCells[x][y] = new GridCell();
      }
    }
  }
  
  void update(Agent[] pAgents)
  {
    // clear cells
    for(int y=0; y<mCellCount; ++y)
    {
      for(int x=0; x<mCellCount; ++x)
      {
        mCells[x][y].clear();
      }
    }    
    
    // add agents
    int[] cellIndex = new int[2];
    
    for(int agentNr=0; agentNr<pAgents.length; ++agentNr)
    {
      cellIndex[0] = (int)( pAgents[agentNr].mPos[0] / mCellSize );
      cellIndex[1] = (int)( pAgents[agentNr].mPos[1] / mCellSize );      
      mCells[ cellIndex[0] ][ cellIndex[1] ].addAgent( pAgents[agentNr] );
     }
     
     //check for silouette
     for(int agentNr=0; agentNr<pAgents.length; ++agentNr)
     {
       int agentImageIndex = (int)pAgents[agentNr].mPos[0] + (int)pAgents[agentNr].mPos[1] * transparentImage.width;       
       color c = transparentImage.pixels[ agentImageIndex ];
       if (c == color(40,40,40)){
       }
       else {
         PVector jointPos = new PVector();
         PVector position_Proj = new PVector();
         context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
         context.convertRealWorldToProjective(jointPos, position_Proj);
         last_pos_proj.lerp(position_Proj, 0.5);
         last_pos_proj = position_Proj;

         pushMatrix();
           translate(last_pos_proj.x,last_pos_proj.y,0);
           float size = 20000/last_pos_proj.z;
         popMatrix();  
       }
     }
  }
  
  
  
  
  
  
  
  Vector getNeighbors(Agent pAgent)
  {
    int[] cellSearchIndex = new int[2];
    cellSearchIndex[0] = (int)( pAgent.mPos[0] / mCellSize );
    cellSearchIndex[1] = (int)( pAgent.mPos[1] / mCellSize );
    
    int cellSearchRadius;
    cellSearchRadius = (int)( ceil(pAgent.mVision / mCellSize) ); //Sicht des einzelnen Agents
    
    Vector cellAgents;
    int cellAgentCount;
    Agent cellAgent;
    Vector neighbors = new Vector(0);
    float neighborDistance2;
    float vision2 = pAgent.mVision * pAgent.mVision;
     
    for(int y=cellSearchIndex[1] - cellSearchRadius; y<cellSearchIndex[1] + cellSearchRadius; ++y)
    {
      if(y < 0 || y >= mCellCount) continue;
      
      for(int x=cellSearchIndex[0] - cellSearchRadius; x<cellSearchIndex[0] + cellSearchRadius; ++x)
      {
        if(x < 0 || x >= mCellCount) continue;
        
        cellAgents = mCells[x][y].mAgents;
        cellAgentCount = cellAgents.size();
         
        for(int agentNr=0; agentNr<cellAgentCount; ++agentNr)
        {
          cellAgent = (Agent)( cellAgents.elementAt(agentNr) );
          
          if(pAgent.mId != cellAgent.mId)
          {
              neighborDistance2 = (pAgent.mPos[0] - cellAgent.mPos[0]) * (pAgent.mPos[0] - cellAgent.mPos[0]) + (pAgent.mPos[1] - cellAgent.mPos[1]) * (pAgent.mPos[1] - cellAgent.mPos[1]);
          
              if(neighborDistance2 <= vision2) neighbors.add(cellAgent);
          }
        }
      }
    }
    return neighbors;
  }
 }

class GridCell
{
  Vector mAgents;
  
  GridCell()
  {
    mAgents = new Vector(0);
  }
  
  void clear()
  {
     mAgents.clear(); 
  }
  
  void addAgent( Agent pAgent )
  {
    mAgents.add(pAgent);
  }
}

class Agent
{
  int mId;
  float mMass;
  float mVision;
  float mSize;
  color mColor;
  
  float[] mPos;
  float[] mVel;
  float[] mAcceleration;
  float[] mForce;
  
  float[] mPosBackup;
  float[] mVelBackup;
  
  Vector mNeighbors;
  
  float mBrownianAmount;
  float mPrefVel;
  float mPrefAmount;
  float mCohesionAmount;
  float mEvasionAmount;
  float mAlignmentAmount; ///

  Agent(int pId, float[] pPos)
  {
    mId = pId;
    mMass = 1.0; //Agent mass?
    mVision = 0.2;  //Sichtweite Agent?
    
    mSize = 0.05;   //Agentsize
    mColor = color(255, 0, 0); //Agent color
    
    mPos = new float[2];
    mPos[0] = pPos[0];
    mPos[1] = pPos[1];
    mVel = new float[2];
    mVel[0] = 0.0;
    mVel[1] = 0.0;
    mAcceleration = new float[2];
    mAcceleration[0] = 0.0;
    mAcceleration[1] = 0.0;
    mForce = new float[2];
    mForce[0] = 0.0;
    mForce[1] = 0.0;
 
    mPosBackup = new float[2];
    mPosBackup[0] = mPos[0];
    mPosBackup[1] = mPos[1];
    mVelBackup = new float[2];
    mVelBackup[0] = mVel[0];
    mVelBackup[1] = mVel[1]; 
  
    mBrownianAmount = 0.1; 
    mPrefVel = 0.68;
    mPrefAmount = 0.9; 
    mCohesionAmount = 0.4;
    mEvasionAmount = 0.2;
    mAlignmentAmount = 0.8; ///
  }
  
  void act()
  {
    look();
    brownian();
    prefVel();
    cohesion();
    evasion();
    alignment(); ///
    move();
  }
 
  void look()
  {
    mNeighbors = gWorld.getNeighbors( this );
  } 
  
  void brownian()
  {
    mForce[0] += random(-1.0, 1.0) * mBrownianAmount;
    mForce[1] += random(-1.0, 1.0) * mBrownianAmount;
  }
  
  void prefVel()
  {
    float[] force = new float[2];
    float forceScale;

    float curVel = sqrt( mVel[0] * mVel[0] + mVel[1] * mVel[1] ); 
    if(curVel == 0.0) return;
    forceScale = mPrefVel - curVel;
    
    force[0] = mVel[0] / curVel * forceScale;
    force[1] = mVel[1] / curVel * forceScale;
    
    mForce[0] += force[0] * mPrefAmount;
    mForce[1] += force[1] * mPrefAmount;  
  }
  
  void cohesion()
  {
    float minDist = 0.0;
    float maxDist = 0.2;
    
    int totalNeighCount = mNeighbors.size();
    if(totalNeighCount == 0) return;
    
    Agent neighbor;
    float[] neighPos;
    float[] neighVec = new float[2];
    float[] avgNeighVec = new float[2]; 
    float[] force = new float[2];
    float neighDist;
    float forceScale;
    
    int neighCount = 0;
    avgNeighVec[0] = 0.0;
    avgNeighVec[1] = 0.0;
    
    for(int neighNr=0; neighNr < totalNeighCount; ++neighNr)
    {
      neighbor = (Agent)mNeighbors.elementAt(neighNr);
      neighPos = neighbor.mPos;
      
      neighVec[0] = (neighPos[0] - mPos[0]);
      neighVec[1] = (neighPos[1] - mPos[1]);
      neighDist = sqrt( neighVec[0] * neighVec[0] + neighVec[1] * neighVec[1] );
    
      if(neighDist < minDist ) continue;
      else if(neighDist > maxDist ) continue;
      
      avgNeighVec[0] += neighVec[0];
      avgNeighVec[1] += neighVec[1];
      neighCount++;
    }
    
    if(neighCount == 0) return;
    
    avgNeighVec[0] /= (float)neighCount;
    avgNeighVec[1] /= (float)neighCount;
    neighDist = sqrt( avgNeighVec[0] * avgNeighVec[0] + avgNeighVec[1] * avgNeighVec[1] );
    forceScale = (neighDist - minDist) / (maxDist - minDist);
    
    force[0] = avgNeighVec[0] / neighDist * forceScale;
    force[1] = avgNeighVec[1] / neighDist * forceScale;
    
    mForce[0] += force[0] * mCohesionAmount;
    mForce[1] += force[1] * mCohesionAmount;
  } 

  void evasion()
  {
    float minDist = 0.0;
    float maxDist = 0.1;
    
    int totalNeighCount = mNeighbors.size();
    if(totalNeighCount == 0) return;
    
    Agent neighbor;
    float[] neighPos;
    float[] neighVec = new float[2];  
    float[] force = new float[2];
    float neighDist;
    float forceScale;
    
    for(int neighNr=0; neighNr < totalNeighCount; ++neighNr)
    {
      neighbor = (Agent)mNeighbors.elementAt(neighNr);
      neighPos = neighbor.mPos;
      
      neighVec[0] = (neighPos[0] - mPos[0]);
      neighVec[1] = (neighPos[1] - mPos[1]);
      neighDist = sqrt( neighVec[0] * neighVec[0] + neighVec[1] * neighVec[1] );
    
      if(neighDist < minDist ) continue;
      else if(neighDist > maxDist ) continue;
      
      forceScale = (neighDist - minDist) / (maxDist - minDist);
 
      force[0] = -neighVec[0] / neighDist * forceScale;
      force[1] = -neighVec[1] / neighDist * forceScale;
    
      mForce[0] += force[0] * mEvasionAmount;
      mForce[1] += force[1] * mEvasionAmount;
    }
  }
 
  ///
  void alignment()
  {
    float minDist = 0.0;
    float maxDist = 0.2;
    
    int totalNeighCount = mNeighbors.size();
    if(totalNeighCount == 0) return;
    
    Agent neighbor;
    float[] neighPos;
    float[] neighVec = new float[2];
    float[] neighVel;
    float[] force = new float[2];
    float neighDist;
    
    int neighCount = 0;   
    for(int neighNr=0; neighNr < totalNeighCount; ++neighNr)
    {
      neighbor = (Agent)mNeighbors.elementAt(neighNr);
      neighPos = neighbor.mPos;
      neighVel = neighbor.mVel;
      
      neighVec[0] = (neighPos[0] - mPos[0]);
      neighVec[1] = (neighPos[1] - mPos[1]);
      neighDist = sqrt( neighVec[0] * neighVec[0] + neighVec[1] * neighVec[1] );
    
      if(neighDist < minDist ) continue;
      else if(neighDist > maxDist ) continue;
      
      force[0] = neighVel[0] - mVel[0];
      force[1] = neighVel[1] - mVel[1];
    
      mForce[0] += force[0] * mAlignmentAmount;
      mForce[1] += force[1] * mAlignmentAmount;    
    }   
  } 
  
  void move()
  {
    // integrate
    mAcceleration[0] = mForce[0] / mMass;
    mAcceleration[1] = mForce[1] / mMass;
    mVelBackup[0] += mAcceleration[0] * gWorld.mTimeStep;
    mVelBackup[1] += mAcceleration[1] * gWorld.mTimeStep;
    mPosBackup[0] += mVelBackup[0] * gWorld.mTimeStep;
    mPosBackup[1] += mVelBackup[1] * gWorld.mTimeStep;   
    
    // boundary wrap
    while(mPosBackup[0] < 0) mPosBackup[0] += gWorld.mSize;
    while(mPosBackup[0] >= gWorld.mSize) mPosBackup[0] -= gWorld.mSize;
    while(mPosBackup[1] < 0) mPosBackup[1] += gWorld.mSize;
    while(mPosBackup[1] >= gWorld.mSize) mPosBackup[1] -= gWorld.mSize;
  }  
  void update()
  {
    mPos[0] = mPosBackup[0];
    mPos[1] = mPosBackup[1];
    mVel[0] = mVelBackup[0];
    mVel[1] = mVelBackup[1];
    mForce[0] = 0.0;
    mForce[1] = 0.0;
  } 
  
  void display()
  {
   float[] displayPos = new float[2];
   float displayOrientation;
   float displaySize;
   
   displayPos[0] = mPos[0] * gDisplayScale;
   displayPos[1] = mPos[1] * gDisplayScale;
   displaySize = mSize * gDisplayScale / 2.0;
   displayOrientation = atan2(mVel[1], mVel[0]);
   
   fill(mColor);
   
   pushMatrix();
   translate(displayPos[0], displayPos[1]);
   rotate(displayOrientation - PI / 2.0);
   triangle(-displaySize, -displaySize, displaySize, -displaySize, 0, 2 * displaySize);
   popMatrix();
  }
}

void controlEvent(ControlEvent theEvent) 
{
  Agent[] agents = gWorld.mAgents;
 
  switch(theEvent.controller().id()) 
  {
    case(1):
    gWorld.mTimeStep = theEvent.controller().value();
    break;
    case(2):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mMass = theEvent.controller().value();
    break;    
    case(3):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mBrownianAmount = theEvent.controller().value();
    break; 
    case(4):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mPrefVel = theEvent.controller().value();
    break;     
    case(5):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mPrefAmount = theEvent.controller().value();
    break;    
    case(6):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mCohesionAmount = theEvent.controller().value();
    break;     
    case(7):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mEvasionAmount = theEvent.controller().value();
    break;
    case(8):
    for(int agentNr = 0; agentNr < agents.length; ++agentNr) agents[agentNr].mAlignmentAmount = theEvent.controller().value();
    break;
  }
}
