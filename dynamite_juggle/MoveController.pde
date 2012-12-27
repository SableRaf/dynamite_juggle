class MoveController extends PSMove {

  private String serial;       // What is the MAC adress of the controller?
  private int connection_type; // USB or Bluetooth?
  private int battery_level;   // How much juice left? Is the controller charging?
  private int rumble_level;    // Value for the vibration
  private color sphere_color;
  
  private String connection_name;
  private String battery_name;

  // enum values returned by PSMove.get_battery()
  final int Batt_MIN           = 0x00;
  final int Batt_20Percent     = 0x01;
  final int Batt_40Percent     = 0x02;
  final int Batt_60Percent     = 0x03;
  final int Batt_80Percent     = 0x04;
  final int Batt_MAX           = 0x05;
  final int Batt_CHARGING      = 0xEE;
  final int Batt_CHARGING_DONE = 0xEF;

  // enum values returned by PSMove.connection_type()
  final int Conn_Bluetooth = 0; // if the controller is connected via Bluetooth
  final int Conn_USB       = 1; // if the controller is connected via USB
  final int Conn_Unknown   = 2; // on error
  
  private MoveButton[] moveButtons = new MoveButton[9];  // The move controller has 9 buttons

  boolean isTriggerPressed, isMovePressed, isSquarePressed, isTrianglePressed, isCrossPressed, isCirclePressed, isStartPressed, isSelectPressed, isPsPressed; 
  int trigger_value, previous_trigger_value;
  ArrayList<Integer> trigger_history;

  color sphereColor;
  int r, g, b;

  MoveController(int i) {
    super(i);
    init();
  }

  void init() {
    get_serial();
    getConnection_type();
    get_battery();
    create_buttons();
  }

  void update() {
    get_battery();
    update_buttons();
    super.update_leds();
  }
  
  // Shut down all controllers
  void shutdown() {
    super.set_rumble(0);
    super.set_leds(0, 0, 0);
    super.update_leds();
  }
  
  // Print the current battery level, mac adress and connection type of each controller
  void echo() {     
     println("MAC address: "+serial+ " | Battery "+battery_name+" | Connected via "+connection_name);
  }
  
  // --- Getters & Setters --------------------
  
  void set_sphere_color(color col) {
    sphere_color = col;
  }
  
  color get_sphere_color() {
    return sphere_color;
  }
  
  String get_connection_name() {
    return connection_name;
  }
  
  String get_battery_name() {
    return battery_name;
  }
    

  
  // --- Inherited methods --------------------
  
  String get_serial() {
    serial = super.get_serial(); // Save the serial of the controller
    return serial;
  }
  
  int getConnection_type() {
    connection_type = super.getConnection_type();
    connection_name = connection_toString(connection_type);
    return connection_type;
  }
  
  // Get the current battery level of the controller
  int get_battery() {
    battery_level = super.get_battery(); // Save the battery level of the controller
    battery_name = get_battery_level_name(battery_level);
    return battery_level;
  }
  
  void set_rumble(int level) {
    super.set_rumble(level);
  }
  
  void set_leds() {
    // Just in case the colorMode is HSB, we translate to RGB
    int r = (int) red   ( get_sphere_color() );
    int g = (int) green ( get_sphere_color() );
    int b = (int) blue  ( get_sphere_color() );
    super.set_leds(r, g, b);
  }
  
  // --- Internal methods ---------------------

  protected void create_buttons() {
    for (int i=0; i<moveButtons.length; i++) {
      moveButtons[i] = new MoveButton();
    }  
  }
  
  protected void update_buttons() {
    // Read inputs from the move  
    while (super.poll () != 0) {
      
      // Sensor values
      float [] ax = {0.f}, ay = {0.f}, az = {0.f};
      float [] gx = {0.f}, gy = {0.f}, gz = {0.f};
      float [] mx = {0.f}, my = {0.f}, mz = {0.f};
  
      super.get_accelerometer_frame(io.thp.psmove.Frame.Frame_SecondHalf, ax, ay, az);
      super.get_gyroscope_frame(io.thp.psmove.Frame.Frame_SecondHalf, gx, gy, gz);
      super.get_magnetometer_vector(mx, my, mz);
      
      // Send the values of the sensors to the dynamite
      // TO DO: Dynamite should request these values explicitely
      dynamite.updateMotion(ax, az); 
  
      int trigger = super.get_trigger();
      moveButtons[0].setValue(trigger);
  
      int buttons = super.get_buttons();
      if ((buttons & Button.Btn_MOVE.swigValue()) != 0) {
        moveButtons[1].press();
        sphereColor = color((int)(random(255)), 0, 0);
      } 
      else {
        moveButtons[1].release();
        super.set_rumble(0);
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

    previous_trigger_value = trigger_value; // record the last value
  
    // Save previous trigger values in a list
    trigger_history.add(previous_trigger_value);
    if( trigger_history.size() > 2 + detonatorThreshold ) {
       trigger_history.remove(0);
    }
  
    // Store the values in conveniently named variables
    trigger_value         = moveButtons[0].value;
    isTriggerPressed     = moveButtons[0].getPressed(); // The trigger is considered pressed if value > 0
    isMovePressed        = moveButtons[1].getPressed();
    isSquarePressed      = moveButtons[2].getPressed();
    isTrianglePressed    = moveButtons[3].getPressed();
    isCrossPressed       = moveButtons[4].getPressed();
    isCirclePressed      = moveButtons[5].getPressed();
    isSelectPressed      = moveButtons[6].getPressed();
    isStartPressed       = moveButtons[7].getPressed();
    isPsPressed          = moveButtons[8].getPressed();
  }
  
  // Translate the connection type from int (enum) to a readable form
  protected String connection_toString(int type) {
    switch(type) {
      case Conn_Bluetooth:  return "Bluetooth";
      case Conn_USB :       return "USB";
      case Conn_Unknown :   return "Connection error";
      default:              return "Error in connection_toString()";
    }
  }
  
  // Translate the battery level from int (enum) to a readable form
  protected String get_battery_level_name(int level) {
    switch(level) {
      case Batt_MIN:            return "low";
      case Batt_20Percent :     return "20%";
      case Batt_40Percent :     return "40%";
      case Batt_60Percent :     return "60%";
      case Batt_80Percent :     return "80%";
      case Batt_MAX :           return "100%";
      case Batt_CHARGING :      return "charging...";
      case Batt_CHARGING_DONE : return "fully charged";
      default:                  return "[Error in get_battery_level_name()]";
    }
  }
}

