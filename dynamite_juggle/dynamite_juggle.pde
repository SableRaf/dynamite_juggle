/*

 * DYNAMITE JUGGLE
 * A social game for one PS Move and any number of players
 * By Raphaël de Courville (Twitter: @sableRaph)
 
 * Distributed under the GRL CreativeCommons license: 
 * http://goo.gl/Ypucq (or see attached file)
 
 * HOW TO PLAY
 * Press the MOVE button to arm the explosive
 * Press the TRIGGER to ignite the fuse
 * Pass the dynamite around
 * If someone passes you the dynamite, you have to take it!
 * Shake the dynamite to make it burn faster!
 * Any player touching the stick when it blows up is out of the game
 * Press START for a brand new stick of TNT
 * The game goes on until one player (or none) remains.
 * The winner of the round gets to launch the new dynamite
 
 * Or make your own rules!
 
 * DISCLAIMER: The creators of Dynamite Juggle are not liable for 
 * an injury to, or death of, a player resulting from the inherent 
 * risk of using high explosive materials for recreationnal purpose.
 
 * PS Move Api By Thomas Perl: http://thp.io/2010/psmove/
 * Sound effects made with Bfxr: http://www.bfxr.net/
 
 */

import io.thp.psmove.*;

import ddf.minim.*;

Minim minim;
AudioPlayer audioArm;
AudioPlayer audioFuse;
AudioPlayer audioBurn;
AudioPlayer audioBlast;

Timer quitTimer;

// Min and Max time before the dynamite goes off (in milliseconds)
int minimumTime = 30000;
int maximumTime = 80000;

PSMove move;

int triggerValue;
boolean isTriggerPressed, isMovePressed, isSquarePressed, isTrianglePressed, isCrossPressed, isCirclePressed, isStartPressed, isSelectPressed, isPsPressed; 

int rumbleLevel;

int shakeCount;

color sphereColor;
int r, g, b;
float glow;

int startRadius = 90; // Initial radius of the on screen time indicator
int radius = startRadius;

Dynamite dynamite;

MoveButton[] moveButtons = new MoveButton[9];  // The move controller has 9 buttons                 



//--- SETUP ---------------------------------------------------------------

void setup() {
  size(100, 100);
  noStroke();
  
  move = new PSMove();    // We need one controller
  sphereColor = color(0); // Default sphere color (0 means ligths off)

  moveInit(); // Create the buttons

  dynamite = new Dynamite(); // Create the dynamite

  // We pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);

  audioArm = minim.loadFile("arm.wav");
  audioFuse = minim.loadFile("fuse.wav");
  audioBurn = minim.loadFile("burn.wav");
  audioBlast = minim.loadFile("blast.wav");

  quitTimer = new Timer(2000); // How long do you need to press the SELECT button to quit the program?

} // SETUP END



//--- DRAW --------------------------------------------------------------

void draw() {
  
  if(!dynamite.isExplosion()) background(200);

  glow = map( sin( frameCount*.05 ), -1, 1, 10, 80 );

  if (dynamite.isSetup()) {
    //println("Setup");
    stopSound("fuse");
    stopSound("blast");
    sphereColor = color( 0, glow, glow );
    if (isMovePressed) {
      dynamite.setFuseLength( minimumTime, maximumTime );
      playSound("arm");
    }
  }

  if (dynamite.isReady()) {
    //println("Ready...");
    int rand = (int)random(220, 255);
    sphereColor = color( rand, 0, 0);
    if (isTriggerPressed)
      dynamite.igniteFuse();
  }

  if (dynamite.isBurning()) {
    //println("The fuse is burning...");
    playSound("fuse");
    int rand = (int)random(100, 200);
    sphereColor = color( rand, rand/2, 0 );
    float _remainingTime = (float)dynamite.getRemainingTime();
    float _fuseLength = dynamite.getFuseLength();
    radius = (int)map( _remainingTime, 0f, _fuseLength, 0f, 90f );
    
    if(dynamite.isShaken()) { // Shaking burns away some more time from the fuse
      playSound("burn");
      dynamite.consume();
      int rand2 = (int)random(200, 255);
      sphereColor = color( rand2, rand2*.7, rand2*.1 );
    } 
    else if(isPlaying("burn")) {
      stopSound("burn");
    }
  }

  if (dynamite.isExplosion()) {
    //println("BOOOOOOOOOOOOOOOM!");
    stopSound("burn");
    stopSound("arm");
    stopSound("fuse");
    playSound("blast");
    int rand = (int)random(0, 255);
    sphereColor = color( rand, rand, rand );
    rumbleLevel = 255;
    int rand2 = (int)random(200,255);
    background( color(rand2,rand2,rand2) ); // show explosion
    radius=0;
  }

  if (dynamite.isFinished()) {
    //println("Press START to play again");
    sphereColor = color( 10, 10, 10 );
    rumbleLevel = 0;
    if (isStartPressed) {
      dynamite.reset();
      radius = startRadius;
    }
  }

  if (isSelectPressed) {
    if (!quitTimer.isRunning())
      quitTimer.start();
    if (quitTimer.isFinished())
      endGame();
  }

  moveUpdate(rumbleLevel, sphereColor);           // Get the buttons value (trigger only) and presses, and update actuators/indicators

  drawColorCircle(sphereColor); // Draw time indicator

} // DRAW END

void drawColorCircle(color c) {
  pushStyle();
  colorMode(HSB);
  stroke( 0,0,255 ); // White outline, for style
  strokeWeight(3);
  
  int alpha = (int)brightness(c);   // Transparency
  
  pushMatrix();                     // Temporary adjustment of the coordinates system
  translate( width*.5, height*.5 ); // To the center
  
  fill( 0,0,255 );                  // Paint any shape that follows white
  ellipse( 0,0,radius,radius );         // Draw a white background circle
  
  fill( c, alpha );                 // Set color & transparency
  ellipse( 0,0,radius,radius );         // Draw the color circle
  
  popMatrix();                      // Forget the adjustment of the coord system
  popStyle();
}

//--- SOUND ------------------------------------------------------

// TO DO: make this more generic

void playSound(String _soundName) {
  if (_soundName == "arm" && !audioArm.isPlaying()) {
    audioArm.play();
  }
  if (_soundName == "burn" && !audioBurn.isPlaying()) {
    audioBurn.loop();
  }
  if (_soundName == "fuse" && !audioFuse.isPlaying()) {
    audioFuse.loop();
  }
  if (_soundName == "blast" && !audioBlast.isPlaying()) {
    audioBlast.play();
  }
}

boolean isPlaying(String _soundName) {
  if (_soundName == "arm" && audioArm.isPlaying()) {
    return true;
  }
  if (_soundName == "burn" && audioBurn.isPlaying()) {
    return true;
  }
  if (_soundName == "fuse" && audioFuse.isPlaying()) {
    return true;
  }
  if (_soundName == "blast" && audioBlast.isPlaying()) {
    return true;
  }
  return false;
}

void stopSound() {
  audioArm.pause();
  audioFuse.pause();
  audioBlast.pause();
}

void stopSound(String _soundName) {
  if (_soundName == "arm") {
    audioArm.rewind();
    audioArm.pause();
  }
  if (_soundName == "burn") {
    audioBurn.rewind();
    audioBurn.pause();
  }
  if (_soundName == "fuse") {
    audioFuse.pause();
  }
  if (_soundName == "blast") {
    audioBlast.rewind();
    audioBlast.pause();
  }
}



//--- MOVE ----------------------------------------------------------

void moveInit() {
  for (int i=0; i<moveButtons.length; i++) {
    moveButtons[i] = new MoveButton();
  }
}

void moveUpdate(int _rumbleLevel, color _sphereColor) {

  float [] ax = {0.f}, ay = {0.f}, az = {0.f};
  float [] gx = {0.f}, gy = {0.f}, gz = {0.f};
  float [] mx = {0.f}, my = {0.f}, mz = {0.f};

  // Read inputs from the move  
  while (move.poll () != 0) {

    move.get_accelerometer_frame(io.thp.psmove.Frame.Frame_SecondHalf, ax, ay, az);
    move.get_gyroscope_frame(io.thp.psmove.Frame.Frame_SecondHalf, gx, gy, gz);
    move.get_magnetometer_vector(mx, my, mz);
    
    detectShake(ax, az); // check if the accelerometers send extreme values

    int trigger = move.get_trigger();
    move.set_leds(0, 255-trigger, trigger);
    moveButtons[0].setValue(trigger);

    int buttons = move.get_buttons();
    if ((buttons & Button.Btn_MOVE.swigValue()) != 0) {
      moveButtons[1].press();
      sphereColor = color((int)(random(255)), 0, 0);
    } 
    else {
      moveButtons[1].release();
      move.set_rumble(0);
    }
    if ((buttons & Button.Btn_SQUARE.swigValue()) != 0) {
      moveButtons[2].press();
    } 
    else {
      moveButtons[2].release();
    }
    if ((buttons & Button.Btn_TRIANGLE.swigValue()) != 0) {
      moveButtons[3].press();
    } 
    else {
      moveButtons[3].release();
    }
    if ((buttons & Button.Btn_CROSS.swigValue()) != 0) {
      moveButtons[4].press();
    } 
    else {
      moveButtons[4].release();
    }
    if ((buttons & Button.Btn_CIRCLE.swigValue()) != 0) {
      moveButtons[5].press();
    } 
    else {
      moveButtons[5].release();
    }
    if ((buttons & Button.Btn_SELECT.swigValue()) != 0) {
      moveButtons[6].press();
    } 
    else {
      moveButtons[6].release();
    }
    if ((buttons & Button.Btn_START.swigValue()) != 0) {
      moveButtons[7].press();
    } 
    else {
      moveButtons[7].release();
    }
    if ((buttons & Button.Btn_PS.swigValue()) != 0) {
      moveButtons[8].press();
    } 
    else {
      moveButtons[8].release();
    }
  }

  // Store the values in conveniently named variables
  triggerValue         = moveButtons[0].value;
  isTriggerPressed     = moveButtons[0].getPressed(); // The trigger is considered pressed if value > 0
  isMovePressed        = moveButtons[1].getPressed();
  isSquarePressed      = moveButtons[2].getPressed();
  isTrianglePressed    = moveButtons[3].getPressed();
  isCrossPressed       = moveButtons[4].getPressed();
  isCirclePressed      = moveButtons[5].getPressed();
  isSelectPressed      = moveButtons[6].getPressed();
  isStartPressed       = moveButtons[7].getPressed();
  isPsPressed          = moveButtons[8].getPressed();

  move.set_rumble(_rumbleLevel);

  r = (int)red(_sphereColor);
  g = (int)green(_sphereColor);
  b = (int)blue(_sphereColor);
  move.set_leds(r, g, b);
  move.update_leds();
}

void moveOff() {
  move.set_rumble(0);
  move.set_leds(0, 0, 0);
  move.update_leds();
}

void detectShake(float [] _xAcc, float [] _zAcc) {
  if(abs(_xAcc[0]) > 1.2 || abs(_zAcc[0]) > 1.2) {
    shakeCount+=2;
  }
  if(shakeCount > 10) {
    //println("Stop shaking me!!");
    dynamite.isShaken(true);
    if(shakeCount > 15) shakeCount=15;
  }
  else {
    dynamite.isShaken(false);
  } 
  if(shakeCount>0) shakeCount--;
}




//--------------------------------------------------------------------

void keyPressed() {
  if (key == 27) { // escape key
    endGame();
  }
}

void endGame() {
  stopSound();   // stop all sounds playing
  moveOff();     // we switch of the sphere and rumble before we quit
  exit();
}

