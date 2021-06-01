/*
  Developped by Samy Barras
  samy.barras@gmail.com
  2020.10.07
  
  For Compagnie Za!
  
  v2.3
  UPDATES 2.3 :
  - clean and update part of code for syphon output with mirrored image
  - button to show / hide scenes gabarit into syphon output (it helps for projection mapping !)
  - pen and eraser size mapped values to Akai Midi
  
  UPDATES 2.2 :
  - implementation of scenes and image template
  - end of presets for pen_color 
  - asynchronous loading for template image files
  
  UPDATES 2.1 :
  - implementation of "AKAI APC mini" Pad for external control of sketch
  - control pad's buttons colors (lights) (madmapper & processing)
  
  UPDATES 2.0 :
  - presets for scenes including pen color and size, eraser size, layers
  - undo / redo option for each layer / drawing
  - external files for presets and help
  - adapted for app exported version (data dir)
  
*/

boolean drawCursorPos = false;
boolean gomme  = false;
boolean help  = false;
boolean outputGab = false;
PGraphics gab, syOutput;
int minPenSize, maxPenSize, minEraserSize, maxEraserSize;
// syphon
boolean syphonOutput = true;
import codeanticode.syphon.*;
SyphonServer server;

//
JSONObject presets;
JSONArray _tools, _scenes;
//
void settings() {
  //size(1280, 720, P3D);
  fullScreen(P2D);
  noSmooth();
}
//
void setup() {
  //
  frameRate(24);
  blendMode(ADD);
  background(0);
  //MidiBus.list();
  myBus = new MidiBus(this, "APC MINI", "APC MINI");
  myBus.sendTimestamps(false);
  //
  presets = loadJSONObject("data/presets.json");
  _tools = presets.getJSONArray("tools");
  _scenes = presets.getJSONArray("scenes");
  scenes = new ArrayList<Scene>();
  scenes.clear();
  buttons = new ArrayList<Button>();
  buttons.clear();
  // populate arrays
  for (int s=0; s < _scenes.size(); s++) {
    JSONObject _s = _scenes.getJSONObject(s);
    Scene d = new Scene(_s);
    println(d.id + " loaded");
    if (!d.gab.isEmpty()) {
      scenes.add(d);
      println("gabarit file : " + d.gabFile);
    }
  }
  for (int t=0; t < _tools.size(); t++) {
    JSONObject _t = _tools.getJSONObject(t);
    Button b = new Button (_t);
    buttons.add(b);
    // define min and max size for tools according to preset file
    if (b.id.matches("pen_size")) {
      minPenSize = _t.getInt("min");
      maxPenSize = _t.getInt("max");
    }
    if (b.id.matches("eraser_size")) {
      minEraserSize = _t.getInt("min");
      maxEraserSize = _t.getInt("max");
    }
  }
  syOutput = createGraphics(width,height);
  if (syphonOutput == true) {
    server = new SyphonServer(this, "Za! - Syphon");
  }
}

//////////////Draw//////////////
void draw() {
  background(0);
  /* -- */
  // draw active scene layer
  _activeScene.gabDrawer();
  image(_activeScene.gabCanvas,0,0); 
  _activeScene.drawer();  
  image(_activeScene.canvas,0,0); 
  // syphon output
  
  if (syphonOutput == true) {
    PImage output;
    // we store corresponding canvas in new clean PImage
    if (outputGab == true) output = _activeScene.gabCanvas.copy();
    else output = _activeScene.canvas.copy();
    // flip image --> syphon is flipping image so we do have to correct that
    PImage mirror = createImage(width, height, RGB);       // make a empty image half size            
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        mirror.set(x, output.height-y-1, output.get(x,y));
      }
    }
    server.sendImage(mirror);
  }
  
  // show drawing canvas to artist 
  // infos and user tools
  stroke(255);
  strokeWeight(1);
  fill(255,0,0);
  text(int(frameRate)+"fps", 40, 30);
  text("layer :   " + _activeScene.id, 40, 60);
  if (gomme) text("Gomme / "+ _activeScene.eraserSize, 40, 80);
  else text("Stylo / " + _activeScene.penSize, 40, 80);
    
  if (help == true) {
    // show help :
    float y = 120;
    JSONArray help = loadJSONArray("data/help.json");  // help is loaded from json file
    text("help : ", 40, y);
    for (int o = 0; o < help.size(); o++){
      text(help.getString(o), 40, y+(o+1)*20);
    }
  }
  if (drawCursorPos == true) {
    line(0, mouseY, width, mouseY); // y
    line(mouseX, 0, mouseX, height); // x
  }
  // cursor and tool visibility
  if (gomme == true) {
    // eraser mode
    noCursor();
    fill(255,0,0);  
    stroke(125,100);
    strokeWeight(1);
    ellipse(mouseX, mouseY, _activeScene.eraserSize, _activeScene.eraserSize);
  }
  else {
    // pen mode
    cursor(CROSS);
    fill(255);
    stroke(_activeScene._penColor, 125);
    strokeWeight(1);
    ellipse(mouseX, mouseY, _activeScene.penSize, _activeScene.penSize);
  }
} 
