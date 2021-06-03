boolean controlDown = false;
boolean shiftDown = false;
boolean commandDown = false;
boolean showGab = false;

void keyPressed() {
  switch(keyCode) {
    case UP :
      _activeScene.updateSizeKeyboard(keyCode);
      break;
    case DOWN :
      _activeScene.updateSizeKeyboard(keyCode);
      break;
    case CONTROL:
      controlDown = true;
      break;
    case 157 :  // CMD key for mac
      commandDown = true;
      break;
    case SHIFT:
      shiftDown = true;
      break;
  }
  if (controlDown == true || commandDown == true) {
    switch (key) {
      case 'Z' :
        _activeScene.undo.redo();
        break;
      case 'S' :
        saveScene();
        break;
      case 'z' :
        _activeScene.undo.undo();
        break;
      case 's' :
        savePresets();
        break;
      case 'g' :
        showGab = !showGab;
        break;
    }
    return;
  }
  else {
    // check if user wants to change of drawing preset
    /*
    // the use of keyboard button for Scene selection is disabled if this block is commented
    for (Scene d : scenes){
      if (d.k == key) {
        _activeScene = d;
        _activeScene.gabDrawer();
        break;
      }
    }
    */
   switch(key) {
      case 'g':
        gomme = !gomme;
        break;
      case 'c' :
        clearLayer();
        break;
      case 'h' :
        // show/hide infos help
        help = !help;
        break;
      case '-' :
        // drawCursorPos = !drawCursorPos; // not necessary animore
        //_activeScene.animate = !_activeScene.animate;
        println("animate ?");
        break;
      case '$' :
        outputGab = !outputGab;
        break;
      case 'm' :
        drawCursorPos = !drawCursorPos;
        break;
    }
  }
}

void keyReleased() {
  switch(keyCode) {
    case CONTROL:
      controlDown = false;
      break;
    case 157 :
      commandDown = false;
      break;
    case SHIFT :
      shiftDown = false;
      break;
  }
}

boolean prevGommeState = gomme;
void mousePressed() {
  if (mouseButton == RIGHT && gomme == false) {
    prevGommeState = gomme;
    gomme = true;
  }
  if (gomme == false) {
    if (_activeScene.animate == false) {
      _activeScene.lastShape = createShape();
    }
  }
}
PVector mouseclicPose = new PVector(0,0);
void mouseClicked() {
  mouseclicPose.x = mouseX;
  mouseclicPose.y = mouseY;
}
void mouseDragged() {
  if (gomme == false) {
    if (_activeScene.animate == false) {
      //
    }
    
  }
}
void mouseReleased() {
  if (mouseButton == RIGHT && prevGommeState == false) gomme = false;
  _activeScene.undo.takeSnapshot();
  if (gomme == false &&_activeScene.animate == false) {
    _activeScene.lastShape.endShape();
  }
}