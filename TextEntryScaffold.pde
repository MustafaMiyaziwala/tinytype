import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 295; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;
PFont font;
Node parentNode;
Node currentNode;

;;
enum LastSide {
   LEFT,
   MIDDLE, 
   RIGHT,
   NONE
}

class Node {
  
  PImage image;
  Node nodes[];
  char chars[];
  
  Node(String imageName, Node leftNode, Node middleNode, Node rightNode) {
    image = loadImage(imageName);
    nodes = new Node[3];
    nodes[0] = leftNode; nodes[1] = middleNode; nodes[2] = rightNode;
    chars = null;
  }
  
  
  Node(String imageName, char left, char middle, char right) {
    image = loadImage(imageName);
    this.nodes = null;
    chars = new char[3];
    chars[0] = left; chars[1] = middle; chars[2] = right;
  }
  
  
  boolean isLeaf() {
    return nodes == null; 
  }
  
  char getChar(LastSide side) {
     return chars[side.ordinal()];
  }
  
  Node getChild(LastSide side) {
    return nodes[side.ordinal()];
  }
  
  void drawImage() {
    pushMatrix();
    translate(width/2 + 3, height/2 + DPIofYourDeviceScreen/8); // Shift down by 0.25 inch (assuming 96 DPI)
    image.resize(DPIofYourDeviceScreen, (3*DPIofYourDeviceScreen)/4);
    imageMode(CENTER);
    image(image, 0, 0);
    popMatrix();
  }
  
}


void handleClick(LastSide side) {
   
  if (currentNode.isLeaf()) {
    
    currentTyped+=currentNode.getChar(side);
    currentNode = parentNode;
    
  } else {
    
    currentNode = currentNode.getChild(side);
    
  }
  
  currentNode.drawImage();
}


void createNodes() {
  
   Node bhnNode = new Node("bhn.png", 'b', 'h', 'n');
   Node tgyNode = new Node("tgy.png", 't', 'g', 'y');
   Node cfvNode = new Node("cfv.png", 'c', 'f', 'v');
   
   Node erdNode = new Node("erd.png", 'e', 'r', 'd');
   Node zsxNode = new Node("zsx.png", 'z', 's', 'x');
   Node qawNode = new Node("qaw.png", 'q', 'a', 'w');
   
   Node olpNode = new Node("olp.png", 'o', 'l', 'p');
   Node mkspaceNode = new Node("mkspace.png", 'm', 'k', ' ');
   Node ujiNode = new Node("uji.png", 'u', 'j', 'i');
   
   Node leftNode = new Node("left.png", qawNode, zsxNode, erdNode);
   Node middleNode = new Node("middle.png", cfvNode, tgyNode, bhnNode);
   Node rightNode = new Node("right.png", ujiNode, mkspaceNode, olpNode);
   
   
   parentNode = new Node("parent.png", leftNode, middleNode, rightNode);
   currentNode = parentNode;
}


//You can modify anything in here. This is just a basic implementation.
void setup()
{
  //noCursor();
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
  
  createNodes();
 

  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(1520, 720); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  // fullScreen(); //Alternatively, set the size to fullscreen.
  font = createFont("NotoSans-Regular.ttf", 14 * displayDensity);
  textFont(font); //set the font to Noto Sans 14 pt. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!", 400, 200); //output
    text("Total time taken: " + (finishTime - startTime)/1000 + "s", 400, 230); //output
    text("Total letters entered: " + lettersEnteredTotal, 400, 260); //output
    text("Total letters expected: " + lettersExpectedTotal, 400, 290); //output
    text("Total errors entered: " + errorsTotal, 400, 320); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm, 400, 350); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors, 1, 3), 400, 380); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty, 400, 410);
    text("WPM w/ penalty: " + (wpm-penalty), 400, 440); //yes, minus, because higher WPM is better
    return;
  }

  drawWatch(); //draw watch background
   if (currentNode != null){
    currentNode.drawImage();
  }

  // fill(100);
  //// Note: width and height are variables defined by the Processing library. For
  //// more information, please refer to Processing's reference.
  //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  



  //Note: mousePressed here is a variable defined by the Processing library. For
  //more information, please refer to Processing's reference.
  if (startTime==0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 && mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(0);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(0);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string

    //draw very basic next button
    fill(255, 0, 0);
    rect(width-200, height-200, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", width-150, height-150); //draw next label

    //example design draw code
    //fill(255, 0, 0); //red button
    //rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    
    //fill(0, 255, 0); //green button
    //rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    //The entered text should be put inside the 1"x1" square. You can specify a
    //smaller text size here. 1pt is 1/72 inch, so the following formula
    //converts point size to pixel size.
    fill(200);
    textFont(font, (6 * DPIofYourDeviceScreen) / 72);
    text("Entered: " + currentTyped +"|", width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/4); //draw what the user has entered thus far 
    textAlign(CENTER);
    textFont(font); //Reset font size
    
  }


  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}


// NOTE: Triangle coords must be entered all in clockwise or cc order
LastSide getSideTapped(float[] leftRectangleXBounds, float[] middleRectangleXBounds, float[] rightRectangleXBounds, float[] rectangleYBounds) {

  if (mouseX>leftRectangleXBounds[0] && mouseX<leftRectangleXBounds[1] && mouseY<rectangleYBounds[0] && mouseY>rectangleYBounds[1]) return LastSide.LEFT;
  if (mouseX>middleRectangleXBounds[0] && mouseX<middleRectangleXBounds[1] && mouseY <rectangleYBounds[0] && mouseY>rectangleYBounds[1]) return LastSide.MIDDLE;
  if (mouseX>rightRectangleXBounds[0] && mouseX<rightRectangleXBounds[1] && mouseY <rectangleYBounds[0] && mouseY>rectangleYBounds[1]) return LastSide.RIGHT;
  return LastSide.NONE;
}

//Note: void mousePressed() is a callback function defined by the Processing
//library, and it is *different from* the mousePressed variable occurred in the
//draw() function.
void mousePressed() {
  float hw = width/2;
  float hh = height/2;
  float soia50 = sizeOfInputArea*0.50;
  float soia25 = sizeOfInputArea*0.25;
  float soia1667 = sizeOfInputArea*0.1667;
  
  float[] leftRectangleXBounds = {hw-soia50, hw-soia1667};
  float[] middleRectangleXBounds = {hw-soia1667, hw+soia1667};
  float[] rightRectangleXBounds = {hw+soia1667, hw+soia50};
  
  float[] rectangleYBounds = {hh+soia50, hh-soia25};// lowerbound, upperbound  

 
  // If the tap is on the top 80% of the watch face, delete one character.
  if (mouseX >= leftRectangleXBounds[0] && mouseX <= rightRectangleXBounds[1] && mouseY < hh - sizeOfInputArea*0.2  && mouseY > hh - soia50) {
    if (currentTyped.length() > 0) {
      currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
    }
    return; // Do not process any other actions for this tap.
  }
 
  LastSide result = getSideTapped(leftRectangleXBounds, middleRectangleXBounds, rightRectangleXBounds, rectangleYBounds);
  if (result != LastSide.NONE) {
    handleClick(result);
  }


  if (mouseX>width-200 && mouseX<width && mouseY>height-200 && mouseY<height) {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)/1000 + "s"); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}


//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger, 52, 341);
  if (mousePressed)
    fill(0);
  else
    fill(255);
  ellipse(0, 0, 5, 5);

  popMatrix();
}



//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
