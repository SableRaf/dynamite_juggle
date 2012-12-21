import ddf.minim.*;

import java.io.File; // Should be fixed in version 2.0b7++

class Audio {

  HashMap<String, AudioPlayer> audioPlayers; 

  Audio(String _folder, String _extension) {
    int _fileCount = countFiles(_folder, _extension);
    audioPlayers = new HashMap<String, AudioPlayer>(_fileCount);
    loadFiles(_folder, _extension);
  }

  void playOnce(String _key) {
    AudioPlayer _player = getAudioPlayer(_key);
    if(!_player.isPlaying()) _player.play();
  }

  void playLoop(String _key) {
    AudioPlayer _player = getAudioPlayer(_key);
    if(!_player.isPlaying())  _player.loop();
  }

  void stopPlay() {
    for(AudioPlayer _player: audioPlayers.values()) {
      if(_player.isPlaying()) _player.pause();
      _player.rewind();
    }
  }

  void stopPlay(String... _keys) {
    for (String _key: _keys) {
      AudioPlayer _player = getAudioPlayer(_key);
      if(_player.isPlaying()) _player.pause();
      _player.rewind();
    }
  }
  
  boolean isPlaying(String _key) {
    AudioPlayer _player = getAudioPlayer(_key);
    boolean _isPlaying = _player.isPlaying();
    return _isPlaying;
  }

  // Returns a specific player or null if not found
  protected AudioPlayer getAudioPlayer(String _key) {
    if (audioPlayers.containsKey(_key)) {
      AudioPlayer _audioPlayer = audioPlayers.get(_key);
      return _audioPlayer;
    }
    return null;
  }

  // Delete the existing keys and reload from folder
  protected void reloadAudioPlayers(String _folder, String _extension) {
    audioPlayers.clear();
    loadFiles(_folder, _extension);
  }

  // Loads the shapes from a folder
  protected void loadFiles(String _folder, String _extension) {
    ArrayList<String> files = listFiles(_folder, _extension);

    for (String _fileName : files) {
      println("Now retrieving "+_fileName+" from "+_folder+" folder.");
      AudioPlayer _audioPlayer = minim.loadFile(_folder+"/"+_fileName);
      if (null != _audioPlayer) {
        String _key = trimFileName(_fileName); // get the name without the extension
        audioPlayers.put( _key, _audioPlayer);           // fill the Hashtable
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
  protected ArrayList<String> listFiles(String folderName, String extention) {
    ArrayList<String> _fileNameList = new ArrayList<String>();
    String folderPath = sketchPath + folderName;
    if (folderPath != null) {
      File file = new File(folderPath);
      File[] files = file.listFiles();
      for (int i = 0; i < files.length; i++) {
        String fileName = files[i].getName();
        int extensionIndex = fileName.lastIndexOf(".");
        if (fileName.substring(extensionIndex + 1).equalsIgnoreCase(extention)) {
          _fileNameList.add(fileName);
          println("Listed new ."+extention+" file > "+ fileName);
        }
        else {
          println("Skipped file (not ."+extention+" file) > "+ fileName);
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

