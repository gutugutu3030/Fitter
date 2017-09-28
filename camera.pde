import processing.video.*;
class CameraView extends ExtraWindow {
  PApplet apa;
  Capture cam;
  int rect[][];
  int grab[]=null;
  PImage img=null;
  CameraView(PApplet theApplet, final String theName) {
    super(theApplet, theName, 0, 300, 640, 480);
    apa=theApplet;
  }
  void windowClosing(WindowEvent e) {
    apa.exit();  
    super.windowClosing(e);
  }
  void setup() {
    cam=new Capture(this, width, height);
    cam.start();
//    rect=new int[4][];
//    rect[0]=new int[] {
//      50, 50
//    };
//    rect[1]=new int[] {
//      width-50, 50
//    };
//    rect[2]=new int[] {
//      width-50, height-50
//    };
//    rect[3]=new int[] {
//      50, height-50
//    };
loadRect();
  }
  void loadRect(){
    String data[]=loadStrings(apa.dataPath("camera.txt"));
    rect=new int[4][2];
    for(int i=0;i<8;i++){
      rect[i/2][i%2]=Integer.parseInt(data[i]);
    }
  }
  void draw() {
    if (!cam.available())return;
    cam.read();
    image(cam, 0, 0);
    strokeWeight(5);
    stroke(255, 0, 0);
    noFill();
    beginShape();
    for (int p[] : rect) {
      vertex(p[0], p[1]);
    }
    endShape(CLOSE);
    strokeWeight(1);
    if (grab!=null) {
      grab[0]=mouseX;
      grab[1]=mouseY;
    }
  }
  void mousePressed() {
    if (mouseButton==LEFT) {
      for (int p[] : rect) {
        if (dist(p[0], p[1], mouseX, mouseY)<10) {
          grab=p;
          return;
        }
      }
    } else {
      copy();
    }
  }
  void copy() {
    img=createImage(width, height, RGB);
    loadPixels();
    for (int i=0; i<pixels.length; i++) {
      img.pixels[i]=pixels[i];
    }
    img.updatePixels();
  }
  void mouseReleased() {
    grab=null;
    saveRect();
  }
  void saveRect(){
    String data[]=new String[8];
    for(int i=0;i<8;i++){
      data[i]=""+rect[i/2][i%2];
    }
    saveStrings(apa.dataPath("camera.txt"),data);
  }
  void drawCam(PApplet apa, float x, float y, float w, float h) {
    if (img==null) {
      return;
    }
    /*
    float pos[][]= {
     {
     x, y
     }
     , {
     x+w, y
     }
     , {
     x+w, y+h
     }
     , {
     x, y+h
     }
     };
     */
    float pos[][]= {
      {
        x+w, y+h
      }
      , {
        x, y+h
      }
      , 
      {
        x, y
      }
      , {
        x+w, y
      }
    };
    apa.beginShape();
    apa.texture(img);
    for (int i=0; i<4; i++) {
      apa.vertex(pos[i][0], pos[i][1], rect[i][0], rect[i][1]);
    }
    apa.endShape();
    apa.save(dataPath("tmp.png"));
  }
  void drawCam(float x, float y, float w, float h) {
    drawCam(apa, x, y, w, h);
  }
}

