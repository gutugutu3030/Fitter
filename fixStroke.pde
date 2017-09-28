class FixStroke {
  int basicCullInterval=1;
  int catmullRomDetail=15;
  float thresholdAngle=18,thresholdDist=50;
  FixStroke(){
    this(1,10,18,50);
  }
  FixStroke(int basicCullInterval,int catmullRomDetail,float thresholdAngle,float thresholdDist) {
    this.basicCullInterval=basicCullInterval;
    this.catmullRomDetail=catmullRomDetail;
    this.thresholdAngle=thresholdAngle;
    this.thresholdDist=thresholdDist;
  }
  ArrayList<PVector> fix(ArrayList<PVector> before) {
    ArrayList<PVector> after=new ArrayList<PVector>();
    before=basicCull(before, basicCullInterval);
    after=catmullRom(before,catmullRomDetail);
    before=basicCull(before, basicCullInterval);
    after=popo(before,thresholdAngle,thresholdDist);
    return after;
  }

  float calcAngle(PVector a, PVector b, PVector c) {
    PVector ab=PVector.sub(b, a);
    PVector bc=PVector.sub(c, b);
    ab.normalize();
    bc.normalize();
    return ((ab.x*bc.y-ab.y*bc.x>0)?-1:1)*acos(max(min(ab.dot(bc), 1), -1));
  }

  ArrayList<PVector> basicCull(ArrayList<PVector>before, int dist) {
    ArrayList<PVector>  after=new ArrayList<PVector>();
    after.add(before.get(0));
    for (int i=1; i<before.size (); i++) {
      if (PVector.dist(after.get(after.size()-1), before.get(i))<dist) {
        continue;
      }
      after.add(before.get(i));
    }
    return after;
  }

  ArrayList<PVector> popo(ArrayList<PVector> before,float thresholdAngle,float thresholdDist) {
    float dist=0;
    float angle=0;
    int index=0;
    boolean deleting=false;
    ArrayList<PVector> delete=new ArrayList<PVector>();
    for (int i=1; i<before.size ()-1; i++) {
      if (deleting) {
        angle+=degrees(calcAngle(before.get(i-1), before.get(i), before.get(i+1)));
        if (abs(angle)<thresholdAngle) {
          dist+=PVector.dist(before.get(i), before.get(i+1));
          continue;
        }
        //直線とみなせる範囲の終了
        deleting=false;
        if (dist<thresholdDist) {
          //短い場合は残す
          continue;
        }
        //長い場合は間の点を削除
        for (int j=index+1; j<i; j++) {
          delete.add(before.get(j));
        }
        continue;
      }
      index=i;
      dist=PVector.dist(before.get(i), before.get(i+1));
      //println(angle);
      angle=0;
      deleting=true;
    }
    if (deleting) {
      if (dist>=30) {
        for (int j=index+1; j<before.size ()-1; j++) {
          delete.add(before.get(j));
        }
      }
    }
    ArrayList<PVector>  after=new ArrayList<PVector>();
    int delIndex=0;
    for (PVector p : before) {    
      if (delIndex<delete.size()&&p==delete.get(delIndex)) {
        delIndex++;
        continue;
      }
      after.add(p);
    }
    return after;
  }
  ArrayList<PVector> catmullRom(ArrayList<PVector> before,int detail) {
    ArrayList<PVector> after=new ArrayList<PVector>();
    PVector a, b, c, d;
    for (int i=0; i<before.size ()-1; i++) {
      a=(i==0)?before.get(0):before.get(i-1);
      b=before.get(i);
      c=before.get(i+1);
      d=(i==before.size()-2)?before.get(before.size()-1):before.get(i+2);
      float w=1.0/detail;
      for (int j=0; j<detail; j++) {
        float x=catmullRom(a.x, b.x, c.x, d.x, w*j);
        float y=catmullRom(a.y, b.y, c.y, d.y, w*j);
        after.add(new PVector(x, y));
      }
    }
    after.add(before.get(before.size()-1));
    return after;
  }

  ArrayList<PVector> cull(ArrayList<PVector> before, float alpha) {
    ArrayList<Segment> featurePoint=new ArrayList<Segment>();
    for (int i=1; i<before.size ()-1; i++) {
      if (PVector.dist(before.get(i-1), before.get(i))==0) {
        continue;
      }
      featurePoint.add(new Segment(before.get(i-1), before.get(i), before.get(i+1)));
    }
    Collections.sort(featurePoint);
    ArrayList<PVector> culling=new ArrayList<PVector>();
    culling.add(before.get(0));
    for (int i=1; i<before.size ()-1; i++) {
      PVector p=before.get(i);
      for (int j=0, n= (int)(featurePoint.size ()*alpha); j<n; j++) {
        if (featurePoint.get(j).equals(p)) {
          culling.add(p);
          break;
        }
      }
    }
    culling.add(before.get(before.size()-1));
    return culling;
  }

  float catmullRom(float p0, float p1, float p2, float p3, float t) {
    float v0 = (p2 - p0) / 2;
    float v1 = (p3 - p1) / 2;
    float t2 = t * t;
    float t3 = t2 * t;
    return (2 * p1 - 2 * p2 + v0 + v1) * t3 + 
      ( -3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 + v0 * t + p1;
  }

  class Segment implements Comparable<Segment> {
    PVector a, b, c;
    float angle;
    float length;
    Segment(PVector a, PVector b, PVector c) {
      this.a=a;
      this.b=b;
      this.c=c;
      length=calcLength(a, b, c);
      angle=calcAngle(a, b, c);
    }
    float calcLength(PVector a, PVector b, PVector c) {
      float length=0;
      length+=PVector.dist(a, b);
      length+=PVector.dist(b, c);
      return length;
    }
    float calcAngle(PVector a, PVector b, PVector c) {
      PVector ba=PVector.sub(a, b);
      PVector bc=PVector.sub(c, b);
      ba.normalize();
      bc.normalize();
      return acos(ba.dot(bc));
    }
    float getFeature() {
      return length/angle;
    }

    boolean equals(PVector p) {
      return b.equals(p);
    }
    int compareTo(Segment s) {    
      if (angle==0&&s.angle!=0) {
        return -1;
      }
      if (angle!=0&&s.angle==0) {
        return 1;
      }
      if (true) {
        return 0;
      }
      if (angle==0&&s.angle==0) {
        if (length<s.length) {
          return 1;
        }
        if (s.length<length) {
          return -1;
        }
        return 0;
      }
      if (getFeature()<s.getFeature()) {
        return 1;
      }
      if (s.getFeature()<getFeature()) {
        return -1;
      }
      return 0;
    }
  }
}

