/*
    Scene class
    Defined using presets json file
    A scene contains :
    - an image template corresponding to stage scenographie
    - 
*/

ArrayList<Scene> scenes;
Scene _activeScene;

class Scene {  
  JSONObject preset;
  PGraphics canvas, animCanvas, gabCanvas;
  int penSize, eraserSize;
  String id, hex, gab;
  color _penColor;
  color penColor;
  char k;
  boolean isDefault, isActive, hasGab;
  PImage gabarit;
  File gabFile;
  PGraphics asset;
  Undo undo;
  Button butt;
  Boolean animate;
  PShape lastShape;
  ArrayList<PVector> lastShapeVertices;
  int shapeX, shapeY, avX, avY;
  
  Scene (JSONObject _preset) {
    preset = _preset;
    id = _preset.getString("name");
    gab = _preset.getString("gab");
    // setup button linked to this scene
    butt = new Button (preset);
    butt.type = "scene";
    buttons.add(butt);
    k = preset.getString("key").charAt(0);

    try {
      if (preset.getBoolean("default") == true) {
        _activeScene = this;
        isActive = true;
        butt.updatePad(butt.onColor);
      }
    }
    catch (Exception e){
      isActive = false;
    }
    
    if (!gab.isEmpty()) {
      hasGab = true;
      String gabPath = "gabarits/" + gab + ".jpg";
      gabFile = new File(dataPath(gabPath));
      if (gabFile.exists()) { gabarit = requestImage(gabPath); }
      else {
        println("ERROR : " + gab+".jpg --> file not found !");
        butt.updatePad(butt.errorColor);
      }
    }
    else { hasGab = false; }

    if (hasGab) {
      // has a gabarit file, so it is a scene with drawing
      gabCanvas = createGraphics(width,height);
      canvas = createGraphics(width,height);
      //animCanvas = createGraphics(width,height);
      penColor = _penColor = color(255,255,255);
      penSize = 2;
      eraserSize = 5;
      animate = false;
      lastShapeVertices = new ArrayList<PVector>();
      lastShape = createShape();
      shapeX = width;
      shapeY = height;
      avX=avY=0;   
      undo = new Undo(30);
    }
  }
  
  // drawing function
  void gabDrawer() {
    gabCanvas.beginDraw();
    if (gabarit != null) {
      if (gabarit.width == 0) println("WAIT : template file for " + id + " is not ready...");
      else if (gabarit.width == -1)  println("ERR : error while loading template file for " + id + " !!");
      else gabCanvas.image(gabarit, 0, 0, width, height);
    }
    gabCanvas.endDraw();
  }
  
  void drawer() {
    // drawing
    canvas.beginDraw();
    if (!animate) {
      //canvas.beginDraw();
      if(gomme == false) {     
        canvas.stroke(_penColor);
        canvas.strokeWeight(penSize);
        //canvas.shape(lastShape);
        if (mousePressed == true) {
          canvas.line(mouseX, mouseY, pmouseX, pmouseY);
          lastShapeVertices.clear();
          lastShape.beginShape();
          lastShape.stroke(penColor);
          lastShape.strokeWeight(penSize);
          lastShape.noFill();
          lastShape.vertex(mouseX, mouseY);
          PVector _vertices = new PVector(mouseX, mouseY);
          lastShapeVertices.add(_vertices);
        }
      }
      else {          
        canvas.stroke(0);
        canvas.strokeWeight(eraserSize);
        if (mousePressed == true) { 
          canvas.line(mouseX, mouseY, pmouseX, pmouseY);
        }
      }
      // end of drawing
    }
    else {
      // wip // not activated
      animCanvas.beginDraw();
      // animation mode
      if (mousePressed) {
        animCanvas.background(0);
        PVector _t = new PVector(mouseX,mouseY);
        //lastShape.translate(_t.x, _t.y);
        animCanvas.shape(lastShape, _t.x, _t.y);
        //lastShape.translate(-_t.x, -_t.y);
      }
      animCanvas.endDraw();
      canvas.image(animCanvas, 0,0);
    }
   canvas.endDraw();
  }
  
  // update pen or eraser size, and corresponding entries in JSON Object / Array
  void updateSizeKeyboard(int k){
    if (k == UP) {
      if (gomme == true && eraserSize < maxEraserSize) eraserSize++;
      else if (gomme == false && penSize < maxPenSize) penSize++;
    }
    else if (k == DOWN) {
      // DOWN
      if (gomme == true && eraserSize > minEraserSize) eraserSize--;
      else if (gomme == false && penSize > minPenSize) penSize--;
    }   
  }
  
  // ----------- undo class for current drawing ----------//
  class Undo {
    // Number of currently available undo and redo snapshots
    int undoSteps=0, redoSteps=0;  
    CircImgCollection images;
    Undo(int levels) {
      images = new CircImgCollection(levels);
    }
    public void takeSnapshot() {
      undoSteps = min(undoSteps+1, images.amount-1);
      // each time we draw we disable redo
      redoSteps = 0;
      images.next();
      images.capture();
    }
    public void undo() {
      if(undoSteps > 0) {
        undoSteps--;
        redoSteps++;
        images.prev();
        images.show();
      }
    }
    public void redo() {
      if(redoSteps > 0) {
        undoSteps++;
        redoSteps--;
        images.next();
        images.show();
      }
    }
  }
  
  class CircImgCollection {
    int amount, current;
    PImage[] img;
    CircImgCollection(int amountOfImages) {
      amount = amountOfImages;
      // Initialize all images as copies of the current display
      img = new PImage[amount];
      for (int i=0; i<amount; i++) {
        img[i] = createImage(width, height, RGB);
        img[i] = get();
      }
    }
    
    void next() {
      current = (current + 1) % amount;
    }
    
    void prev() {
      current = (current - 1 + amount) % amount;
    }
    
    void capture() {
      img[current] = canvas.get();
    }
    
    void show() {
      canvas.beginDraw();
      canvas.background(0);
      canvas.image(img[current], 0, 0); // Draw an image on the PGraphics.
      canvas.endDraw();
    }
  }
  // ----------- MIDI functions ----------//
  
  //------------ end of class drawing --------------------//
}
