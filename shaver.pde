Shaver shaver;

//void setup() {
//  size(640, 480);
//}
//
//void draw() {
//  background(255);
//  if (shaver!=null) {
//    if (mousePressed) {
//      shaver.add(new PVector(mouseX, mouseY));
//    }
//    shaver.draw();
//  }
//}

//void mousePressed() {
//  shaver=new Shaver();
//}
//void mouseReleased() {
//  shaver.fixLine();
//}

class Shaver {
  ArrayList<PVector> line;
  float min, max;
  Shaver() {
    line=new ArrayList<PVector>();
  }
  void add(PVector a) {
    line.add(a);
  }
  void fixLine() {
    PVector a=line.get(0), b;
    int dir=(line.get(line.size()-1).x-a.x>0)?1:-1;//1:昇順　-1:降順
    for (int i=1; i<line.size (); i++) {
      b=line.get(i);
      if ((b.x-a.x)*dir<=0) {
        //方向が逆，または変化がないなら削除
        line.remove(i);
        i--;
      } else {
        a=b;
      }
    }
    if (dir<0) {
      Collections.reverse(line);
    }
    min=line.get(0).x;
    max=line.get(line.size()-1).x;
    for (PVector p : line) {
      p.z=convToZ(p.y);
    }
  }
  float getZ(float x, ArrayList<PVector> line) {
    PVector a=line.get(0), b;
    if (a.x==x) {
      return a.z;
    }
    for (int i=1, n=line.size (); i<n; i++) {
      b=line.get(i);
      if (b.x==x) {
        return b.z;
      }
      if (a.x<=x&&x<=b.x) {
        float ac=x-a.x;
        float cb=b.x-x;
        float ab=b.x-a.x;
        float z=(a.z*cb+b.z*ac)/ab;
        return z;
      }
      a=b;
    }
    return 0;
  }
  void shave(DrawSTL stl) {
    if (line.get(0).z<getZ(min, stl.upperLine)) {
      //      println("だめ1");
      return;
    }
    if (line.get(line.size()-1).z<getZ(max, stl.upperLine)) {
      //      println("だめ2");
      return;
    }
    boolean fixed[]=new boolean[stl.vertex.length];
    for (int i=0; i<fixed.length; i++) {
      if (fixed[i]) {
        continue;
      }
      PVector p=stl.vertex[i];
      if (!ifin(line, p)||!ifin(stl.upperLine, p)) {
        //        println(p.x);
        //        println(line.get(0).x+" "+line.get(line.size()-1).x);
        //        println(stl.upperLine.get(0).x+" "+stl.upperLine.get(line.size()-1).x);
        continue;
      }
      //      ArrayList<Integer> list=new ArrayList<Integer>();
      float z=p.z*min(getZ(p.x, line)/getZ(p.x, stl.upperLine), 1);
      for (int j=0; j<fixed.length; j++) {
//        if (p.equals(stl.vertex[j])) {
        if (PVector.dist(p,stl.vertex[j])<0.001) {
          stl.vertex[j].z=z;
          fixed[j]=true;
        }
      }

      //      p.z*=min(getZ(p.x,line)/getZ(p.x,stl.upperLine),1);
    }
  }
  float convToZ(float y) {
    return y;
    //    return (-y+1151)*h/1080;
  }
  boolean ifin(ArrayList<PVector> line, PVector pos) {
    return line.get(0).x<=pos.x&&pos.x<=line.get(line.size()-1).x;
  }
}

