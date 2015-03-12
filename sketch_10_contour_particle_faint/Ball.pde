class Ball 
{

  PVector location;
  PVector velocity;
  PVector acceleration;
  
  float topspeed;
  float size;
  color c;
  
  Ball() 
  {
    location = new PVector(100, 100);
    velocity = new PVector(0,0);
    acceleration = new PVector(-0.001,0.01);
    topspeed = 10;
    size = 50;
    c = color(255,255,255);
    
  }
  
  Ball(color _c, PVector _startLoc, float _size)
  {
    location = _startLoc;
    velocity = new PVector(0,0);
    acceleration = new PVector(-0.001,0.01);
    topspeed = 10;
    size = _size;
    c = _c;
  }
  
  //1.Speed und Position addieren = neue Position
  void update(PVector newPos) 
  {

    PVector mouse = new PVector(newPos.x, newPos.y, newPos.z);
    PVector dir = PVector.sub(mouse,location);
    dir.normalize();
    dir.mult(0.4);
    acceleration = dir;
    
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
  }

  //2.Kanten erkennen
  void checkEdges() 
  {
    if ((location.x > width-size/2) || (location.x < 0+size/2)) 
    {
      velocity.x = velocity.x * -1; //Umkehren
    }
    if ((location.y > height-size/2) || (location.y < 0+size/2)) 
    {
      velocity.y = velocity.y * -1; //Umkehren
    }
  }

  //3.Ball darstellen
  void display() 
  {    

    pushMatrix();
      translate(location.x,location.y);
      fill(255);
      stroke(0);
      float size = 2000/last_pos_proj.z;
      ellipse(0,0,size,size);
    popMatrix();
  }
}

