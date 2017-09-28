class Axis {
  Axis() {
  }
  ArrayList<PVector> points;
  DelaunayTriangles chordal(Model model, ArrayList<Point> frame) {
    points=new ArrayList<PVector>();
    points.addAll(model.points);
    for (Model.Tri tri : model.tris) {
      Model.Line ls[]=tri.getNotFrame();
      
      switch(tri.type) {
      case 0:
        points_add(points, tri.getCenter());
        for (Model.Line l : tri.oldLine) {
          points_add(points, l.getMidpoint());
        }
        for (PVector pv : tri.newPointByFan) {
          points_add(points, pv);
        }
        break;
      case 1:
        for (Model.Line l : ls) {
          points_add(points, l.getMidpoint());
        }
        break;
      }
    }
    return createDelaunay(points, frame);
  }
  DelaunayTriangles createDelaunay(ArrayList<PVector> line, ArrayList<Point> frame) {
    DelaunayTriangles delaunay=new DelaunayTriangles(line); 
    delaunay.delete(frame);
    return delaunay;
  }
  void points_add(ArrayList<PVector> points, PVector p) {
    for (PVector pv : points) {
      if (pv.equals(p)) {
        return;
      }
    }
    points.add(p);
  }
  void draw(){
    fill(0);
    for(PVector pv:points){
      ellipse(pv.x,pv.y,10,10);
    }
  }
}

