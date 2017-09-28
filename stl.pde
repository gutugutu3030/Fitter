import readTextLine.*;
import java.nio.ByteBuffer;
import java.io.*;
import xyz.gutugutu3030.stl.*;


boolean forcePosition=true;

class MakeGCode extends Thread {
  public void run() {
    gcode=null;
    stls=new ArrayList<DrawSTL>();
    teddy.model.save("tmp1");
    stls.add(new DrawSTL(dataPath("tmp1.stl")));
    comparea();
    //stl.recalc=false;
    //    stl.saveBin(dataPath("tmp.stl"));
    //    String gcodepath=dataPath("tmp.gcode");
    //    int time=slice(dataPath("tmp.stl"), gcodepath);
    //    gcode=new GCode(gcodepath);
    //    gcode.setTime(time);
  }
}

GCode saveAndCreateGCode() {
  String stlpath=dataPath("tmp.stl");
  String gcodepath=dataPath("tmp.gcode");
  for (DrawSTL stl : stls) {
    stl.setXYDiff(4, -1);
    stl.setPositonToVertex();
  }
  STL.saveBin(stlpath, stls.toArray(new DrawSTL[0]));
  for (DrawSTL stl : stls) {
    stl.setXYDiff(-4, 1);
  }
  int time=slice(stlpath, gcodepath);
  GCode gcode=new GCode(gcodepath);
  gcode.setTime(time);
  return gcode;
}
int slice(String input, String output) {
  String ini=dataPath("fast-cura.ini");
  switch(control.howToPrint.getSelectedIndex()) {
  case 0:
    ini=dataPath("fast-cura.ini");
    break;
  case 1:
    ini=dataPath("cura-support.ini");
    break;
  case 2:
    ini=dataPath("cura01.ini");
    break;
  }
  Cura cura = new Cura("D:/Program Files/Repetier-Host/plugins/CuraEngine/CuraEngine.exe", ini, input, output);
  int time=-1;
  try {      
    cura.exe();
    time =cura.getTime();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  //exit();
  return time;
}

class DrawSTL extends STL {
  float x0, y0, z0, w0, h0, d0, x, y;
  float tx, ty;
  PShape mesh;
  //PVector center;
  float angle;
  ArrayList<PVector> frontList=new ArrayList<PVector>();
  ArrayList<PVector> upperLine;
  DrawSTL(String path) {
    this(path, false);
  }
  DrawSTL(String path, boolean move) {  
    super(path);
    mesh=createShape(GROUP);
    float minx=100000, miny=100000, minz=1000000, maxx=0, maxy=0, maxz=0;
    for (int i=0; i<vertex.length; i++) {
      minx=min(minx, vertex[i].x);
      miny=min(miny, vertex[i].y);
      minz=min(minz, vertex[i].z);
      maxx=max(maxx, vertex[i].x);
      maxy=max(maxy, vertex[i].y);
      maxz=max(maxz, vertex[i].z);
    }
    x0=minx;
    y0=miny;
    z0=minz;
    w0=maxx-minx;
    h0=maxy-miny;
    d0=maxz-minz;
    x=x0;
    y=y0;
    tx=1;
    ty=1;
    angle=0;
    for (PVector p : vertex) {
      p.z-=minz;
    }
    z0=0;

    //    for (int i=0; i<vertex.length; i+=9) {
    //      PShape point=createShape(POINT, vertex[i].x-x0, vertex[i].y-y0);
    //      point.setStroke((vertex[i].z<z0+3)?color(255, 0, 0):color(0));
    //      mesh.addChild(point);
    //    }

    for (int i=0; i<tri.length; i+=3) {
      Tri t=tri[i];
      t.calcNor();
      if (abs(PVector.dot(t.nor, new PVector(0, 1, 0)))<0.15) {
        for (PVector p : new PVector[] {
          t.a/*, t.b, t.c*/
        }
        ) {
          frontList.add(p);
        }
      }
    }
    detailMesh();
    //upperLine=getUpperSurface();
    if (move) {
      setXY((170-w0)/2-30, (100-h0)/2-30);
    }
  }
  void detailMesh() {
    mesh=createShape(GROUP);
    for (int i=0; i<tri.length; i+=1) {
      Tri t=tri[i];
      t.calcNor();
      if (abs(PVector.dot(t.nor, new PVector(0, 0, 1)))>0.99) {
        PShape triangle=createShape(TRIANGLE, t.a.x-x0, t.a.y-y0, t.b.x-x0, t.b.y-y0, t.c.x-x0, t.c.y-y0);
        triangle.setFill(color(255, 0, 0));
        triangle.setStroke(color(255, 0, 0));
        //        PShape triangle=createShape();
        //        triangle.beginShape();
        //        triangle.vertex(t.a.x-x0, t.a.y-y0);
        //        triangle.vertex(t.b.x-x0, t.b.y-y0);
        //        triangle.vertex(t.c.x-x0, t.c.y-y0);
        //        triangle.endShape(CLOSE);
        //        triangle.setFill(color(255,0,0));
        //        triangle.setStroke(color(255,0,0));
        mesh.addChild(triangle);
      }
    }
  }
  void fastMesh() {
    mesh=createShape(GROUP);
    for (int i=0; i<tri.length; i+=3) {
      Tri t=tri[i];
      t.calcNor();
      if (abs(PVector.dot(t.nor, new PVector(0, 0, 1)))<0.15) {
        for (PVector p : new PVector[] {
          t.a/*, t.b, t.c*/
        }
        ) {
          PShape point=createShape(POINT, p.x-x0, p.y-y0);
          point.setStroke((p.z<z0+3)?color(255, 0, 0):color(0));
          point.setStrokeWeight(6);
          mesh.addChild(point);
        }
      }
    }
  }
  void drawFront(PApplet apa) {
    apa.rect(x, 0, w0*tx, d0*ty);
    if (frontList!=null) {
      try {
        for (PVector p : frontList) {
          apa.point((p.x-x0)*tx+x, (p.z-z0)*ty);
        }
      }
      catch(Exception e) {
      }
    }
    if (upperLine!=null) {
      try {
        apa.noFill();
        apa.stroke(0);
        apa.beginShape();
        for (PVector p : upperLine) {
          apa.vertex(p.x, p.z);
        }
        apa.endShape();
      }
      catch(Exception e) {
      }
    }
  }
  void draw() {
    fill(255, 255, 255, 100);
    rect(x, y, w0*tx, h0*ty);
    shape(mesh, x, y, w0*tx, h0*ty);
  }
  void setXY(float x, float y) {
    if (forcePosition) {
      this.x=x;
      this.y=y;
      return;
    }
    this.x=max(0, min(x, 170-w0*tx));
    this.y=max(0, min(y, 100-h0*ty));
  }
  void setXYDiff(float dx, float dy) {
    setXY(dx+x, dy+y);
  }
  //  void setT(float t) {
  //    this.t=t;
  //  }
  void setTX(float tx, boolean auto) {
    this.tx=tx;
    if (auto) {
      ty=tx;
    }
  }
  void setTY(float ty, boolean auto) {
    this.ty=ty;
    if (auto) {
      tx=ty;
    }
  }

  boolean outOfField() {
    return(x<0||y<0||170<x+w0*tx||100<y+h0*ty);
  }
  void setTAuto(float mouse[], int side, boolean auto) {
    switch(side) {
    case 1:
      setTX((x+w0*tx-mouse[0])/w0, auto);
      this.x=max(0, min(mouse[0], 170-w0*tx));

      break;
    case 2:
      setTX((mouse[0]-x)/w0, auto);
      break;
    case 3:
      setTY((y+h0*ty-mouse[1])/h0, auto);
      this.y=max(0, min(mouse[1], 100-h0*ty));

      break;
    case 4:
      setTY((mouse[1]-y)/h0, auto);
      break;
    }
  }
  int ifonTheOutLine(float xx, float yy) {
    if (abs(xx-x)<2&&y<=yy&&yy<=y+h0*ty)return 1;
    if (abs(xx-x-w0*tx)<2&&y<=yy&&yy<=y+h0*ty)return 2;
    if (abs(yy-y)<2&&x<=xx&&xx<=x+w0*tx)return 3;
    if (abs(yy-y-h0*ty)<2&&x<=xx&&xx<=x+w0*tx)return 4;
    return -1;
  }
  boolean ifin(float xx, float yy) {
    return x<=xx&&xx<=x+w0*tx&&y<=yy&&yy<=y+h0*ty;
  }
  void setPositonToVertex() {
    for (PVector v : vertex) {
      v.x=(v.x-x0)*tx+x;
      v.y=(v.y-y0)*ty+y;
      v.z=(v.z-z0)*(tx+ty)/2;//t;
    }
  }
  ArrayList<PVector> getUpperSurface() {
    PVector top=null, left=null, right=null;
    for (PVector v : vertex) {
      if (top==null||top.z<v.z) {
        top=v;
      }
      if (left==null||v.x<left.x) {
        left=v;
      }
      if (right==null||right.x<v.x) {
        right=v;
      }
    }
    ArrayList<Tri> tris=new ArrayList<Tri>();
    PVector znor=new PVector(0, 0, 1);
    for (Tri t : tri) {
      t.calcNor();
      if (t.nor.dot(znor)>0) {
        tris.add(t);
      }
    }
    //    println("上向きの面の数:"+tris.size());
    ArrayList<PVector> line=new ArrayList<PVector>();//最終的に得られた形の線
    HashSet<PVector> visited=new HashSet<PVector>();
    ArrayDeque<PVector> queue=new ArrayDeque<PVector>();
    queue.add(top);
    //    queue.add(right);
    //    queue.add(left);
    while (!queue.isEmpty ()) {
      //      println("キューの呼び出し");
      PVector p=queue.pollFirst();
      if (visited.contains(p)) {
        continue;
      }
      visited.add(p);
      if (line.size()==0) {
        line.add(p);
        addQueue(queue, tris, p);
        continue;
      }
      if (line.size()==1) {
        if (line.get(0).x<p.x) {
          line.add(p);
        } else {
          line.add(0, p);
        }
        addQueue(queue, tris, p);
        continue;
      }
      //xが探索範囲外ならそのまま追加
      if (p.x<line.get(0).x) {
        line.add(0, p);
        addQueue(queue, tris, p);
        continue;
      }
      if (line.get(line.size()-1).x<p.x) {
        line.add(p);
        addQueue(queue, tris, p);
        continue;
      }
      //探索範囲内なら
      PVector a=line.get(0), b;
      for (int i=1, n=line.size (); i<n; i++) {
        b=line.get(i);
        if (a.x<=p.x&&p.x<=b.x) {
          float ac=p.x-a.x;
          float cb=b.x-p.x;
          float ab=b.x-a.x;
          float z=(a.z*cb+b.z*ac)/ab;//もともとのz
          if (z<p.z) {
            //更新
            line.add(i, p);

            if (a.x<top.x||b.x<top.x) {
              line.remove(a);
            } else {
              line.remove(b);
            }
          }
          addQueue(queue, tris, p);
          break;
        }
        a=b;
      }
    }
    PVector first=line.get(0);
    PVector last=line.get(line.size()-1);
    for (int k=0; k<5; k++) {
      //探索範囲内なら
      PVector a=line.get(0), b=line.get(1), c;
      for (int i=2; i<line.size ()-2; i++) {
        c=line.get(i);
        float ac=c.x-a.x;
        float ab=b.x-a.x;
        float bc=c.x-b.x;
        float z=(a.z*bc+c.z*ab)/ac;//もともとのz
        if (b.z<z&&c.x-a.x<5) {
          line.remove(--i);
          b=c;
        } else {
          a=b;
          b=c;
        }
      }
    }
    if (first!=line.get(0)) {
      line.add(0, first);
    }
    if (last!=line.get(line.size()-1)) {
      line.add(last);
    }
    ArrayList<PVector> line1=new ArrayList<PVector>();
    for (PVector p : line) {
      line1.add(new PVector(p.x, p.y, p.z));
    }
    return line1;
  }
  void addQueue(ArrayDeque<PVector> queue, ArrayList<Tri> tris, PVector p) {
    for (Tri t : contains (tris, p)) {
      PVector ps[]= {
        t.a, t.b, t.c
      };
      Arrays.sort(ps, new Comparator<PVector>() {
        public int compare(PVector a, PVector b) {
          if (b.z-a.z<0) {
            return 1;
          }
          if (a.z-b.z==0) {
            return 0;
          }
          return -1;
        }
      }
      );
      for (PVector ts1 : ps) {
        if (!ts1.equals(p)) {
          queue.add(ts1);
        }
      }
      tris.remove(t);
    }
  }
  ArrayList<Tri> contains(ArrayList<Tri> tris, PVector p) {
    ArrayList<Tri> ans=new ArrayList<Tri>();
    for (Tri t : tris) {
      if (t.contains(p)) {
        ans.add(t);
      }
    }
    return ans;
  }
}

