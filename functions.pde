/*
  Global functions
*/

void saveScene() {
  _activeScene.canvas.save("data/" + _activeScene.id+"_"+year()+month()+day()+hour()+minute()+".jpg");
  println("Image Saved for "+_activeScene.id);
}

void loadMask () {
  /* 
      old stuff, keeped just in case
      -> load an image "mask" (stored in datas directory) in
  */
  PImage savedMask = loadImage("data/mask.jpg");
  _activeScene.canvas.clear();
  _activeScene.canvas.blend(savedMask, 0, 0, width, height, 0, 0, width, height, ADD);
  println("Mask file loaded");
}

void clearLayer () {
  _activeScene.canvas.clear();
  println("layer cleared\n");
}

void savePresets() {
  /* update activeDrawing vars values to corresponding preset */
  for (int _s = 0; _s < _scenes.size(); _s++) {
    JSONObject tmpScene = _scenes.getJSONObject(_s);
    if (tmpScene.getString("name").matches(_activeScene.id)) {
      tmpScene.setInt("penSize",_activeScene.penSize);
      tmpScene.setInt("eraserSize",_activeScene.eraserSize);
    }
  }
  saveJSONObject(presets, "data/presets.json");
  println("Presets Saved");
}

int[] JSONArrayToIntArray (JSONArray _a) {
  int[] array = new int[_a.size()];
  // Extract numbers from JSON array.
  for (int i = 0; i < _a.size(); ++i) {
      array[i] = _a.getInt(i);
  }
  return array;
}
