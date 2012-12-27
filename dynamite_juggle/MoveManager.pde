
class MoveManager {
  
  int total_connected, unique_connected;
  
  // This is the list where we will store the connected 
  // controllers and their id (MAC address) as a Key.
  private HashMap<String, MoveController> controllers;
  
  // The same controller connected via USB and Bluetooth 
  // shows twice. If enabled, USB controllers will be replaced 
  // with their Bluetooth counterpart when found. Otherwise,
  // it is "first in first served".
  boolean priority_bluetooth = true;
  
  MoveManager() {
    init();
  }
  
  void init() {
    println("Looking for controllers...");
    println("");
    
    total_connected = psmoveapi.count_connected();
    unique_connected = 0; // Number of actual controllers connected (without duplicates)
    
    controllers = new HashMap<String, MoveController>(); // Create the list of controllers

    // This is only fun if we actually have controllers
    if (total_connected == 0) {
      print("WARNING: No controllers connected.");
    }

    // Filter via connection type to avoid duplicates
    for (int i = 0; i<total_connected; i++) {
  
      MoveController move = new MoveController(i);
    
      String id = move.get_serial();
      String connection = move.get_connection_name();
  
      if (!controllers.containsKey(id)) { // Check for duplicates
        try { 
          controllers.put(id, move);        // Add the id (MAC address) and controller to the list
          println("Found "+id+" via "+connection);
        }
        catch (Exception ex) {
          println("Error trying to register Controller #"+i+" with address "+id);
          ex.printStackTrace();
        }
        unique_connected++; // We just added one unique controller
      }
      else {
        if(connection == "Bluetooth" && priority_bluetooth) {
          MoveController duplicate_move = controllers.get(id);
          String duplicate_connection = duplicate_move.get_connection_name(); // 
          
          controllers.put(id, move);     // Overwrite the controller at this id
          println("Found "+id+" via "+connection+" (overwrote "+duplicate_connection+")");
        }
        else {
          println("Found "+id+" via "+connection+" (duplicate ignored)");
        }
      }
    }
  }
  
  void update() {
    for (String id: controllers.keySet()) {
      MoveController move = controllers.get(id);     // Give me the controller with that MAC address
      move.update();
    }
  }
  
  void shutdown() {
    for (String id: controllers.keySet()) {
      MoveController move = controllers.get(id);     // Give me the controller with that MAC address
      move.shutdown();
    }
  }
}
