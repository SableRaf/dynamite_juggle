// Learning Processing
// Daniel Shiffman


class Timer {
 
  boolean running;
  
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last
  
  int passedTime;
  int penalty;
  
  Timer(int _TotalTime) {
    totalTime = _TotalTime;
    running = false;
    penalty = 0;
  }
  
  // Starting the timer
  void start() {
    running = true;
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }
  
  // The function isFinished() returns true if totalTime has passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    passedTime = millis() + penalty - savedTime;
    if (passedTime > totalTime) {
      running = false;
      return true;
    } else {
      return false;
    }
   }
   
   boolean isRunning() {
     return running;
   }
   
   int getRemaining() {
     int remaining = totalTime - passedTime;
     return remaining;
   }
   
   void decrement() {
     penalty+=100;
   }
   
 }
