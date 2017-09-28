class SplitLine {
  float theta, r, h;
  PVector a, b;
  int n;
  void init(PVector a, PVector b) {
    PVector c=PVector.sub(b, new PVector(a.x, a.y, 0));
    r=c.dist(new PVector(0, 0, 0));
    theta=atan2(c.y, c.x);
    this.a=a;
    this.b=b;
    h=a.z;
    n=(int)(PVector.sub(b, a).dist(new PVector(0, 0, 0))/15);
  }
  SplitLine(PVector a, PVector b) {
    if (b.z==0) {
      init(a, b);
    } else {
      init(b, a);
    }
  }
  PVector[] create(int n) {
    PVector pos[]=new PVector[n];
    pos[0]=a;
    pos[pos.length-1]=b;
    for (int i=1; i<pos.length-1; i++) {
      pos[i]=new PVector();
      pos[i].x=cos(theta)*r*sin(radians(90.0/(n-1)*i))+a.x;
      pos[i].y=sin(theta)*r*sin(radians(90.0/(n-1)*i))+a.y;
      pos[i].z=cos(radians(90.0/(n-1)*i))*h;
    }
    return pos;
  }
  PVector[] create() {
    return create(n);
  }
  PVector[] create2() {
    PVector pos[]=new PVector[n-1];
    for (int i=1; i<pos.length; i++) {
      pos[i-1]=new PVector();
      pos[i-1].x=cos(theta)*r*sin(radians(90.0/(n-1)*i))+a.x;
      pos[i-1].y=sin(theta)*r*sin(radians(90.0/(n-1)*i))+a.y;
      pos[i-1].z=cos(radians(90.0/(n-1)*i))*h;
    }
    for(PVector a:pos){
      if(a==null)println("００００００");
    }
    return pos;
  }
}

