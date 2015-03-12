//Spatial Interaction
//ZHdK, Interaction Design
//iad.zhdk.ch
//Beispiel 5: Kamerabild Background Substraction

import processing.video.*;
Capture video;

PImage backgroundImage;
float threshold = 20;
PFont myFont;
PImage myImage;
int pixelSize = 10;
String txtDisplay = "a";
int value = 0;

void setup() 
{
  size(640, 480);
  myFont = createFont("Futura-Lig", 32);
  video = new Capture(this, width, height, 30);
  video.start();
  backgroundImage = createImage(video.width, video.height, RGB);
}

void draw() 
{
  //background(0,0,0);
  fill(255, 255, 255, 20);
  rect(0, 0, width, height);
  if (video.available()) 
  {
    video.read();
  }

  loadPixels();
  video.loadPixels(); 
  backgroundImage.loadPixels();

  for (int x = 0; x < video.width; x +=pixelSize ) 
  {
    for (int y = 0; y < video.height; y +=pixelSize ) 
    {
      int loc = x + y*video.width; 
      color fgColor = video.pixels[loc]; 

      color bgColor = backgroundImage.pixels[loc];

      float r1 = red(fgColor);
      float g1 = green(fgColor);
      float b1 = blue(fgColor);
      float r2 = red(bgColor);
      float g2 = green(bgColor);
      float b2 = blue(bgColor);
      float diff = dist(r1, g1, b1, r2, g2, b2);

      if (diff > threshold) 
      {
        //pixels[loc] = fgColor;
        float B = brightness(fgColor);

        if (B < 15)
        {
          textFont(myFont);
          textSize(51);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 30)
        {
          textFont(myFont);
          textSize(48);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 45)
        {
          textFont(myFont);
          textSize(45);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 60)
        {
          textFont(myFont);
          textSize(42);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 75)
        {
          textFont(myFont);
          textSize(39);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 90)
        {
          textFont(myFont);
          textSize(36);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 105)
        {
          textFont(myFont);
          textSize(33);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 120)
        {
          textFont(myFont);
          textSize(30);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 135)
        {
          textFont(myFont);
          textSize(27);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 150)
        {
          textFont(myFont);
          textSize(24);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 165)
        {
          textFont(myFont);
          textSize(21);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 180)
        {
          textFont(myFont);
          textSize(18);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 195)
        {
          textFont(myFont);
          textSize(15);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 210)
        {
          textFont(myFont);
          textSize(12);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 225)
        {
          textFont(myFont);
          textSize(9);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 240)
        {
          textFont(myFont);
          textSize(6);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        } else if (B < 255)
        {
          textFont(myFont);
          textSize(3);
          text(txtDisplay, x, y);
          fill(0, 102, 153);
        }
      } else 
      {
        pixels[loc] = color(0, 0, 0);
      }
    }
  }
  //updatePixels();
  keyPressed();
}

void mousePressed() 
{  
  backgroundImage.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  backgroundImage.updatePixels();
}

void keyPressed()
{
  if (keyPressed) {
    if (key == 'b' || key == 'B') {
      txtDisplay ="b";
    }
  }
    if (keyPressed) {
    if (key == 'a' || key == 'A') {
      txtDisplay ="a";
    }
  }
    if (keyPressed) {
    if (key == 'c' || key == 'C') {
      txtDisplay ="c";
    }
    
  }
    if (keyPressed) {
    if (key == 'm' || key == 'M') {
      txtDisplay ="m";
    }
  }
    if (keyPressed) {
    if (key == 'f' || key == 'F') {
      txtDisplay ="F";
    }
  }
      if (keyPressed) {
    if (key == 'i' || key == 'I') {
      txtDisplay ="i";
    }
  }
}

