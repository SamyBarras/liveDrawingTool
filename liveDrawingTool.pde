/*
  Developped by Samy Barras
  samy.barras@gmail.com
  2020.10.07
  
  For Compagnie Za!
  
  v2.4.2
*/

boolean fullscreen = true;
boolean drawCursorPos = false;
boolean gomme  = false;
boolean help  = false;
boolean outputGab = false;
PGraphics gab, syOutput;
PImage output;
int minPenSize, maxPenSize, minEraserSize, maxEraserSize;
// syphon
boolean syphonOutput = true;
import codeanticode.syphon.*;
SyphonServer server;
// OSC
import netP5.*;
import oscP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;
//
JSONObject presets;
JSONArray _tools, _scenes;
//
void settings() {
  if (fullscreen == false) size(1280, 720, P2D);
  else fullScreen(P2D);
  //noSmooth();
}
//
void setup() {
  //
  frameRate(60);
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
      println("--> gabarit file : " + d.gabFile);
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

  syOutput = createGraphics(width, height);
  if (syphonOutput == true) {
    server = new SyphonServer(this, "Za! - Syphon");
  }

  while(_activeScene.gabarit.width <= 0) {
    print(".");
  }
  println();
  if (_activeScene.gabarit.width > 0) {
    _activeScene.gabDrawer();
    println("ready");
  }

  
  oscP5 = new OscP5(this, 3000);
  myRemoteLocation = new NetAddress("127.0.0.1", 8000);
  //
  OscMessage msg = new OscMessage("/cues/Bank-1/columns/1"); // direct control to MadMapper --> go to column 1 
  //msg.add("1");
  oscP5.send(msg,myRemoteLocation);
}

//////////////Draw//////////////
void draw() {
  background(0);
  /* -- */
  // draw active scene layer
  if (_activeScene.hasGab) {
    // if active scene has gabarit, it means it has live drawing, so we draw and output to syphon
    _activeScene.drawer();
    image(_activeScene.canvas, 0, 0);
    image(_activeScene.gabCanvas, 0, 0);
    // syphon output  
    if (syphonOutput == true) {
      // we store corresponding canvas in new clean PImage
      if (outputGab == true) {
        output = _activeScene.gabCanvas.copy();
        strokeWeight(1);
        stroke(255,255,0);
        line(0,0,width,height);
        line(width,0, 0, height);
      }
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
    // cursor and tool visibility
    if (gomme == true) {
      // eraser mode
      noCursor();
      fill(255,0,0);  
      stroke(125,100);
      strokeWeight(1);
      ellipse(mouseX, mouseY, _activeScene.eraserSize, _activeScene.eraserSize);
      //text("Gomme / "+ _activeScene.eraserSize, 40, 80);
    }
    else {
      // pen mode
      cursor(CROSS);
      fill(255);
      stroke(_activeScene._penColor, 125);
      strokeWeight(1);
      ellipse(mouseX, mouseY, _activeScene.penSize, _activeScene.penSize);
      //text("Stylo / " + _activeScene.penSize, 40, 80);
    }
  }
  // show drawing canvas to artist 
  // infos and user tools
  stroke(255);
  strokeWeight(1);
  // show infos
  fill(255,0,0);
  text(_activeScene.gab, 20, 20);
  if (help == true) {
    fill(0,0,0,255);
    strokeWeight(0);
    blendMode(BLEND);
    rect(30, 30, 300, 290);
    fill(255,0,0);
    text(int(frameRate)+"fps", 40, 60);
    text("resolution :   " + width + " / " + height, 40, 80);
    // show help :
    float y = 110;
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
} 
