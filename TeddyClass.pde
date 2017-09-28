FixStroke strokeFixer=new FixStroke(2,10,20,40);

class Teddy {
  ArrayList<Point> frame;
  Model model;
  DelaunayTriangles delaunay;
  Axis axis;
  int creationType=2; 
  int frameLength(ArrayList<PVector> line) {
    float sum=0;
    for (int i=0, n=line.size (); i<n; i++) {
      sum+=line.get(i).dist(line.get((i+1)%n));
    }
    return (int)(sum/3);
  }
  boolean ready=false;
  Teddy(ArrayList<PVector> line, int creationType,FixStroke strokeFixer) {
    this.creationType=creationType;
    int frameL=frameLength(line);
    if(frameL<5)return;
    line=strokeFixer.fix(line);
    ArrayList<Point> frame=cull(line, frameL);
    if (frame.size()<=5)return;
    try {
      CreateSecond createSecond=null;
      if (creationType==2) {
        createSecond=new CreateSecond(frame.toArray(new Point[0]), -2);
        createSecond.start();
      }
      if (creationType==3) {
        createSecond=new CreateSecond(frame.toArray(new Point[0]), -3);
        createSecond.start();
      }
      DelaunayTriangles delaunay=createDelaunay(/*line, */frame);
      model=new Model();
      for (Triangle tri : (Set<Triangle>)delaunay.triangleSet) {
        model.addTriangle(tri.type, (PVector)tri.p1, (PVector)tri.p2, (PVector)tri.p3);
      }
      println("setframe");
      model.setFrame(frame);
      println("makeFan");
      model.makeFan();
      println("chordalAxis");
      model.chordalAxis();
      model=new Model(model);//最適化
      println("setFrame");
      model.setFrame(frame);
      println("to3D");
      model.to3D(creationType, frame);


      if (creationType==2||creationType==3) {
        try {
          createSecond.join();
        }
        catch(Exception e) {
        }
        Model ms[]=createSecond.getModels();
        if (creationType==3) {
          model=new Model(-3, model, ms[0], new Model(model.getSuperStroke(false), ms[0].getSuperStroke(true)));

          //model=new Model(model);
          //ms[0]=new Model(ms[0]);
          //model=new Model(model.getSuperStroke(false), ms[0].getSuperStroke(true));
        } else {
          model=new Model(model, ms[0]);//new Model(true, model, ms[0], ms[1]);
          model=new Model(true, model, ms[1]);
        }
      } else {
        model=new Model(true, model);//最適化
      }
      ready=true;
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  boolean isReady() {
    return ready;
  }


  Point[] createArc(PVector a, PVector b, int n) {
    PVector c=PVector.add(a, b);
    c.div(2);
    float r=PVector.dist(a, c);
    Point ans[]=new Point[n];
    float ang=PI/(n-1);
    for (int i=0; i<n; i++) {
      ans[i]=new Point(PVector.sub(b, c));
      ans[i].mult(cos(ang*i));
      ans[i].add(c);
      ans[i].z=sin(ang*i)*r;
    }
    return ans;
  }
  class CreateSecond extends Thread {
    Point[] frame, frame2;
    int creationType;
    Model model2, model3;
    CreateSecond(Point[] frame, int creationType) {
      this.frame=frame;
      this.creationType=creationType;
    }
    public void run() {
      println("second start");
      if (frame==null) {
        return;
      }
      println(frame==null);
      createOuterFrame(frame);
      CreateThird createThird=null;
      if (creationType==-2) {
        createThird=new CreateThird(frame, frame2);
      }
      if (creationType==-3) {
        PVector f[]=new PVector[10];
        PVector f21=new PVector(frame2[0].x, frame2[0].y, frame2[0].z);
        PVector f22=new PVector(frame2[frame.length-1].x, frame2[frame.length-1].y, frame2[frame.length-1].z);
        f21.z=-3;
        f22.z=-3;
        createThird=new CreateThird(createArc(frame[0], frame[frame.length-1], 20), createArc(f21, f22, 20));
        //        frame2[0]=frame[0];
        //        frame2[frame.length-1]=frame[frame.length-1];
      }
      createThird.start();
      ArrayList<Point> frame2L=new ArrayList<Point>();
      for (PVector f : frame2) {
        frame2L.add(new Point(f));
      }
      println("おｋ１");

      DelaunayTriangles delaunay2=createDelaunay(/*line, */frame2L);
      println("おｋ");
      model2=new Model();
      for (Triangle tri : (Set<Triangle>)delaunay2.triangleSet) {
        model2.addTriangle(tri.type, (PVector)tri.p1, (PVector)tri.p2, (PVector)tri.p3);
      }
      model2.setFrame(frame2L);
      model2.makeFan();
      model2.chordalAxis();
      model2=new Model(model2);//最適化
      model2.setFrame(frame2L);
      model2.to3D(creationType, frame2L);//outer;
      println("second ok");
      try {
        createThird.join();
      }
      catch(Exception e) {
      }
    }
    void createOuterFrame(Point frame[]) {
      float time=3;
      frame2=new Point[frame.length];

      float ang=0;
      for (int i=0; i<frame.length; i++) {
        PVector A=frame[(frame.length+i-1)%frame.length];
        PVector O=frame[i];
        PVector B=frame[(i+1)%frame.length];
        PVector AO=PVector.sub(O, A);
        PVector OB=PVector.sub(B, O);
        AO.normalize();
        OB.normalize();
        ang+=AO.x*OB.y-AO.y*OB.x;
      }  
      for (int i=0; i<frame.length; i++) {
        PVector A=frame[(frame.length+i-1)%frame.length];
        PVector O=frame[i];
        PVector B=frame[(i+1)%frame.length];
        PVector AO=PVector.sub(O, A);
        PVector BO=PVector.sub(O, B);
        AO.normalize();
        BO.normalize();
        PVector dir=PVector.add(AO, BO);
        dir.normalize();
        if (dir.magSq()<0.1) {
          BO.rotate(HALF_PI);
          if (ang<0) {
            BO.mult(-1);
          }
          BO.mult(time);
          frame2[i]=new Point(frame[i].x, frame[i].y);
          frame2[i].add(BO);
          continue;
        }
        if ((AO.x*dir.y-AO.y*dir.x)*ang>0) {
          dir.mult(-1);
        }
        frame2[i]=new Point(frame[i].x, frame[i].y);
        dir.mult(time);
        frame2[i].add(dir);
      }
    }
    Model[] getModels() {
      return new Model[] {
        model2, model3
      };
    }

    class CreateThird extends Thread {
      Point[] frame, frame2;
      CreateThird(Point[] frame, Point[] frame2) {
        this.frame=frame;
        this.frame2=frame2;
      }
      public void run() {
        model3=new Model(frame, frame2);
      }
    }
  }


  DelaunayTriangles createDelaunay(ArrayList<Point> frame) {
    DelaunayTriangles delaunay=new DelaunayTriangles(frame); 
    delaunay.delete(frame);
    return delaunay;
  }
  //  DelaunayTriangles createDelaunay(ArrayList<PVector> line, ArrayList<Point> frame) {
  //    DelaunayTriangles delaunay=new DelaunayTriangles(frame); 
  //    delaunay.delete(frame);
  //    return delaunay;
  //  }
  ArrayList<Point> cull(ArrayList<PVector> line, int n) {
    double dist[]=new double[line.size()];
    double sumDist=0;
    for (int i=0; i<dist.length-1; i++) {
      PVector a=line.get(i), b=line.get(i+1);
      double dx=a.x-b.x;
      double dy=a.y-b.y;
      dist[i]=Math.sqrt(dx*dx+dy*dy);
      sumDist+=dist[i];
    }
    if (creationType!=3) {
      PVector a=line.get(0), b=line.get(line.size()-1);
      double dx=a.x-b.x;
      double dy=a.y-b.y;
      dist[dist.length-1]=Math.sqrt(dx*dx+dy*dy);
      sumDist+=dist[dist.length-1];
    }
    double criteria=sumDist/n;
    Point ans[]=new Point[n];
    ans[0]=new Point(line.get(0).x, line.get(0).y);
    int index=1;
    double stackDist=0;
    for (int i=0; i<=dist.length; i++) {
      stackDist+=dist[i];
      while (true) {
        if (stackDist<=criteria) {
          break;
        }
        //まだ，その辺の中で頂点を取れる場合
        ans[index]=new Point();
        {
          double bd=stackDist-criteria;
          double ad=dist[i]-bd;
          PVector a=line.get(i), b=line.get((i+1)%line.size());
          ans[index].x=(float)((a.x*bd+b.x*ad)/(dist[i]));
          ans[index].y=(float)((a.y*bd+b.y*ad)/(dist[i]));
        }
        index++;
        if (index==n) {
          return new ArrayList(Arrays.asList(ans));
        }
        stackDist-=criteria;
      }
    }
    return null;
  }

  void draw() {
    stroke(0);
    if (is3D) {
      model.draw3D();
    } else {
      model.draw2D();
    }
    //    axis.draw();
  }
  boolean is3D=false;
}

