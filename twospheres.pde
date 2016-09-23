//User Values
float ballRotation = 3.0;
float changeView = 0.02;
float Zoom = 7.0;

// Create a shader object
PShader shaderToy;


ArduinoInput input;  // Create Arduino input

//-------------------------------------
void setup() {
  size(640, 480, P2D); 
  noStroke();
  background(0); 

  shaderToy = loadShader("myShader.glsl"); // Load our .glsl shader from the /data folder
  shaderToy.set("iResolution", float(width), float(height), 0); // Pass in our xy resolution to iResolution uniform variable in our shader

  input = new ArduinoInput(this); // input from Arduino
}



//-------------------------------------
void update_shader_params() {
  float[] sensorValues = input.getSensor(); // get value from sensor
  
  ballRotation= map(sensorValues[0],0,1023,1.0,15.0); // control Positions of balls
  changeView = map(sensorValues[1],0,1023,0.02,0.3);  // control view of camera
  Zoom = map(sensorValues[2],0,400,0.03,1.0);       // control zoom in

  shaderToy.set("ballrotation", ballRotation); // Pass in our millisecond clock to iGlobalTime uniform variable in our shader
  shaderToy.set("changeView", changeView); // pass in a xy to iResolution uniform variable in our shader 
  shaderToy.set("Zoom", Zoom);
  
}

//-------------------------------------
void draw() {
  update_shader_params(); 
  
  shaderToy = loadShader("myShader.glsl"); // Load our .glsl shader from the /data folder
  shaderToy.set("iResolution", changeView * 5000.0, Zoom * 17000.0, 0); // changing of view based on changeView value and Zoom value
  shaderToy.set("iGlobalTime", ballRotation / 5.0); // iGlobalTime value = ballRotation value / 5.0 
  shaderToy.set("iMouse", changeView); // 
  
  shader(shaderToy); 
  rect(0, 0, width, height); // We draw a rect here for our shader to draw onto
}