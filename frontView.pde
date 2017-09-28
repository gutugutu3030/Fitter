class FrontView extends ExtraWindow {
  PApplet apa;
  TouchScreen touchScreen;
  Shaver shaver;
  FrontView(PApplet theApplet, final String theName) {
    super(theApplet, theName, 1920, -1080, 1920, 1080);
    apa=theApplet;
    textSize(100);
    touchScreen=new TouchScreen(this, new Serial(apa, "COM10", 9600));
    touchScreen.setRotate180(true);
    final TouchScreen ts=touchScreen;
    new Thread() {
      public void run() {
        try {
          Thread.sleep(3000);
          ts.start();
          ts.setEnable(true);
        }
        catch(Exception e) {
        }
      }
    }
    .start();
  }
  void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }
  void setup() {
  }
  void draw() {
    background(255);
    pushMatrix();
    try {
      //translate(width/2, height/2);
      //rotateX(radians(mouseY));
      translate(-84, 1151);
      //translate(0, -500);
      scale(1.0*width/w, -1.0*height/h);
      drawLocal();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    popMatrix();

    if (gcode!=null&&gcode.printing) {
      fill(255, 0, 0);
      text(gcode.getTimeString(), 80, 100);
    }
  }
  void drawLocal() {
    //    ellipse(67.31633,5.9259944,10,10);
    stroke(0);
    noFill();
    if (stls!=null) {
      for(DrawSTL stl:stls){
        stl.drawFront(this);
      }
    }
    stroke(0, 0, 255);
    strokeWeight(0.2);
    if (gcode!=null) {
      gcode.drawFront(this);
    }
    if (shaver!=null) {
      if (mousePressed) {
        float pos[]=getPos(mouseX+84, mouseY-1151);
        shaver.add(new PVector(pos[0],pos[1]));
      }
      noFill();
      stroke(0);
      beginShape();
      for (PVector p : shaver.line) {
        vertex(p.x, p.y);
      }
      endShape();
    }
  }
  void mousePressed() {
    shaver=new Shaver();
  }
  void mouseReleased() {
    shaver.fixLine();
    for (DrawSTL stl : stls) {
      shaver.shave(stl);
    }
  }
}

