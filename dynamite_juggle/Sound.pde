import ddf.minim.*;

import java.io.File; // Should be fixed in version 2.0b7++

class Audio {

  private String folder, extension;


  HashMap<String, AudioPlayer> audioPlayers; 

  Audio(String _folder, String _extension) {
    folder    = _folder;
    extension = _extension;
    int _fileCount = countFiles(_folder, _extension);
    audioPlayers = new HashMap<String, AudioPlayer>(_fileCount);
    loadFiles(_folder, _extension);
  }

  void playOnce(String _key) {
    if (audioPlayers.containsKey(_key)) { // Is that a valid key?
      AudioPlayer _player = getAudioPlayer(_key);
      if (null!=_player) { // Is there a value corresponding to that key?
        if (!_player.isPlaying()) 
          _player.play(0);
      }
      else {
        println("Error: playOnce(\""+_key+"\") > no value in audioPlayers Hashmap for \""+_key+"\"");
      }
    }
    else {
      println("Error: playOnce(\""+_key+"\") > no such key in audioPlayers HashMap.");
    }
  }

  void playLoop(String _key) {
    if (audioPlayers.containsKey(_key)) { // Is that a valid key?
      AudioPlayer _player = getAudioPlayer(_key);

      if (null!=_player) { // Is there a value corresponding to that key?
        if (!_player.isPlaying())  
          _player.loop();
      }
      else {
        println("Error: playLoop(\""+_key+"\") > no value in audioPlayers Hashmap for \""+_key+"\"");
      }
    }
    else {
      println("Error: playLoop(\""+_key+"\") > no such key in audioPlayers HashMap.");
    }
  }

  void stop() {
    for (String _key: audioPlayers.keySet()) {
      if (audioPlayers.containsKey(_key)) { // Is that a valid key?
        AudioPlayer _player = getAudioPlayer(_key);

        if ( null!=_player ) { // Is there a value corresponding to that key?
          if (_player.isPlaying()) 
            _player.pause();

          _player.rewind();
        }
        else {
          println("Error: stop() > no value in audioPlayers Hashmap for \""+_key+"\"");
        }
      }
      else {
        println("Error: stop() \""+_key+"\" > no such key in audioPlayers HashMap.");
      }
    }
  }

  void stopPlay(String... _keys) {
    for (String _key: _keys) {
      if (audioPlayers.containsKey(_key)) { // Is that a valid key?
        AudioPlayer _player = getAudioPlayer(_key);
        if ( null!=_player ) { // Is there a value corresponding to that key?
          if (_player.isPlaying()) 
            _player.pause();

          _player.rewind();
        }  
        else {
          println("Error: stopPlay(\""+_key+"\") > no value in audioPlayers Hashmap for \""+_key+"\"");
        }
      }
      else {
        println("Error: stopPlay(\""+_key+"\") > no such key in audioPlayers HashMap.");
      }
    }
  }

  boolean isPlaying(String _key) {
    if (audioPlayers.containsKey(_key)) { // Is that a valid key?
      AudioPlayer _player = getAudioPlayer(_key);
      if ( null != _player) { // Is there a value corresponding to that key?
        boolean _isPlaying = _player.isPlaying();
        return _isPlaying;
      }
      else {
        println("Error: isPlaying(\""+_key+"\") > no value in audioPlayers Hashmap for \""+_key+"\"");
        return false;
      }
    }
    else {
      println("Error: isPlaying(\""+_key+"\") > no such key in audioPlayers HashMap.");
      return false;
    }
  }

  void close() {
    println("Closing all players");
    for (String _key: audioPlayers.keySet()) {
      AudioPlayer _player = getAudioPlayer(_key);
      if (null!=_player) { // Is there a value corresponding to that key?
        println("closing \""+ _key +"\" AudioPlayer...");
        try {
          _player.close();
        } 
        catch (Exception ex) {
          println("Could not close player \""+_key+"\"");
        }
      }
    }
  }

  // Returns a specific player or null if not found
  protected AudioPlayer getAudioPlayer(String _key) {
    if (audioPlayers.containsKey(_key)) {
      try {
        AudioPlayer _audioPlayer = audioPlayers.get(_key);
        if (null!= _audioPlayer) // Is there a value corresponding to that key?
          return _audioPlayer;
      }
      catch (Exception ex) {
        println("Could not retrieve player \""+_key+"\"");
      }
    }
    return null;
  }

  // Delete the existing keys and reload from folder
  protected void reloadAudioPlayers(String _folder, String _extension) {
    audioPlayers.clear();
    loadFiles(_folder, _extension);
  }

  // Loads the files from a folder
  protected void loadFiles(String _folder, String _extension) {
    ArrayList<String> files = listFiles(_folder, _extension);

    for (String _fileName : files) {
      String _key = trimFileName(_fileName); // get the name without the extension
      println("Creating AudioPlayer > \""+_key+"\"");
      AudioPlayer _player = minim.loadFile(_folder+"/"+_fileName);
      if (null != _player) {
        audioPlayers.put( _key, _player);           // fill the Hashtable
      }
      else {
        println("Error: file "+ _fileName +" does not exist or is not a valid "+_extension+".");
      }
    }
  }

  // Return the file name without the extension (e.g. "foo.wav" -> "foo")
  protected String trimFileName( String _fileName ) {
    int _extensionIndex = _fileName.lastIndexOf(".");
    String _trimmedName  = _fileName.substring(0, _extensionIndex);
    return _trimmedName;
  }

  // Lists the files with a given extentions in a certain folder
  protected ArrayList<String> listFiles(String _folderName, String _extention) {
    ArrayList<String> _fileNameList = new ArrayList<String>();
    String folderPath = sketchPath + _folderName;
    if (folderPath != null) {
      File file = new File(folderPath);
      File[] files = file.listFiles();
      for (int i = 0; i < files.length; i++) {
        String _fileName = files[i].getName();
        int extensionIndex = _fileName.lastIndexOf(".");
        if (_fileName.substring(extensionIndex + 1).equalsIgnoreCase(_extention)) {
          _fileNameList.add(_fileName);
          println("Listed new ."+_extention+" file > "+_folderName+"/"+_fileName);
        }
        else {
          println("Skipped file (not ."+_extention+" file) > "+_folderName+"/"+ _fileName);
        }
      }
    }
    return _fileNameList;
  }

  protected int countFiles(String _folderName, String _extention) {
    String _folderPath = sketchPath + _folderName;
    File _file = new File(_folderPath);
    File[] _files = _file.listFiles();
    int _fileCount = _files.length;
    String _plural = ""; 
    if (_fileCount>1) _plural = "s";
    println("We found "+_fileCount+" ."+_extention+" file"+_plural+" in the "+_folderName+" folder.");
    return _fileCount; // put the counting algorithm here
  }
}

