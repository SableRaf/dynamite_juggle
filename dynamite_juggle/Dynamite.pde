class Dynamite {
  Timer timer;
  Timer explosion;

  int fuseLength=-1; // duration of the countdown

  int SETUP    = 0;
  int READY    = 1;
  int FUSE     = 2;
  int BOOM     = 3;
  int END      = 4;
  int state;

  boolean triggered;

  Dynamite() {
    state = SETUP;
    explosion = new Timer(1000); // set the duration of the explosion (in ms)
  }

  void setFuseLength(int _lengthMin, int _lengthMax ) {
    fuseLength = (int)random(_lengthMin, _lengthMax);
    timer = new Timer(fuseLength);
    state = READY;
  }

  int getFuseLength() {
    if ( fuseLength == -1 ) 
      println("No fuse yet. Can't tell length.");
    return fuseLength;
  }

  int getRemainingTime() {
    return timer.getRemaining();
  }
  
  void consume() {
    timer.decrement();
  }

  void igniteFuse() {
    if (null!=timer) {
      println("started the fuse");
      timer.start();
      state = FUSE;
      triggered = true;
    }
    else {
      println("You have to choose a fuse length before you can ignite it.");
    }
  }

  boolean isSetup() {
    if (state == SETUP) return true;
    return false;
  }

  boolean isReady() {
    if (state == READY) return true;
    return false;
  }

  boolean isBurning() {
    if (state == FUSE) {
      return true;
    }
    return false;
  }

  boolean isExplosion() {
    if (triggered && timer.isFinished() && state != END) {
      if(state!=BOOM) explosion.start();
      state = BOOM;
      return true;
    }
    return false;
  }

  boolean isFinished() {
    if (state == BOOM && explosion.isFinished()) 
    { 
      state = END;
      return true;
    }
    else if ( state == END )
    {
      return true;
    }
    return false;
  }

  void reset() {
    triggered = false;
    state = SETUP;
  }
}

