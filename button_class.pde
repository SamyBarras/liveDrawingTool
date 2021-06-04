import themidibus.*;
import javax.sound.midi.MidiMessage;
//import javax.sound.midi.SysexMessage;
//import javax.sound.midi.ShortMessage;
MidiBus myBus;
ArrayList<Button> buttons;

class Button {
  int channel, status, num, col, onColor, offColor, errorColor, data;
  String id, type;
  JSONObject bDatas;
  
  Button (JSONObject _b) {
    id = _b.getString("name");
    bDatas = _b.getJSONObject("button");
    channel = bDatas.getInt("channel");
    status = bDatas.getInt("status");
    num = bDatas.getInt("num");
    onColor = bDatas.getInt("on");
    offColor = bDatas.getInt("off");
    errorColor = bDatas.getInt("error");
    
    try {
      type = _b.getString("type");
    }
    catch (Exception e){
      type = "";
      println("error with button "+id);
    }
    
    try {
      if (_b.getBoolean("default") == true) updatePad(onColor);
      else updatePad(offColor);
    }
    catch (Exception e){
      updatePad(offColor);
    }
    
    data = 0; // button's value received by midi message
  }
  
  void updatePad(int _v) {
    myBus.sendMessage(status, channel, num, _v);    
  }
  
  void triggerButtonValue (int _v) {
    // update data value ((int) button's value from midi message)
    data = _v;
    // update buttons color
    updatePad(onColor);
    for (Button _b : buttons) {
      if (_b.type.matches(type)) {
        if (_b.num != num) { _b.updatePad(_b.offColor); }
      }
    }
    
    if (type.matches("scene")) {
      for (Scene d : scenes){
        if (d.id.matches(id)) {
          _activeScene = d;
          _activeScene.gabDrawer();
          break;
        }
      }
    }
    else {
      switch (id) {
        case ("pen_button") :
          gomme = false;
          break;
        case ("eraser_button") :
          gomme = true;
          break;
        case ("eraser_size") :
          if (gomme == true) _activeScene.eraserSize =  (int)map(data, 0, 127, minEraserSize, maxEraserSize);
          break;
        case ("pen_size"):
          if (gomme == false) _activeScene.penSize =  (int)map(data, 0, 127, minPenSize, maxPenSize);
          break;
        case ("clear_button"):
          clearLayer();
          break;
        case ("save_button"):
          saveScene();
          savePresets();
          break;
        case ("ctrl-z"):
          _activeScene.undo.undo();
          break;
        case ("ctrl-shift-z"):
          _activeScene.undo.redo();
          break;
        case ("show-gab"):
          // invert
          if (outputGab == true) updatePad(offColor);
          else updatePad(onColor);
          outputGab = !outputGab;
          println("show gab : " + outputGab);
          break;
        default :
          println("unknown button : " + num + " -- " + data);
      }
    }
  }
}


void rawMidi(byte[] data) {
 
  int _s = (int)(data[0] & 0xFF);
  int _n = (int)(data[1] & 0xFF);
  int _v = (int)(data[2] & 0xFF);
  //println(_s + " - " + _n + " - " + _v + " - ");
  for (Button _b : buttons) {
    if (_b.status == _s && _b.num == _n) {
      _b.triggerButtonValue(_v);
    }
  }
  
}
