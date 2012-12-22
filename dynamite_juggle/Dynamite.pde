class Dynamite {
  private Timer timer;
  private Timer explosion;
  
  private boolean isShaken;
  private int fuseLength=-1; // duration of the countdown
  private boolean triggered;

  private int SETUP    = 0;
  private int READY    = 1;
  private int FUSE     = 2;
  private int BOOM     = 3;
  private int END      = 4;
  private int state;

  Dynamite() {
    state = SETUP;
    explosion = new Timer(1000); // set the duration of the explosion (in ms)
    isShaken = false;
  }
  
  public void arm() {
    state = READY;
  }
  
  public String detonatorSuccess( int _triggerValue, ArrayList<Integer> _triggerHistory ) {
    
    ArrayList<Integer> _detonatorHistory = _triggerHistory;
    int _detonatorVal = _triggerValue;
    int _prevDtnVal = _detonatorHistory.get( _detonatorHistory.size()-1 );
    
    // How many zeros in the most recent values of the detonator?
    int _zeroCount = 0;
    for(int i: _detonatorHistory) {
     if(i==0) _zeroCount++; 
    }
    
    //println("triggerValue = "+triggerValue);
    
    // Check if the detonator was pressed swiftly enough...
    if ( _detonatorVal == 255 && _zeroCount >= 1 ) {
      return "success";
    }
    else if( _detonatorVal == 255 && _prevDtnVal < 255) {
      return "failure";
    }
    return "wait";
  }

  public void igniteFuse() {
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
  
  public void consume() {
    timer.decrement();
  }
  
  public void reset() {
    triggered = false;
    state = SETUP;
  }
  
  // --- Getters ---------------------------------

  public int getFuseLength() {
    if ( fuseLength == -1 ) 
      println("No fuse yet. Can't tell length.");
    return fuseLength;
  }

  public int getRemainingTime() {
    return timer.getRemaining();
  }
  
  public String getState() {
    switch(state) {
      case 0: return "Setup";
      case 1: return "Ready";
      case 2: return "Fuse";
      case 3: return "Exploding";
      case 4: return "End";
      default: return "Something went wrong: Invalid state";
    }
  }

  public boolean isSetup() {
    if (state == SETUP) return true;
    return false;
  }

  public boolean isReady() {
    if (state == READY) return true;
    return false;
  }
  
  public boolean isShaken() {
   return isShaken; 
  }
  
  public void shake(boolean _shake) {
   isShaken = _shake; 
  }

  public boolean isBurning() {
    if (state == FUSE) {
      return true;
    }
    return false;
  }

  public boolean isExplosion() {
    if (triggered && timer.isFinished() && state != END) {
      if(state!=BOOM) explosion.start();
      state = BOOM;
      return true;
    }
    return false;
  }

  public boolean isFinished() {
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
  
  // --- Setters ---------------------------------

  public void setFuseLength(int _lengthMin, int _lengthMax ) {
    fuseLength = (int)random(_lengthMin, _lengthMax);
    timer = new Timer(fuseLength);
  }
}

