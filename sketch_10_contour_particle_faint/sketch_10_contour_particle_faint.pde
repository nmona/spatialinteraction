/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */
 
import processing.opengl.*;
import SimpleOpenNI.*;
SimpleOpenNI  context;
PImage  userImage;
int userID;
int[] userMap;
PImage rgbImage;
Ball [] balls;


int numOfBalls = 500;


color[]       userClr = new color[]{ color(255,0,0),
                                   };     
PVector last_pos_proj = new PVector(); 

void setup()
{
  size(640,480);
  balls = new Ball[numOfBalls];
  
  for(int i=0; i<numOfBalls;i++)
  {
    float size = random(5,10);
    color c = color(random(0,255),random(0,255),random(0,255));
    PVector location = new PVector(random(size,width-size),random(size,height-size));
    balls[i] = new Ball(c,location,size); 
  }
  
  context = new SimpleOpenNI(this);
  
  // enable depthMap generation 
  context.enableDepth();
  context.setMirror(!context.mirror());
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(1);
  smooth();  
}

void draw()
{
  background(255);
  // update the cam

  context.update();
  if (context.getNumberOfUsers() > 0) { 
    userMap = context.userMap(); 
    loadPixels(); 
    for (int i = 0; i < userMap.length; i++) { 
      if (userMap[i] != 0) {
        pixels[i] = color(0, 255, random(100, 200)); 
      }     }
    updatePixels(); 
  }
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0);
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      //drawSkeleton(userList[i]);
      //drawobject(userList[i]);
      
      
      // get 3D position of a joint
      PVector jointPos = new PVector();
      PVector position_Proj = new PVector();
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND, jointPos);
      context.convertRealWorldToProjective(jointPos, position_Proj);
      last_pos_proj.lerp(position_Proj, 0.5);
      
      for(int x=0; x<numOfBalls;x++)
      {
        println(jointPos.z);       
        balls[x].update(last_pos_proj);
        balls[x].checkEdges();
        balls[x].display(); 
      }
    }    
  }  

      
}

void drawobject(int userId)
{
    // get 3D position of a joint
    PVector jointPos = new PVector();
    PVector position_Proj = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,jointPos);
    context.convertRealWorldToProjective(jointPos, position_Proj);
    last_pos_proj.lerp(position_Proj, 0.5);
    last_pos_proj = position_Proj;
    println(jointPos.x);
    println(jointPos.y);
    println(jointPos.z);
    pushMatrix();
      translate(last_pos_proj.x,last_pos_proj.y,0);
      fill(255);
      float size = 20000/last_pos_proj.z;
      box(size);
    popMatrix();  
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
