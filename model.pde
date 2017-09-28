class Model {
  ArrayList<PVector> points;
  ArrayList<Line> lines;  
  ArrayList<Tri> tris;
  ArrayList<PVector> axis;
  ArrayList<Line> axisLine;
  Point[] frameBackup;
  int creationType;

  boolean half=false;
  void setHalf(boolean bool) {
    half=bool;
  }
  Model(Point[] frame, Point[] frame2) {
    this();
    println(frame.length+" "+frame2.length);
    int nnn=min(frame.length, frame2.length);
    Line l4=null;
    for (int i=0; i<nnn; i++) {
      points.add((PVector)frame[i]);
      points.add((PVector)frame2[i]);
      if (i==0) {
        l4=new Line((PVector)frame[0], (PVector)frame2[0]);
        //l4.isSuper=true;
        lines.add(l4);
      } else {
        Line l0=l4;
        Line l1=new Line((PVector)frame[i], (PVector)frame[(i+1)%frame.length]);
        Line l2=new Line((PVector)frame2[i], (PVector)frame2[(i+1)%frame2.length]);
        Line l3=new Line( (PVector)frame2[(i+1)%frame2.length], (PVector)frame[i]);
        l1.isSuper=true;
        l2.isSuper=true;
        //l3.isSuper=true;
        //l4.isSuper=true;
        l4=(i==frame.length-1)?lines.get(0):new Line((PVector)frame[(i+1)%frame.length], (PVector)frame2[(i+1)%frame2.length]);
        lines.add(l1);
        lines.add(l2);
        lines.add(l3);
        if(i!=frame.length-1)lines.add(l4);
        if (i!=frame.length-1) {
          lines.add(l4);
        }
        tris.add(new Tri(new Line[] {
          l0, l2, l3
        }
        ));
        tris.add(new Tri(new Line[] {
          l1, l4, l3
        }
        ));
      }
    }
  }

  Model() {
    points=new ArrayList<PVector>();
    lines=new ArrayList<Line>();
    tris=new ArrayList<Tri>();
    axis=new ArrayList<PVector>();
    axisLine=new ArrayList<Line>();
  }
  Model(Model... ms) {
    this(false, ms);
  }
  Model(int i, Model... ms) {
    points=new ArrayList<PVector>();
    lines=new ArrayList<Line>();
    tris=new ArrayList<Tri>();
    axis=new ArrayList<PVector>();
    axisLine=new ArrayList<Line>();
    for (Model m : ms) {
      create(m);
    }
    for (Tri tri : tris) {
      for (Line l : tri.l)
        println(lines.indexOf(l));
    }
    
    laplacianSmoothing(10, new float[] {
      i, 0
    }
    );
  }
  Model(boolean lap, Model... ms) {
    points=new ArrayList<PVector>();
    lines=new ArrayList<Line>();
    tris=new ArrayList<Tri>();
    axis=new ArrayList<PVector>();
    axisLine=new ArrayList<Line>();
    for (Model m : ms) {
      create(m);
    }
    for (Tri tri : tris) {
      for (Line l : tri.l)
        println(lines.indexOf(l));
    }
    if (lap) {
      laplacianSmoothing(10);
    }
  }
  //  void setZPos(PVector frame2[],float z){
  //    for(PVector p:points){
  //      for(PVector p1:frame2){
  //        if(p.equals(p1)){
  //          p.z=z;
  //        }
  //      }
  //    }
  //  }
  void setZPos(float z) {
    //    for (PVector p : points) {
    //      if (abs(p.z)<0.01) {
    //        p.z=z;
    //      }
    //    }
  }

  
  PVector[] getSuperStroke1() {
    ArrayList<PVector> poin=new ArrayList<PVector>();
    PVector a=null;
    for (Line l : lines) {
      if (l.isSuper()) {
        if (!poin.contains(l.a))
          poin.add(l.a);
        if (!poin.contains(l.a))
          poin.add(l.b);
        a=l.a;
      }
    }
    println(poin.size()+"poin");
    //    PVector stroke[]=new PVector[poin.size()];
    //    stroke[0]=a;
    //    for(int i=1;i<stroke.length;i++){
    //      for(Line l1:lin){
    //        PVector t=l1.getNot(stroke[i-1]);
    //        if(t!=null){
    //          stroke[i]=t;
    //          break;
    //        }
    //      }
    //      lin.remove(stroke[i]);
    //    }
    //    println(lin.size()+"lin");  
    Collections.sort(poin, new Comparator<PVector>() {
      public int compare(PVector a, PVector b) {
        if (a.x > b.x) {
          return 1;
        } else if (a.x == b.x) {
          return 0;
        } else {
          return -1;
        }
      }
    }
    );
    if (abs(poin.get(0).x- poin.get(poin.size()-1).x)<0.1) {
      Collections.sort(poin, new Comparator<PVector> (){
        public int compare(PVector a, PVector b) {
          if (a.y > b.y) {
            return 1;
          } else if (a.y == b.y) {
            return 0;
          } else {
            return -1;
          }
        }
      }
      );
      return poin.toArray(new PVector[0]);
    }
    return poin.toArray(new PVector[0]);
  }
  Point[] getSuperStroke(boolean fixZ) {
    ArrayList<PVector> poin=new ArrayList<PVector>();
    PVector a=null;
    for (Line l : lines) {
      if (l.isSuper()) {
        if(fixZ&&l.a.z==0){
          l.a.z=-3;
        }
        if(fixZ&&l.b.z==0){
          l.b.z=-3;
        }
        if (!poin.contains(l.a)){
          poin.add(l.a);
        }
        if (!poin.contains(l.b)){
          poin.add(l.b);
        }
        a=l.a;
      }
    }
    println(poin.size()+"poin");
    //    PVector stroke[]=new PVector[poin.size()];
    //    stroke[0]=a;
    //    for(int i=1;i<stroke.length;i++){
    //      for(Line l1:lin){
    //        PVector t=l1.getNot(stroke[i-1]);
    //        if(t!=null){
    //          stroke[i]=t;
    //          break;
    //        }
    //      }
    //      lin.remove(stroke[i]);
    //    }
    //    println(lin.size()+"lin");  
    Collections.sort(poin, new Comparator<PVector>() {
      public int compare(PVector a, PVector b) {
        if (a.x > b.x) {
          return 1;
        } else if (a.x == b.x) {
          return 0;
        } else {
          return -1;
        }
      }
    }
    );
    if (abs(poin.get(0).x- poin.get(poin.size()-1).x)<0.1) {
      Collections.sort(poin, new Comparator<PVector> (){
        public int compare(PVector a, PVector b) {
          if (a.y > b.y) {
            return 1;
          } else if (a.y == b.y) {
            return 0;
          } else {
            return -1;
          }
        }
      }
      );
    }
    Point stroke1[]=new Point[poin.size()];
    for (int i=0; i<stroke1.length; i++) {
      stroke1[i]=new Point(poin.get((i+stroke1.length/2)%stroke1.length));
    }
    return stroke1;
  }
  void save(String filename) {
    ArrayList<String> data=new ArrayList<String>();
    data.add("solid "+filename);
    PVector center=new PVector();
    for (PVector p : points) {
      center.add(p);
    }
    center.div(points.size());
    for (Tri tri : tris) {
      ArrayList<PVector> ps=new ArrayList<PVector>();
      for (Line l : tri.l) {
        if (ps.indexOf(l.a)==-1)ps.add(l.a);
        if (ps.indexOf(l.b)==-1)ps.add(l.b);
      }
      PVector p[]=ps.toArray(new PVector[0]);

      if (p.length==3) {
        PVector nor=PVector.sub(p[1], p[0]).cross(PVector.sub(p[2], p[0]));
        nor.normalize();
        if (PVector.sub(p[0], center).dot(nor)<0) {
          nor.mult(-1);
        }
        if (tri.reverse) {
          nor.mult(-1);
          data.add("facet normal "+nor.x+" "+nor.y+" "+nor.z);
          data.add("outer loop");
          for (int i=2; i>=0; i--) {
            PVector p1=p[i];
            data.add("  vertex "+p1.x+" "+p1.y+" "+p1.z);
          }
          data.add("endloop");
          data.add("endfacet");
        } else {
          data.add("facet normal "+nor.x+" "+nor.y+" "+nor.z);
          data.add("outer loop");
          for (PVector p1 : p) {
            data.add("  vertex "+p1.x+" "+p1.y+" "+p1.z);
          }
          data.add("endloop");
          data.add("endfacet");
        }
      }
    }
    data.add("endsolid "+filename);
    saveStrings(dataPath(filename+".stl"), data.toArray(new String[0]));
  }
  void smoothModel(ArrayList<PVector> axiss) {


    float axisHeight[]=new float[axiss.size()];
    for (int n=0; n<3; n++) {
      for (int i=0; i<axisHeight.length; i++) {
        PVector axisP=axiss.get(i);
        int num=1;
        axisHeight[i]=axisP.z;
        for (Line l : axisLine) {
          PVector notP=l.getNot(axisP);
          if (notP!=null) {
            axisHeight[i]+=notP.z;
            num++;
          }
        }
        axisHeight[i]/=num;
      }
      for (int i=0; i<axisHeight.length; i++) {
        axiss.get(i).z=axisHeight[i];
      }
    }

    //    for (Line line : lines) {
    //      if (axiss.indexOf(line)==-1) {
    //        //        println((line.a==null)+" "+(line.b==null));
    //        points.addAll(Arrays.asList(new SplitLine(line.a, line.b).create(4)));
    //      }
    //    }
    ArrayList<Tri> newTris=new ArrayList<Tri>();
    for (Tri tri : tris) {
      PVector separateL[][]=new PVector[2][];
      HashSet<Integer> superLine=new HashSet<Integer>();
      { 
        int index=0;
        for (Line l : tri.l) {
          if (axisLine.indexOf(l)!=-1) {
            continue;//ここで弾けてない線が存在する
          }
          println(l.isFrame()+" "+index);
          PVector tmp[]=l.getSeparatePoint();
          if (tmp!=null) {
            if (l.isSuper()) {
              superLine.add(index);
            }
            separateL[index++]=tmp;
          }
        }
      }
      if (superLine.size()==2) {
        println("aaaa");
        continue;
      }

      separateL[0][separateL[0].length-1]=getFromPoints(separateL[0][separateL[0].length-1]);
      separateL[1][separateL[0].length-1]=getFromPoints(separateL[1][separateL[0].length-1]);
      for (int i=0; i<separateL[0].length-1; i++) {
        if (i==0) {
          separateL[0][i]=getFromPoints(separateL[0][i]);
          separateL[1][i]=getFromPoints(separateL[1][i]);
        } else {
          separateL[0][i]=points_add2(separateL[0][i]);
          separateL[1][i]=points_add2(separateL[1][i]);
        }
        if (i==separateL[0].length-1) {
          continue;
        }


        Line a, b, c;
        a=lines_add(new Line(separateL[0][i], separateL[0][i+1]));
        b=lines_add(new Line(separateL[0][i+1], separateL[1][i+1]));
        c=lines_add(new Line(separateL[1][i+1], separateL[0][i]));
        if (superLine.contains((Integer)0)) {
          a.isSuper=true;
          println("0だあああああ");
        }
        newTris.add(new Tri(a, b, c));
        a=lines_add(new Line(separateL[0][i], separateL[1][i]));
        b=lines_add(new Line(separateL[1][i], separateL[1][i+1]));
        c=lines_add(new Line(separateL[1][i+1], separateL[0][i]));
        newTris.add(new Tri(a, b, c));
        if (superLine.contains((Integer)1)) {
          b.isSuper=true;
          println("1だあああああ");
        }
      }
    }
    tris=newTris;
    //exit();
  }
  PVector[][] separateLineType(Tri tri, ArrayList<PVector> axiss) {    
    PVector pv[]=tri.toPointArray();
    for (PVector p : pv) {
      int id=axiss.indexOf(p);
      if (id!=-1) {
        PVector a[]=new PVector[2];
        int index=0;
        for (PVector p1 : pv) {
          if (p1!=p) {
            a[index++]=p1;
          }
        }
        return new PVector[][] {
          {
            axiss.get(id)
          }
          , a
        };
      }
    }
    if (true) {
      return null;
    }
    Line lll=tri.getFrame()[0];
    PVector[][] ans=new PVector[2][];
    ans[1]=new PVector[] {
      lll.a, lll.b
    };
    println(tri.getNotFrame().length+" "+tri.getFrame().length+" "+tri.l.size());
    PVector ppp=tri.getNotFrame()[0].getNot(ans[1][0]);
    if (ppp==null) {
      ppp=tri.getNotFrame()[1].getNot(ans[1][0]);
    }
    ans[0]=new PVector[] {
      ppp
    };

    println(ans[0][0]==null);
    println(ans[1][0]==null);
    println(ans[1][1]==null);
    return ans;
  }
  void create(Model m) {
    println("create start");
    //面の線から点を再構築する
big:
    for (Tri tri : m.tris) {
      if (tri.l.size()!=3) {
        println(tri.l.size()+"点の面を発見");
        continue;
      }
      println("ポイントを抽出");
      for (PVector p : tri.toPointArray ()) {
        if (creationType==-3&&p.z==0) {
          p.z=-300;
        }
        points_add2(p);
      }
      println("ラインの新規登録");
      for (Line line : tri.l) {
        println(indexOfPoint(line.a)+" "+indexOfPoint(line.b));
        if (indexOfPoint(line.a)==-1||indexOfPoint(line.b)==-1) {
          continue big;
        }
        Line newLine=new Line(getFromPoints(line.a), getFromPoints(line.b));
        if (line.isFrame()) {
          newLine.setFrame();
        }
        newLine.isSuper=line.isSuper();
        boolean a=false;
        for (Line tmp : lines) {
          if (tmp.equals(newLine)) {
            if (line.isFrame()) {
              tmp.setFrame();
            }
            tmp.isSuper=line.isSuper();
            a=true;
          }
        }
        if (!a) {
          lines.add(newLine);
        }
      }
    }
    println("面の登録");
    //面の移動
big:
    for (Tri tri : m.tris) {
      if (tri.l.size()!=3)continue;
      println("面の辺の数"+tri.l.size());
      Line l[]=new Line[tri.l.size()];
      for (int i=0; i<l.length; i++) {
        Line line=tri.l.get(i);
        if (indexOfPoint(line.a)==-1||indexOfPoint(line.b)==-1) {
          continue big;
        }
        l[i]=new Line(getFromPoints(line.a), getFromPoints(line.b));
        l[i]=getFromLines(l[i]);
      }
      Tri newTri=new Tri(l);
      newTri.usingTexture=tri.usingTexture;
      newTri.reverse=tri.reverse;
      tris.add(newTri);
    }
    for (PVector axisP : m.axis) {
      PVector p=getFromPoints(axisP);
      boolean b=true;
      for (PVector a : axis) {
        if (a==p) {
          b=false;
          break;
        }
      }
      if (b) {
        axis.add(p);
      }
    }
    for (Line axisL : m.axisLine) {
      Line l=getFromLines(axisL);
      boolean b=true;
      for (Line a : axisLine) {
        if (a==l) {
          b=false;
          break;
        }
      }
      if (b) {
        axisLine.add(l);
      }
    }
  }
  void to3DCover() {
    to3D(2, null);
  }
  void to3D() {
    to3D(0, null);
  }
  void to3DHalf() {
    to3D(1, null);
  }
  void to3D(int creationType, ArrayList<Point> frame) {
    this.creationType=creationType;
    if (creationType==3||creationType==-3) {
      //不動点の設定
      PVector a=(PVector)frame.get(0), b=(PVector)frame.get(frame.size()-1);
      PVector c=PVector.add(a, b);
      c.div(2);
      Line l1=new Line(a, c), l2=new Line(b, c);
      int cnt=0;
      for (Line l : lines) {
        if (l.equals(a, b)) {
          for (Tri tri : tris) {
            if (tri.contains(l)) {
              PVector p[]=tri.getNotLinePoint(l);
              for (PVector p1 : p) {
                p1.x=c.x;
                p1.y=c.y;
                p1.z=c.z;
                break;
              }
              for (Line ll : tri.l) {
                ll.isSuper=true;
              }
              l.isSuper=false;
              break;
            }
          }
          break;
        }
      }
    }
    println("after"+points.size());
    ArrayList<PVector> axiss=new ArrayList<PVector>();
    for (Line line : axisLine) {
      if (axiss.indexOf(line.a)==-1) {
        axiss.add(line.a);
      }
      if (axiss.indexOf(line.b)==-1) {
        axiss.add(line.b);
      }
    }
    for (Line line : axisLine) {
      PVector tmp[]=new PVector[] {
        line.a, line.b
      };
      for (PVector axisP : tmp) {
        float ave=0;
        int num=0;
        for (Line l : lines) {
          PVector p=l.getNot(axisP);
          if (p!=null&&axiss.indexOf(p)==-1) {
            ave+=axisP.dist(p);
            num++;
          }
        }
        axisP.z=ave/num;//2*ave/num/3;
      }
    }
    smoothModel(axiss);

    for (Tri t : tris) {
      t.usingTexture=true;
    }
    switch(creationType) {
    case 0:
    case 1:
    case 3:
    case -3:
      //鏡面
      {
        Tri oldTris[]=tris.toArray(new Tri[0]);
        for (Tri tri : oldTris) {
          PVector pv[]=tri.toPointArray();
          for (int i=0; i<pv.length; i++) {
            if (pv[i].z==0) {
              continue;
            }
            float zzz=0;
            switch(creationType) {
            case 0:
              zzz=-pv[i].z;
              break;
            case 1:
              zzz=0;
            case 3:
              zzz=0;
              break;
            case -3:
              zzz=-3;
              break;
            }
            pv[i]=new PVector(pv[i].x, pv[i].y, zzz);
            points.add(pv[i]);
          }
          Line newLine[]=new Line[pv.length];
          for (int i=0; i<newLine.length; i++) {
            newLine[i]=new Line(pv[i], pv[(i+1)%newLine.length]);
            newLine[i]=lines_add(newLine[i]);
          }
          tris.add(new Tri(newLine));
        }
      }
      if (creationType==3) {
        for (Tri tri : tris) {
          tri.reverse=true;
        }
      }
      break;
    case -22:
      {
        Tri oldTris[]=tris.toArray(new Tri[0]);
        //tris=new ArrayList<Tri>();
        float center[]=new float[2];
        for (PVector p : points) {
          center[0]+=p.x;
          center[1]+=p.y;
        }
        center[0]/=points.size();
        center[1]/=points.size();
        for (Tri tri : oldTris) {
          tri.reverse=true;
          PVector pv[][]=new PVector[2][];
          pv[0]=tri.toPointArray();          
          pv[1]=new PVector[pv[0].length];
          float magnification[]= {
            1.1, 1.2, 1.5
          };
          int frameCnt=0;
          int frameIdx[]=new int[2];
          for (int i=0; i<pv[0].length; i++) {
            if (pv[0][i].z==0) {
              frameIdx[frameCnt++]=i;
            }

            pv[1][i]=new PVector();
            boolean ok=false;
            for (float mag : magnification) {
              pv[1][i].x=(pv[0][i].x-center[0])*mag+center[0];
              pv[1][i].y=(pv[0][i].y-center[1])*mag+center[1];
              pv[1][i].z=pv[0][i].z*mag;
              if (PVector.dist(pv[1][i], pv[0][i])>=2) {
                ok=true;
                break;
              }
            }
            if (!ok) {
              if (PVector.dot(new PVector(pv[0][i].x-center[0], pv[0][i].y-center[1]), new PVector(0, 0, 1))>0.8) {
                //zの補正
                pv[1][i].z=pv[0][i].z+1;
              } else {
                //xyの補正
                pv[1][i].x=pv[0][i].x+((pv[0][i].x-center[1]>0)?1.5:-1.5);
                pv[1][i].y=pv[0][i].y+((pv[0][i].y-center[1]>0)?1.5:-1.5);
              }
            }    
            points.add(pv[1][i]);
          }
          Line newLine[]=new Line[pv[1].length];
          for (int i=0; i<newLine.length; i++) {
            newLine[i]=new Line(pv[1][i], pv[1][(i+1)%newLine.length]);
            newLine[i]=lines_add(newLine[i]);
          }
          tris.add(new Tri(newLine));
          if (frameCnt==2) {
            Line bridge[]=new Line[3];
            bridge[0]=new Line(pv[0][frameIdx[0]], pv[0][frameIdx[1]]);
            bridge[0]=lines_add(bridge[0]);
            bridge[1]=new Line(pv[0][frameIdx[1]], pv[1][frameIdx[0]]);
            bridge[1]=lines_add(bridge[1]);
            bridge[2]=new Line(pv[1][frameIdx[0]], pv[0][frameIdx[0]]);
            bridge[2]=lines_add(bridge[2]);
            tris.add(new Tri(bridge));
            bridge=new Line[3];
            bridge[0]=new Line(pv[1][frameIdx[0]], pv[1][frameIdx[1]]);
            bridge[0]=lines_add(bridge[0]);
            bridge[1]=new Line(pv[1][frameIdx[1]], pv[0][frameIdx[1]]);
            bridge[1]=lines_add(bridge[1]);
            bridge[2]=new Line(pv[0][frameIdx[1]], pv[1][frameIdx[0]]);
            bridge[2]=lines_add(bridge[2]);
            tris.add(new Tri(bridge));
          }
        }
      }
      break;
    case 2://inner
      for (Tri tri : tris) {
        tri.reverse=true;
      }
      break;
    }
  }
  void laplacianSmoothing1(int n) {
    for (int i=0; i<n; i++) {
      for (PVector p : points) {
        if (p.z==0) {
          continue;
        }
        PVector mean=new PVector();
        int cnt=0;
        for (Line l : lines) {
          PVector t=l.getNot(p);
          if (t!=null) {
            mean.add(t);
            cnt++;
          }
        }
        mean.div(cnt);
        p.x=mean.x;
        p.y=mean.y;
        p.z=mean.z;
      }
    }
  }
  void laplacianSmoothing(int n) {
    laplacianSmoothing(n, new float[] {
      0
    }
    );
  }
  void laplacianSmoothing(int n, float baseZ[]) {
    HashSet<PVector> blackList=new HashSet<PVector>();
    for (Line l : lines) {
      if (l.isSuper()) {
        blackList.add(l.a);
        blackList.add(l.b);
      }
    }
    for (Line l : lines) {
      if (l.isFrame()) {
        blackList.add(l.a);
        blackList.add(l.b);
      }
    }
    laplacianSmoothing(n, blackList, baseZ);
  }
  void laplacianSmoothing(int n, HashSet<PVector> blackList, float baseZ[]) {
    ArrayList<PVector> points1=new ArrayList<PVector>();
big:
    for (PVector p : points) {
      for (float bz : baseZ) {
        if (p.z==bz) {
          continue big;
        }
      }
      if (blackList.contains(p)) {
        continue;
      }
      points1.add(p);
    }
    for (int i=0; i<n; i++) {
      for (PVector p : points1) {
        PVector mean=new PVector();
        int cnt=0;
        for (Line l : lines) {
          PVector t=l.getNot(p);
          if (t!=null) {
            mean.add(t);
            cnt++;
          }
        }
        mean.div(cnt);
        p.x=mean.x;
        p.y=mean.y;
        p.z=mean.z;
      }
    }
  }
  PVector getFromPoints(PVector p) {    
    return points.get(indexOfPoint(p));
  }
  Line getFromLines(Line p) {
    return lines.get(indexOfLine(p));
  }
  int indexOfPoint(PVector tmp) {
    int index=0;
    for (PVector p : points) {
      if (p.x==tmp.x&&p.y==tmp.y&&p.z==tmp.z) {
        return index;
      }
      index++;
    }
    return -1;
  }
  int indexOfLine(Line tmp) {
    int index=0;
    for (Line l : lines) {
      if (l.equals(tmp)) {
        return index;
      }
      index++;
    }
    return -1;
  }
  void addTriangle(int type, PVector... triPoint) {
    //点の用意
    for (int i=0; i<triPoint.length; i++) {
      boolean settle=false;
      for (int j=0, n=points.size (); j<n; j++) {
        if (points.get(j).equals(triPoint[i])) {
          triPoint[i]=points.get(j);
          settle=true;
          break;
        }
      }
      if (!settle) {
        //登録されてなかったら点を登録
        points.add(triPoint[i]);
      }
    }
    //ここから
    //線の用意
    Line line[]=new Line[triPoint.length];
    for (int i=0; i<triPoint.length; i++) {
      PVector a=triPoint[i], b=triPoint[(i+1)%triPoint.length];
      line[i]=null;
      for (Line l : lines) {
        if (l.equals(a, b)) {
          //同じ直線が登録済み
          l.use();
          line[i]=l;
          break;
        }
      }
      if (line[i]==null) {
        line[i]=new Line(triPoint[i], triPoint[(i+1)%triPoint.length]);
        lines.add(line[i]);
      }
    }
    tris.add(new Tri(type, line));
  }
  Line lines_add(Line l) {
    for (Line line : lines) {
      if (line.equals(l)) {
        return line;
      }
    }
    lines.add(l);
    return l;
  }
  PVector points_add(PVector p) {
    for (PVector pv : points) {
      if (pv.x==p.x&&pv.y==p.y) {
        return pv;
      }
    }
    points.add(p);
    return p;
  }

  PVector points_add2(PVector p) {
    for (PVector pv : points) {
      if (pv.x==p.x&&pv.y==p.y&&pv.z==p.z) {
        return pv;
      }
    }
    points.add(p);
    return p;
  }
  class Tri {
    boolean reverse;
    ArrayList<Line> l;
    ArrayList<Line> oldLine;
    ArrayList<PVector> newPointByFan;
    int type;
    boolean makedfan=false;
    PVector center;
    boolean usingTexture;

    Tri(int type, Line... line) {
      this.type=type;
      l=new ArrayList(Arrays.asList(line));
      oldLine=new ArrayList(l);
      newPointByFan=new ArrayList<PVector>();

      center=new PVector(0, 0, 0);
      for (PVector pv : toPointArray ()) {
        center.add(pv);
      }
      center.div(l.size());
    }
    Tri(Line... line) {
      type=3;
      l=new ArrayList<Line>();
      oldLine=new ArrayList<Line>();
      for (Line la : line) {
        l.add(la);
        oldLine.add(la);
      }
      center=new PVector(0, 0, 0);
      for (PVector pv : toPointArray ()) {
        center.add(pv);
      }
      center.div(l.size());
    }
    Tri(int type, PVector... pv) {
      this.type=type;
      l=new ArrayList();
      for (int i=0; i<pv.length; i++) {
        Line tmp=new Line(pv[i], pv[(i+1)%pv.length]);
        lines_add(tmp);
        l.add(tmp);
      }
      oldLine=new ArrayList(l);
      newPointByFan=new ArrayList<PVector>();

      center=new PVector(0, 0, 0);
      for (PVector pv1 : toPointArray ()) {
        center.add(pv1);
      }
      center.div(l.size());
    }
    PVector getCenter() {
      return center;
    }
    boolean contains(Line l) {
      for (Line tmp : this.l) {
        if (l.equals(tmp)) {
          return true;
        }
      }
      return false;
    }
    boolean remove(Line l) {
      for (Line tmp : this.l) {
        if (l.equals(tmp)) {
          this.l.remove(l);
          oldLine.remove(l);
          return true;
        }
      }
      return false;
    }
    boolean remove0(Line rem) {
      oldLine.remove(rem);
      return l.remove(rem);
    }
    void add(Tri tri) {
      for (int i=0, n=l.size (); i<n; i++) {
        Line thisl=l.get(i);
        for (Line thatl : tri.l) {
          if (thisl.b.equals(thatl.a)) {
            tri.remove0(thatl);
            l.add(i+1, thatl);
            add(tri);
            return;
          }
          if (thisl.b.equals(thatl.b)) {
            tri.remove0(thatl);
            thatl.inverse();
            l.add(i+1, thatl);
            add(tri);
            return;
          }
        }
      }
    }
    boolean addPointToLine(PVector pv, Line target) {
      newPointByFan.add(pv);
      //      type=4;//0->4
      for (int i=0, n=l.size (); i<n; i++) {
        Line line=l.get(i);
        if (line.equals(target)) {
          remove(line);
          l=new ArrayList<Line>(oldLine);
          switch(l.size()) {
          case 0:
            return false;
          case 1:
            line=l.get(0);
            l.add(new Line(line.a, pv));
            l.add(new Line(line.b, pv));
            return true;
          case 2:
            l.add(new Line(line.a, pv));
            l.add(new Line(line.b, pv));
            return true;
          }
        }
      }
      return true;
    }
    ArrayList<Tri> splitTri(PVector newPoint, Line line) {
      ArrayList<Tri> split=new ArrayList<Tri>();
      for (Line tmp : l) {
        if (tmp==line) {
          continue;
        }
        Line a=new Line(tmp.a, newPoint), b=new Line(tmp.b, newPoint);
        lines.add(a);
        lines.add(b);
        Tri tri=new Tri(3, tmp, a, b);
        axis.add(newPoint);
        split.add(tri);
      }
      return split;
    }
    void fan() {
      makedfan=true;
    }
    boolean makedfan() {
      return makedfan;
    }
    PVector[] getNotLinePoint(Line line) {
      ArrayList<PVector> p=new ArrayList<PVector>();
      for (Line tmp : l) {
        if (tmp==line) {
          continue;
        }
        if (!line.contains(tmp.a)) {
          p.add(tmp.a);
        }
        if (!line.contains(tmp.b)) {
          p.add(tmp.b);
        }
      }
      return p.toArray(new PVector[0]);
    }
    Line[] getFrame() {
      ArrayList<Line> frame=new ArrayList<Line>();
      for (Line tmp : l) {
        if (tmp.isFrame()) {
          frame.add(tmp);
        }
      }
      return frame.toArray(new Line[0]);
    }
    Line[] getNotFrame() {
      ArrayList<Line> frame=new ArrayList<Line>();
      for (Line tmp : l) {
        if (!tmp.isFrame()) {
          frame.add(tmp);
        }
      }
      return frame.toArray(new Line[0]);
    }
    void draw3D() {
      beginShape();
      if (usingTexture) {
        //texture(img);
      }
      for (PVector pv : toPointArray ()) {
        if (usingTexture) {
          vertex(pv.x, pv.y, pv.z, pv.x, pv.y);
        } else {
          vertex(pv.x, pv.y, pv.z);
        }
      }
      endShape(CLOSE);
    }
    void draw2D() {
      color c[]= {
        color(255, 200, 200), color(200), color(255, 255, 200), color(200, 200, 255)
      };
      fill(255);
      beginShape();
      for (PVector pv : toPointArray ()) {
        vertex(pv.x, pv.y);
      }
      endShape(CLOSE);
    }
    PVector[] toPointArray() {
      PVector start=l.get(0).a;
      boolean used[]=new boolean[l.size()];
      ArrayList<PVector> list=new ArrayList<PVector>();
      toPointArray(start, used, list);
      //if (used.length!=list.size())println("エラー発生 "+type+" length:"+ used.length+" list:"+list.size());
      return list.toArray(new PVector[0]);
    }
    void toPointArray(PVector now, boolean used[], ArrayList<PVector> list) {
      for (int i=0; i<used.length; i++) {
        if (used[i]) {
          continue;
        }
        PVector tmp=l.get(i).getNot(now);
        if (tmp!=null) {
          used[i]=true;
          list.add(tmp);
          toPointArray(tmp, used, list);
          return;
        }
      }
    }
  }
  class Line {
    boolean isSuper=false;
    PVector a, b;
    int useCount=0;
    boolean frame=false;
    PVector separatePoint[];
    Line(PVector a, PVector b) {
      this.a=a;
      this.b=b;
      useCount=1;
    }
    boolean isSuper() {
      return isSuper;
    }
    PVector[] getSeparatePoint() {
      if (frame) {
        return null;
      }
      if (separatePoint==null) {
        separatePoint=new SplitLine(a, b).create(8);
      }
      return separatePoint;
    }
    void use() {
      useCount++;
    }
    PVector getNot(PVector c) {
      if (a.equals(c)) {
        return b;
      }
      if (b.equals(c)) {
        return a;
      }
      return null;
    }
    void inverse() {
      PVector t=a;
      a=b;
      b=t;
    }
    boolean needed() {
      return(useCount!=0);
    }
    boolean contains(PVector p) {
      return(p.equals(a)||p.equals(b));
    }
    boolean equals(Line l) {
      if (this==l) {
        return true;
      }
      return ((a.equals(l.a)&&b.equals(l.b))||(a.equals(l.b)&&b.equals(l.a)));
    }
    boolean equals(PVector la, PVector lb) {
      return ((a.equals(la)&&b.equals(lb))||(a.equals(lb)&&b.equals(la)));
    }


    void setFrame() {
      frame=true;
    }
    boolean isFrame() {
      return frame;
    }
    float length() {
      return a.dist(b);
    }
    PVector getMidpoint() {
      PVector ans=PVector.add(a, b);
      ans.div(2);
      return ans;
    }
  }
  void draw2D() {
    for (Tri tri : tris) {
      if (tri.type!=0)
        tri.draw2D();
    }
    for (Line l : lines) {
      if (l.isSuper) {
        stroke(255, 0, 0);
        line(l.a.x, l.a.y, l.b.x, l.b.y);
      }
    }
    //println(axis.size()+" "+axisLine.size());
//    for (PVector axisPoint : axis) {
//      fill(255, 0, 0);
//      stroke(255, 0, 0);
//      pushMatrix();
//      translate(axisPoint.x, axisPoint.y);
//      sphere(5);
//      popMatrix();
//      noFill();
//      stroke(0);
//    }
//    for (Line aL : axisLine) {
//      stroke(255, 0, 0);
//      strokeWeight(3);
//      line(aL.a.x, aL.a.y, aL.b.x, aL.b.y);
//      strokeWeight(1);
//    }
  }

  void draw3D() {
    for (Tri tri : tris) {
      if (tri.type!=0)
        tri.draw3D();
    }
  }
  void setFrame(ArrayList<Point> frame) {
    frameBackup=frame.toArray(new Point[0]);
    for (Line l : lines) {
      PVector a=frame.get(0), b;
      for (int i=1, n=frame.size (); i<=n; i++) {
        b=frame.get(i%n);
        if (l.equals(a, b)) {
          l.setFrame();
          break;
        }
        a=b;
      }
    }
  }

  void makeFan() {
    for (int i=0; i<tris.size (); i++) {
      Tri tri=tris.get(i);
      if (tri.type==2) {
        tri.type=3;
        if (makeFan(tri, tri.getNotFrame()[0])) {
          i=tris.indexOf(tri);
        }
      }
    }

    for (Tri t : tris) {
      println("vertex "+t.l.size());
    }
  }
  boolean makeFan(Tri tri, Line line) {
    println(tri.getNotFrame().length);
    if (tri.makedfan()) {
      return false;
    }
    boolean lastFan=!neededFan(tri, line);
    for (Tri t : tris) {
      if (t.l.indexOf(line)==-1) {
        continue;
      }
      switch(t.type) {
      case 1:
        tri.remove(line);
        t.remove(line);
        Line next[]=t.getNotFrame();
        println(Arrays.toString(next));
        tri.add(t);
        tris.remove(t);
        if (lastFan) {
          PVector newPoint=next[0].getMidpoint();
          tris.addAll(tri.splitTri(newPoint, next[0]));//分割
          points.add(newPoint);
          return true;
        }
        if (next.length==1) {
          makeFan(tri, next[0]);
        }        
        return true;
      case 0:
        //へこませる処理
        PVector newPoint=t.getCenter();//calcFarPoint(tri, t, line);
        t.addPointToLine(newPoint, line);
        tris.addAll(tri.splitTri(newPoint, line));//分割
        tris.remove(tri);
        points.add(newPoint);
        return true;
      }
    }
    return false;
  }
  PVector getMidpoint(PVector a, PVector b) {
    PVector c=PVector.add(a, b);
    c.div(2);
    return c;
  }
  boolean ifFarPoints(PVector target, PVector point[], float dist) {
    for (PVector pv : point) {
      if (target.dist(pv)<dist) {
        return false;
      }
    }
    return true;
  }
  PVector calcFarPoint(Tri outside, Tri inside, Line splitLine) {
    PVector point[]=outside.getNotLinePoint(splitLine);//キョリを図る点群
    PVector out=splitLine.getMidpoint();
    PVector in=inside.getCenter();
    PVector explorer=getMidpoint(in, out);
    PVector lastGotoOut=null;
    for (int i=0; i<3; i++) {
      if (ifFarPoints(explorer, point, splitLine.a.dist(explorer))) {
        lastGotoOut=explorer;
        in=explorer;
        explorer=getMidpoint(explorer, out);
      } else {
        out=explorer;
        explorer=getMidpoint(explorer, in);
      }
    }
    if (lastGotoOut!=null&&!ifFarPoints(explorer, point, splitLine.a.dist(explorer))) {
      return lastGotoOut;
    }
    return explorer;
  }
  boolean neededFan(Tri tri, Line line) {
    PVector p[]=tri.getNotLinePoint(line);
    float length=line.length()/2;
    PVector midpoint=line.getMidpoint();
    for (PVector pv : p) {
      if (midpoint.dist(pv)>=length) {
        println("やる必要なんてなかった");
        tri.fan();
        return false;
      }
    }
    return true;
  }
  void chordalAxis() {
    for (int i=0; i<tris.size (); i++) {
      Tri tri=tris.get(i);
      switch(tri.type) {
      case 0:
        PVector center=tri.getCenter();
        for (Line l : tri.oldLine) {
          PVector mid=l.getMidpoint();
          Tri tmp=new Tri(3, center, mid, l.a);
          axisLine.add(new Line(center, mid));
          tris.add(tmp);
          tris.add(new Tri(3, center, mid, l.b));
        }
        tris.remove(tri);
        i--;
        break;
      case 1:
        Line l[]=tri.getNotFrame();
        Line frame=tri.getFrame()[0];
        PVector mpa=frame.getMidpoint();
        PVector mpb=l[0].getMidpoint();
        PVector mpc=l[1].getMidpoint();
        PVector a=tri.getNotLinePoint(frame)[0];
        PVector b=l[1].getNot(a);
        PVector c=l[0].getNot(a);
        Tri tmp;
        tmp=new Tri(3, a, mpb, mpc);
        axisLine.add(new Line(mpb, mpc));
        tris.add(tmp);

        if (b.dist(mpc)<c.dist(mpb)) {
          tris.add(new Tri(3, b, mpb, mpc));
          tris.add(new Tri(3, b, mpb, c));
        } else {
          tris.add(new Tri(3, c, mpc, mpb));
          tris.add(new Tri(3, c, mpc, b));
        }
        tris.remove(tri);
        i--;
        break;
      }
    }
  }
}

