boolean debugMode=false;







import processing.serial.*;
import java.util.regex.*;

FixStroke fixer=new FixStroke();
TouchScreen touchScreen;
GCode gcode;
CameraView camera;
ArrayList<DrawSTL> stls;
Serial printer=null;
Control control;
FrontView front;
PVector currentPosition=new PVector();
int w=163;//152;//ミリ
int h=91;//83;//ミリ
boolean enableFront=false;

boolean mode=true;//false:指輪　true:teddy
int mouseStatus =-1;//0:中を掴んでいる 1~4:枠を掴んでいる
DrawSTL mouseObj=null;

ArrayList<PVector> line=null;
int mouseButtonBuffer=-1;
Teddy teddy;



PImage screenShot;
boolean hastoshot;


void setup() {
  size(1920, 1080, P3D);
  stls=new ArrayList<DrawSTL>();
  control=new Control(this, "Controller");
  if (!debugMode) {
    if (enableFront) {
      front=new FrontView(this, "正面図");
    }
    camera=new CameraView(this, "カメラ");
    touchScreen=new TouchScreen(this, new Serial(this, "COM8", 9600));
    final TouchScreen ts=touchScreen;
    screenShot=createImage(width, height, RGB);
    for (int i=0; i<screenShot.pixels.length; i++) {
      screenShot.pixels[i]=0xFFFFFFFF;
    }
    screenShot.updatePixels();
    new Thread() {
      public void run() {
        try {
          Thread.sleep(3000);
          ts.start();
          //ts.setEnable(true);
        }
        catch(Exception e) {
        }
      }
    }
    .start();
  }
  textSize(48);
  textAlign(LEFT, CENTER);
}

//void exit(){
//  gcode.exit();
//  super.exit();
//}

void draw() {
  if (debugMode) {
    background(255);
  } else {
    if (camera!=null&&line==null) {
      if (hastoshot) {
        hastoshot=false;
        //camera.drawCam(60, 33, 1799, 1015);
        camera.drawCam(12, 19, 1827, 1045);
        loadPixels();
        for (int i=0; i<pixels.length; i++) {
          screenShot.pixels[i]=pixels[i];
        }
        screenShot.updatePixels();
      }
      image(screenShot, 0, 0, width, height);
    }
    if (camera==null) {
      background(255);
    }
  }
  pushMatrix();
  try {
    //translate(width/2, height/2);
    //rotateX(radians(mouseY));
    //background(255);
    
    translate(-35/*-84*/, 1233-64);
    //translate(-12,1045-19);
    scale(1.0*width/w, -1.0*height/h);
    drawLocal();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  popMatrix();
  stroke(0);
  fill(#A7F7DF);
  rect(width-250, 0, 250, 250);
  rect(width-250, 250, 250, 250);
  rect(width-250, 500, 250, 250);  
  fill(255, 0, 0);
  text("Trace", width-240, 125);
  text("Load", width-240, 125+250);
  text("Print", width-240, 125+500);
}
void drawLocal() {
  float mouse[]=getMousePos();
  if (line!=null) {
    line.add(new PVector(mouse[0], mouse[1]));
    if (line.size()==1) {
      if (camera==null) {
        background(255);
      } else {
        image(screenShot, 0, 0, width, height);
      }
    }
    noFill();
    beginShape();
    for (PVector pv : line) {
      vertex(pv.x, pv.y);
    }
    endShape();
    return;
  }
  if (!mode) {
    for (DrawSTL stl : stls) {
      stl.draw();
      switch(mouseStatus) {
      case 0:
        float newMousePos[]=getMousePos();
        //      float diff[]=getPos(mouseX-pmouseX, mouseY-pmouseY);
        //      mouseObj.setXYDiff(diff[0], diff[1]);
        mouseObj.setXYDiff(newMousePos[0]-oldMousePos[0], newMousePos[1]-oldMousePos[1]);
        oldMousePos=newMousePos;
        break;
      case 1:
      case 2:
      case 3:
      case 4:
      println("mouseStatus:"+mouseStatus);
        mouseObj.setTAuto(mouse, mouseStatus, (keyPressed&&keyCode==SHIFT));
        break;
      }
    }
    return;
  }
  if (teddy!=null) {
    teddy.draw();
  }
}
float[] getPos(float x, float y) {
  return new float[] {
    x*w/width, -y*h/height
  };
}
float[] getMousePos() {
  float mouse[]=mouse();
  //translate(-35/*-84*/, 1233-64);
  return getPos(mouse[0]+35, mouse[1]-(1233-64));
}
float[] mouse() {
  if (debugMode) {
    return new float[] {
      mouseX, mouseY
    };
  }
  PVector xy=touchScreen.get();
  if (touchScreen.isEnable()&&xy!=null) {
    return new float[] {
      xy.x, xy.y
    };
  }
  return new float[] {
    mouseX, mouseY
  };
}
float oldMousePos[]= {
  0, 0
};
void mousePressed() {
  float mouse1[]=mouse();
  if (mouse1[0]>width-250) {
    switch((int)mouse1[1]/250) {
    case 0:
      if (!debugMode) {
        camera.copy();
        hastoshot=true;
      }
      break;
    case 1:
      mode=false;//STL読み込みモードに変更
      stls.add(new DrawSTL(searchLatestSTL(sketchPath).getAbsolutePath(),true));
      break;
    case 2:
      try {
        Thread.sleep(2000);
      }
      catch(Exception e) {
      }
      control.startPrint();
      break;
    case 3:
      teddy=null;
      stls=new ArrayList<DrawSTL>();
      break;
    }
    return;
  }
  if (mode) {
    stls.clear();
    line=new ArrayList<PVector>();
    mouseButtonBuffer=mouseButton;
  } else {
    float mouse[]=getMousePos();
    for (DrawSTL stl : stls) {
      mouseStatus=stl.ifonTheOutLine(mouse[0], mouse[1]);
      if (mouseStatus!=-1) {
        mouseObj=stl;
        return;
      }
      if (stl.ifin(mouse[0], mouse[1])) {
        mouseObj=stl;
        mouseStatus=0;
        oldMousePos=mouse;
        return;
      }
    }
  }
}
void mousePressed(float x, float y) {
  mousePressed();
}
void mouseReleased() {
  mouseStatus=-1;
  mouseObj=null;
  if (line!=null) {
    stls.clear();
    int creationType=control.creationType.getSelectedIndex();
    if (control.creationType.getSelectedItem().equals("auto")) {
      if (line.get(0).dist(line.get(line.size()-1))<8) {
        println("わっか");
        creationType=2;
      } else {
        creationType=3;
      }
    }
    teddy=new Teddy(line, creationType, strokeFixer);
    if (teddy.isReady()) {
      new MakeGCode().start();
    }
    line=null;
  }
}
void mouseReleased(float x, float y) {
  mouseReleased();
}
StringBuilder sb=null;
Pattern getXPattern=Pattern.compile("(?<=X:\\s)\\d+\\.\\d+");
Pattern getYPattern=Pattern.compile("(?<=Y:)\\d+\\.\\d+");
Pattern getZPattern=Pattern.compile("(?<=Z:)\\d+\\.\\d+");
void serialEvent(Serial thisPort) {
  if (touchScreen.serialEvent(thisPort)) {
    return;
  }
  if (enableFront&&front.touchScreen.serialEvent(thisPort)) {
    return;
  }
  if (sb==null) {
    sb=new StringBuilder();
  }
  String readSt=thisPort.readString();
  if (readSt.equals("\n")) {
    //println(sb);
    String str=sb.toString();
    if (str.indexOf("T:")!=-1) {
      //温度測定命令
      control.temp.setText(str.split(" ")[1].split(":")[1]+"℃");
    } else if (str.indexOf("Count")!=-1) {
      //座標指定命令
      String position=str.split("Count")[1];
      Matcher m;
      m = getXPattern.matcher(position);
      m.find();
      currentPosition.x=Float.parseFloat(m.group());
      m = getYPattern.matcher(position);
      m.find();
      currentPosition.y=Float.parseFloat(m.group());
      m = getZPattern.matcher(position);
      m.find();
      currentPosition.z=Float.parseFloat(m.group());
    } else if (str.equals("ok")) {
      println(str);
      control.serialReady=true;
      if (gcode!=null) {
        gcode.getOKFromPrinter();
      }
    } else {
      println(str);
    }
    sb=null;
    return;
  }
  sb.append(readSt);
}

void comparea() {
  float t, s;
  {
    float min=1000000, max=-1000000;
    for (PVector p : teddy.model.points) {
      min=min(p.y, min);
      max=max(p.y, max);
    }
    t=max-min;
  }
  {
    float min=1000000, max=-1000000;
    for (PVector p : stls.get (0).vertex) {
      min=min(p.y, min);
      max=max(p.y, max);
    }
    s=max-min;
  }
}

