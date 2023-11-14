import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean ccwPressed = false;
boolean cwPressed = false;
boolean minusPressed = false;
boolean plusPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
boolean upPressed = false;
boolean downPressed = false;
boolean donePressed = false;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;
boolean logoHold = false;

//used for the images
HashMap<String, PShape> labelShapeMap = new HashMap<String, PShape>();


private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
    
  labelShapeMap.put("CCW", loadShape("icons/ccw.svg"));
  labelShapeMap.put("CW", loadShape("icons/cw.svg"));
  labelShapeMap.put("-", loadShape("icons/minus.svg"));
  labelShapeMap.put("+", loadShape("icons/plus.svg"));
  labelShapeMap.put("right", loadShape("icons/right.svg"));
  labelShapeMap.put("left", loadShape("icons/left.svg"));
  labelShapeMap.put("up", loadShape("icons/up.svg"));
  labelShapeMap.put("down", loadShape("icons/down.svg"));
  labelShapeMap.put("done", loadShape("icons/done.svg"));

  // Create buttons and add them to the buttons array
  buttons.add(new Button(inchToPix(.4f), inchToPix(.4f)+inchToPix(.8f)*3, inchToPix(.8f), inchToPix(.8f), "CCW"));
  buttons.add(new Button(inchToPix(.4f)+inchToPix(.8f), inchToPix(.4f)+inchToPix(.8f)*3, inchToPix(.8f), inchToPix(.8f), "CW"));
  buttons.add(new Button(inchToPix(.4f)+inchToPix(.8f), inchToPix(.4f)+ 2* inchToPix(.8f), inchToPix(.8f), inchToPix(.8f), "-"));
  buttons.add(new Button(inchToPix(.4f), inchToPix(.4f)+ 2 *inchToPix(.8f), inchToPix(.8f), inchToPix(.8f), "+"));
  buttons.add(new Button(inchToPix(.4f)+inchToPix(.8f), inchToPix(.4f), inchToPix(.8f), inchToPix(.8f), "right"));
  buttons.add(new Button(inchToPix(.4f), inchToPix(.4f), inchToPix(.8f), inchToPix(.8f), "left"));
  buttons.add(new Button(inchToPix(.4f)+inchToPix(.8f), inchToPix(.4f) + inchToPix(.8f), inchToPix(.8f), inchToPix(.8f), "down"));
  buttons.add(new Button(inchToPix(.4f), inchToPix(.4f)+inchToPix(.8f), inchToPix(.8f), inchToPix(.8f), "up"));
  buttons.add(new Button(inchToPix(.4f), inchToPix(.4f)+inchToPix(.8f)*4, inchToPix(1.6f), inchToPix(.8f), "done"));
}



void draw() {
  if (ccwPressed || cwPressed || minusPressed || plusPressed || leftPressed || rightPressed || upPressed || downPressed) {
    moveWhileButtonPressed();
  }
  background(40); //background is dark grey
  fill(200);
  noStroke();
  
  for (Button button : buttons) {
        button.draw();
  }
 //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }
  
  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }
  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if(checkForSuccess())
    fill(0, 255, 0, 120);
  else
    fill(255, 0, 0, 120);
  moveLogoWithMouse();//moves logo by clicking and holding
  rect(0, 0, logoZ, logoZ);
  popMatrix();


  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

public void moveLogoWithMouse()
{
  if(mouseX > logoX-logoZ/2 && mouseX < logoX+logoZ/2 && mouseY > logoY-logoZ/2 && mouseY < logoY+logoZ/2)
  {
    //System.out.println(random(2, 500));
    if (mousePressed == true)
    {
      logoHold = true;
    }
  }
  if (logoHold == true)
  {
    logoX = mouseX;
    logoY = mouseY;
  }
}


class Button {
  float x, y, width, height;
  String label;
  PShape shape;


  Button(float x, float y, float width, float height, String label) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
    this.shape = labelShapeMap.get(label);
  }

  void draw() {
    rectMode(CORNER);
    fill(200);
    stroke(0);
    rect(x, y, width, height);
    shapeMode(CENTER);
    shape(shape, x + width / 2, y + height / 2, width, height);
    rectMode(CENTER);

  }

  boolean isClicked() {
    return mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height;
  }
}

ArrayList<Button> buttons = new ArrayList<Button>();


void handleButtonAction(String label, boolean isPressed) {
  // Update the state of the buttons
  switch (label) {
    case "CCW":
      ccwPressed = isPressed;
      break;
    case "CW":
      cwPressed = isPressed;
      break;
    case "-":
      minusPressed = isPressed;
      break;
    case "+":
      plusPressed = isPressed;
      break;
    case "left":
      leftPressed = isPressed;
      break;
    case "right":
      rightPressed = isPressed;
      break;
    case "up":
      upPressed = isPressed;
      break;
    case "down":
      downPressed = isPressed;
      break;
    case "done":
      donePressed = isPressed;
      break;
  }
}
void moveWhileButtonPressed() {
  // Continuous movement while buttons are pressed
  if (ccwPressed) {
    logoRotation--;
  }
  if (cwPressed) {
    logoRotation++;
  }
  if (minusPressed) {
    logoZ = constrain(logoZ - inchToPix(.01f), .01, inchToPix(4f));
  }
  if (plusPressed) {
    logoZ = constrain(logoZ + inchToPix(.01f), .01, inchToPix(4f));
  }
  if (leftPressed) {
    logoX -= inchToPix(.01f);
  }
  if (rightPressed) {
    logoX += inchToPix(.01f);
  }
  if (upPressed) {
    logoY -= inchToPix(.01f);
  }
  if (downPressed) {
    logoY += inchToPix(.01f);
  }
}

void mousePressed()
{
  for (Button button : buttons) {
    if (button.isClicked()) {
      handleButtonAction(button.label, true); // Set the button state to "pressed"
    }
  }
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  logoHold = false;
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (donePressed)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  
  for (Button button : buttons) {
      if (button.isClicked()) {
        handleButtonAction(button.label, false); // Set the button state to "released"
      }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
