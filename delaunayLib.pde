import java.util.*;

class Point extends PVector {  
  // ======================================  
  // コンストラクタ  
  // ======================================  
  public Point() {  
    super();
  }  
  public Point(float x, float y) {  
    super(x, y);
  }  
  public Point(float x, float y, float z) {  
    super(x, y, z);
  }  
  public Point(PVector v) {  
    this.x = v.x;  
    this.y = v.y;  
    this.z = v.z;
  }  

  // ======================================  
  // 同値判定  
  // ======================================  
  public boolean equals(Object o) {  
    boolean retVal;  
    try {  
      PVector p = (PVector)o;  
      return (x == p.x && y == p.y && z == p.z);
    } 
    catch (Exception ex) {  
      return false;
    }
  }  

  // ======================================  
  // 描画  
  // ======================================    
  public void draw() {  
    point(x, y);
  }
}  
class Circle {  
  // 中心座標と半径  
  Point center;  
  float radius;  

  // ======================================  
  // コンストラクタ  
  // 中心座標と半径を与えて円をつくるよ  
  // ======================================  
  public Circle(PVector c, float r) {  
    this.center = new Point(c);  
    this.radius = r;
  }  

  // ======================================  
  // 描画（デバッグ用）  
  // ======================================    
  public void draw() {  
    ellipse(center.x, center.y, radius * 2, radius * 2);
  }
}  

class Triangle {
  final int typeJ=0, typeS=1, typeT=2;
  int type;
  public Point p1, p2, p3;  // 頂点  
  // ======================================  
  // コンストラクタ  
  // 3頂点を与えて三角形をつくるよ  
  // 頂点はPointで与えてもOK  
  // ======================================  
  public Triangle(Point p1, Point p2, Point p3) {  
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }
  Point[][] getLine() {
    return new Point[][] {
      {
        p1, p2
      }
      , {
        p2, p3
      }
      , {
        p3, p1
      }
    };
  }
  boolean contains(Point a, Point b) {
    return (
    p1.equals(a)&&p2.equals(b)||
      p2.equals(a)&&p3.equals(b)||
      p3.equals(a)&&p1.equals(b)||
      p1.equals(b)&&p2.equals(a)||
      p2.equals(b)&&p3.equals(a)||
      p3.equals(b)&&p1.equals(a)
      );
  }


  // ======================================  
  // 同値判定  
  // ======================================  
  public boolean equals(Object obj) {  
    try {  
      Triangle t = (Triangle)obj;  
      // ※ 同値判定に頂点を用いると、  
      // 三角形の頂点の順番を網羅的に考慮する分条件判定が多くなる。  
      return(p1.equals(t.p1) && p2.equals(t.p2) && p3.equals(t.p3) ||  
        p1.equals(t.p2) && p2.equals(t.p3) && p3.equals(t.p1) ||  
        p1.equals(t.p3) && p2.equals(t.p1) && p3.equals(t.p2) ||  

        p1.equals(t.p3) && p2.equals(t.p2) && p3.equals(t.p1) ||  
        p1.equals(t.p2) && p2.equals(t.p1) && p3.equals(t.p3) ||  
        p1.equals(t.p1) && p2.equals(t.p3) && p3.equals(t.p2) );
    } 
    catch (Exception ex) {  
      return false;
    }
  }  

  // ======================================  
  // ハッシュ表で管理できるよう、hashCodeをオーバーライド  
  // ======================================  
  public int hashCode() {  
    return 0;
  }  

  // ======================================  
  // 描画  
  // ======================================    
  public void draw() {  
    color c[]= {
      color(255, 200, 200), color(255), color(255, 255, 200)
    };
    fill(c[type]);
    triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  }  

  // ======================================  
  // 他の三角形と共有点を持つか  
  // ======================================    
  public boolean hasCommonPoints(Triangle t) {  
    return (p1.equals(t.p1) || p1.equals(t.p2) || p1.equals(t.p3) ||  
      p2.equals(t.p1) || p2.equals(t.p2) || p2.equals(t.p3) ||  
      p3.equals(t.p1) || p3.equals(t.p2) || p3.equals(t.p3) );
  }
}  
class DelaunayTriangles {  
  public HashSet triangleSet;  // 三角形リスト  

  // ======================================  
  // コンストラクタ  
  // 与えられた点のリストを基にDelaunay分割を行う  
  // ======================================  
  public DelaunayTriangles(ArrayList pointList) {  
    DelaunayTriangulation(pointList);
  }  

  // ======================================  
  // 点のリストを与えて、Delaunay三角分割を行う  
  // ======================================  
  public void DelaunayTriangulation(ArrayList pointList) {  
    // 三角形リストを初期化  
    triangleSet = new HashSet();  

    // 巨大な外部三角形をリストに追加  
    Triangle hugeTriangle = getHugeTriangle();  
    triangleSet.add(hugeTriangle);  

    try {  
      // --------------------------------------  
      // 点を逐次添加し、反復的に三角分割を行う  
      // --------------------------------------  
      for (Iterator pIter = pointList.iterator (); pIter.hasNext(); ) {  
        Object element = pIter.next();  
        Point p = element instanceof Point ?   
        (Point)element : new Point((PVector)element);  

        // --------------------------------------  
        // 追加候補の三角形を保持する一時ハッシュ  
        // --------------------------------------  
        // 追加候補の三角形のうち、「重複のないものだけ」を  
        // 三角形リストに新規追加する  
        //          → 重複管理のためのデータ構造  
        // tmpTriangleSet  
        //  - Key   : 三角形  
        //  - Value : 重複していないかどうか  
        //            - 重複していない : true  
        //            - 重複している   : false  
        // --------------------------------------  
        HashMap tmpTriangleSet = new HashMap();  

        // --------------------------------------  
        // 現在の三角形リストから要素を一つずつ取り出して、  
        // 与えられた点が各々の三角形の外接円の中に含まれるかどうか判定  
        // --------------------------------------  
        for (Iterator tIter=triangleSet.iterator (); tIter.hasNext(); ) {  
          // 三角形リストから三角形を取り出して…  
          Triangle t = (Triangle)tIter.next();  

          // その外接円を求める。  
          Circle c = getCircumscribedCirclesOfTriangle(t);  

          // --------------------------------------  
          // 追加された点が外接円内部に存在する場合、  
          // その外接円を持つ三角形をリストから除外し、  
          // 新たに分割し直す  
          // --------------------------------------  
          if (Point.dist(c.center, p) <= c.radius) {  
            // 新しい三角形を作り、一時ハッシュに入れる  
            addElementToRedundanciesMap(tmpTriangleSet, 
            new Triangle(p, t.p1, t.p2));  
            addElementToRedundanciesMap(tmpTriangleSet, 
            new Triangle(p, t.p2, t.p3));  
            addElementToRedundanciesMap(tmpTriangleSet, 
            new Triangle(p, t.p3, t.p1));  

            // 旧い三角形をリストから削除  
            tIter.remove();
          }
        }  

        // --------------------------------------  
        // 一時ハッシュのうち、重複のないものを三角形リストに追加   
        // --------------------------------------  
        for (Iterator tmpIter = tmpTriangleSet.entrySet ().iterator(); 
        tmpIter.hasNext(); ) {  

          Map.Entry entry = (Map.Entry)tmpIter.next();  
          Object t = entry.getKey();  

          boolean isUnique =   
            ((Boolean)entry.getValue()).booleanValue();  

          if (isUnique) {  
            triangleSet.add(t);
          }
        }
      }  

      // 最後に、外部三角形の頂点を削除  
      for (Iterator tIter = triangleSet.iterator (); tIter.hasNext(); ) {  
        // 三角形リストから三角形を取り出して  
        Triangle t = (Triangle)tIter.next();  
        // もし外部三角形の頂点を含む三角形があったら、それを削除  
        if (hugeTriangle.hasCommonPoints(t)) {  
          tIter.remove();
        }
      }
    } 
    catch (Exception ex) {  
      return;
    }
  }  

  // ======================================  
  // 描画  
  // ======================================  
  public void draw() {  
    for (Iterator it = triangleSet.iterator (); it.hasNext(); ) {  
      Triangle t = (Triangle)it.next();  
      t.draw();
    }
  }  


  // ======================================  
  // ※ ここからprivateメソッド  
  // ======================================  


  // ======================================  
  // 一時ハッシュを使って重複判定  
  // hashMap  
  //  - Key   : 三角形  
  //  - Value : 重複していないかどうか  
  //            - 重複していない : true  
  //            - 重複している   : false  
  // ======================================  
  private void addElementToRedundanciesMap(HashMap hashMap, Object t)  
  {  
    if (hashMap.containsKey((Triangle)t)) {  
      // 重複あり : Keyに対応する値にFalseをセット  
      hashMap.put(t, new Boolean(false));
    } else {  
      // 重複なし : 新規追加し、  
      hashMap.put(t, new Boolean(true));
    }
  }  

  // ======================================  
  // 最初に必要な巨大三角形を求める  
  // ======================================  
  // 画面全体を包含する正三角形を求める  
  private Triangle getHugeTriangle() {  
    return getHugeTriangle(new PVector(0, 0), 
    new PVector(width, height));
  }  
  // 任意の矩形を包含する正三角形を求める  
  // 引数には矩形の左上座標および右下座標を与える  
  private Triangle getHugeTriangle(PVector start, PVector end) {  
    // start: 矩形の左上座標、  
    // end  : 矩形の右下座標…になるように  
    if (end.x < start.x) {  
      float tmp = start.x;  
      start.x = end.x;  
      end.x = tmp;
    }  
    if (end.y < start.y) {  
      float tmp = start.y;  
      start.y = end.y;  
      end.y = tmp;
    }  

    // 1) 与えられた矩形を包含する円を求める  
    //      円の中心 c = 矩形の中心  
    //      円の半径 r = |p - c| + ρ  
    //    ただし、pは与えられた矩形の任意の頂点  
    //    ρは任意の正数  
    Point center = new Point( (end.x - start.x) / 2.0, 
    (end.y - start.y) / 2.0 );  
    float radius = Point.dist(center, start) + 1.0;  

    // 2) その円に外接する正三角形を求める  
    //    重心は、円の中心に等しい  
    //    一辺の長さは 2√3･r  
    float x1 = center.x - sqrt(3) * radius;  
    float y1 = center.y - radius;  
    Point p1 = new Point(x1, y1);  

    float x2 = center.x + sqrt(3) * radius;  
    float y2 = center.y - radius;  
    Point p2 = new Point(x2, y2);  

    float x3 = center.x;  
    float y3 = center.y + 2 * radius;  
    Point p3 = new Point(x3, y3);  

    return new Triangle(p1, p2, p3);
  }  

  // ======================================  
  // 三角形を与えてその外接円を求める  
  // ======================================  
  private Circle getCircumscribedCirclesOfTriangle(Triangle t) {  
    // 三角形の各頂点座標を (x1, y1), (x2, y2), (x3, y3) とし、  
    // その外接円の中心座標を (x, y) とすると、  
    //     (x - x1) * (x - x1) + (y - y1) * (y - y1)  
    //   = (x - x2) * (x - x2) + (y - y2) * (y - y2)  
    //   = (x - x3) * (x - x3) + (y - y3) * (y - y3)  
    // より、以下の式が成り立つ  
    //  
    // x = { (y3 - y1) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)  
    //     + (y1 - y2) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1)} / c  
    //  
    // y = { (x1 - x3) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)  
    //     + (x2 - x1) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1)} / c  
    //  
    // ただし、  
    //   c = 2 * {(x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)}  

    float x1 = t.p1.x;  
    float y1 = t.p1.y;  
    float x2 = t.p2.x;  
    float y2 = t.p2.y;  
    float x3 = t.p3.x;  
    float y3 = t.p3.y;  

    float c = 2.0 * ((x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1));  
    float x = ((y3 - y1) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)  
      + (y1 - y2) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1))/c;  
    float y = ((x1 - x3) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)  
      + (x2 - x1) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1))/c;  
    Point center = new Point(x, y);  

    // 外接円の半径 r は、半径から三角形の任意の頂点までの距離に等しい  
    float r = Point.dist(center, t.p1);  

    return new Circle(center, r);
  }
  void delete(ArrayList<Point> frame) {
big:
    while (true) {
      for (Triangle t : (Set<Triangle>)triangleSet) {
small:
        for (Point p[] : t.getLine ()) {
          Point a=frame.get(0), b=null;
          for (int i=1, n=frame.size (); i<=n; i++) {
            b=frame.get(i%n);
            if ((p[0]==a&&p[1]==b)||(p[0]==b&&p[1]==a)) {
              continue small;
            }
            a=b;
          }
          int count=0;
          for (Triangle t1 : (Set<Triangle>)triangleSet) {
            if (t1.contains(p[0], p[1])) {
              count++;
            }
          }
          if (count==1) {
            triangleSet.remove(t);
            continue big;
          }
        }
      }
      break;
    }
    Point a=frame.get(0), b=null;
    for (Triangle t : (Set<Triangle>)triangleSet) {
      int count=0;
      for (int i=1, n=frame.size (); i<=n; i++) {
        b=frame.get(i%n);
        if (t.contains(a, b)) {
          count++;
        }
        a=b;
      }
      t.type=count;
    }
  }
  
  void delete0(ArrayList<Point> frame) {
    Triangle[] ta=((Set<Triangle>)triangleSet).toArray(new Triangle[0]);
    ArrayList<Triangle> triangleArray=new ArrayList<Triangle>(Arrays.asList(ta));
    for (int index=0; index<triangleArray.size (); index++) {
      Triangle t=triangleArray.get(index);
small:
      for (Point p[] : t.getLine ()) {
        Point a=frame.get(0), b=null;
        for (int i=1, n=frame.size (); i<=n; i++) {
          b=frame.get(i%n);
          if ((p[0]==a&&p[1]==b)||(p[0]==b&&p[1]==a)) {
            continue small;
          }
          a=b;
        }
        int count=0;
        for (Triangle t1 : (Set<Triangle>)triangleSet) {
          if (t1.contains(p[0], p[1])) {
            count++;
          }
        }
        if (count==1) {
          triangleSet.remove(t);
          triangleArray.remove(t);
          index--;
        }
      }
      break;
    }
    Point a=frame.get(0), b=null;
    for (Triangle t : (Set<Triangle>)triangleSet) {
      int count=0;
      for (int i=1, n=frame.size (); i<=n; i++) {
        b=frame.get(i%n);
        if (t.contains(a, b)) {
          count++;
        }
        a=b;
      }
      t.type=count;
    }
  }
}

