import processing.serial.*;

Serial myPort;
PImage carImage;
PImage wheelImage;

int line;
int wheel;
int speed;
int ramp;

int w;

void setup() 
{
  size(600, 600);
  
  // Car image
  carImage = loadImage("car.png");
  
  // Serial setup
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
  
  line=0;
  wheel=0;
  speed=0;
  ramp=0;
  
  w = int(0.02*width); 
  
  textAlign(CENTER,BOTTOM);
  
  background(0);
  fill(255);
  
  // Labels
  text("Line",width*0.2,height*0.9);
  text("Turn",width*0.4,height*0.9);
  text("Speed",width*0.6,height*0.9);
  text("Ramp",width*0.8,height*0.9);
  
  myPort.write("a");
  myPort.write("b");
  myPort.write("c");
  myPort.write("d");
  myPort.write("e");
  myPort.write(13);
}


void draw()
{
  displayStatus();
  
  fill(255);
  rect(.25*width,0,width*0.5,height*0.5);
  showCar();
  stroke(255);
  showWheel();
  showSpeed();
  
  updateStatus();
}

void displayStatus()
{
  fill(0);
  rect(0,height*0.9,width,height*0.1);
  fill(255);
  float h = height*0.95;
  text(line,width*0.2,h);
  text(wheel,width*0.4,h);
  text(speed,width*0.6,h);
  
  String rampText = "-";
  if(ramp == -1)
    rampText = "UP";
  if(ramp == 1)
    rampText = "DOWN";
  text(rampText,width*0.8,h);
}

void showCar()
{
  float xpos = 0.25*width+((-line+100.0)/200.0)*(width*0.5-carImage.width);
  image(carImage,xpos,.1*height);
}

void showWheel()
{
  fill(0,40);
  rect(.25*width,0.5*height,width*0.5,w*3);
  float xpos = 0.25*width+((wheel+100.0)/200.0)*(width*0.5-w);
  fill(0,0,255);
  rect(xpos,.5*height,w,w*3);
}

void showSpeed()
{
  fill(0,40);
  rect(.1*width,0,w*3,height*0.5);
  float ypos = (1-(speed/100.0))*(width*0.5-w);
  // Red
  if(speed < 10)
    fill(255,0,0);
  else
    fill(350-speed*3,180,0);
  rect(.1*width,ypos,w*3,w);
}

void updateParams()
{
  byte p = 0;
  byte p2 = 0;
  byte i = 0;
  byte i2 = 0;
  byte d = 0;
  byte d2 = 0;
  myPort.write(p);
  myPort.write(p2);
  myPort.write(i);
  myPort.write(i2);
  myPort.write(d);
  myPort.write(d2);
  println("Updating tuning parameters");
}

void updateStatus()
{
  byte[] inBuffer = new byte[4];
  
  while(myPort.available() < 4);
  
  inBuffer = myPort.readBytes();
  if(inBuffer != null)
  {
    if((inBuffer[0]==3)
      &(inBuffer[1]==2)
      &(inBuffer[2]==1)
      &(inBuffer[3]==0))
    {
      println("Starting control loop...");
    }
    else if((inBuffer[0]==0)
           &(inBuffer[1]==1)
           &(inBuffer[2]==2)
           &(inBuffer[3]==3))
    {
      println("FINISH LINE...");
    }
    else
    {
      line  = int(inBuffer[0])-100;
      wheel = int(inBuffer[1])-100;
      speed = int(inBuffer[2]);
      ramp  = int(inBuffer[3])-1;
    }
  }
}


void keyPressed() {
  switch(key)
  {
    default:
      updateParams();
      break;
  }
}
