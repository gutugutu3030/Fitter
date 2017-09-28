import java.util.*;

class GCode {
  //PShape skinShape;
  StrQue strQue;
  Layer layer[];
  GCode(String path) {
    strQue=new StrQue(path);
    layer=null;
  }

  int time;
  void setTime(int time) {
    this.time=time;
  }
  long startTime=-1;
  void exit() {
    strQue.exit();
  }
  String getTimeString() {
    if (!printing) {
      return null;
    }
    int s=(int)(millis()-startTime)/1000;
    int s1=time-s;
    StringBuilder sb=new StringBuilder();
    if (s1>3600) {
      sb.append(s1/3600);
      sb.append(":");
      s1=s1%3600;
    }
    if (s1>60) {
      sb.append(s1/60);
      sb.append(":");
      s1=s1%60;
    }
    sb.append(s1);
    sb.append(" left");

    return sb.toString();
  }
  void drawFront(PApplet apa) {
    if (layer!=null) {
      for (int i=0; i<layer.length; i++) {
        layer[i].drawFront(apa, i);
      }
    }
  }
  void printAll(Serial port) {
    if (printing) {
      return;
    }
    print(port);
  }
  boolean printing=false;
  boolean pauseQuery=false;
  void pausePrinting() {
    pauseQuery=true;
  }
  boolean send(Serial port, String s) {
    port.write(s+"\n");
    queue++;
    return true||s.charAt(0)=='G';
  }
  void print(Serial port) {
    Print print=new Print();
    print.setPort(port);
    print.start();
  }
  int queue=0;
  void getOKFromPrinter() {
    queue--;
    if (startTime==-1) {
      startTime=millis();
    }
  }
  class Que {
    String str;
    int layer;
    Que(String str, int layer) {
      this.str=str;
      this.layer=layer;
    }
  }
  class StrQue extends Thread {
    ArrayDeque<Que> queue;
    LineReader ld=null;
    int buffer=50;
    StrQue(String path) {
      super();
      ld=new LineReader(path, null);
      queue=new ArrayDeque<Que>();
      start();
    }
    Que get() {
      if (queue.isEmpty()) {
        return null;
      }
      return queue.poll();
    }
    boolean isEmpty() {
      return queue.isEmpty();
    }
    int size() {
      return queue.size();
    }
    boolean exit=false;
    void exit() {
      stop();
      if (ld!=null) {
        try {
        }
        catch(Exception e) {
          ld.close();
        }
      }
    }
    public void run() {
      queue.add(new Que("G28", 0));
      int layerConut=0;
      boolean load=false;
      while (!ld.hadRead ()) {
        if (queue.size()<buffer) {
          if (exit) {
            return;
          }
          String str=ld.read();
          //println(str);
          if (str==null) {
            break;
          }
          if (!load) {
            if (str.indexOf(";Layer count:")!=-1) {
              layer=new Layer[Integer.parseInt(str.substring(";Layer count: ".length()))+1];
              for (int i=0; i<layer.length; i++) {
                layer[i]=new Layer();
              }
              load=true;
            }
            continue;
          }
          if (str.indexOf(";LAYER:")!=-1) {
            layerConut++;
          }
          String d=str.split(";")[0];
          if (d.length()==0) {
            continue;
          }
          queue.add(new Que(d, layerConut));
          continue;
        }
        long elapsed, startTime = System.nanoTime();
        do {
          elapsed = System.nanoTime() - startTime;
        } 
        while (elapsed < 1);
      }
    }
  }
  class Print extends Thread {
    Serial port;
    public void setPort(Serial port) {
      this.port=port;
    }
    public void run() {
      while (strQue==null||strQue.size ()<30) {
        long elapsed;
        final long startTime = System.nanoTime();
        do {
          elapsed = System.nanoTime() - startTime;
        } 
        while (elapsed < 1);
      }
      boolean hasWait=false;
      String code;
      StringBuilder sb=new StringBuilder();
      queue=0;
      printing=true;
      code=strQue.get().str;
      hasWait=send(port, code);
      println("send code:"+code);
      println("empty "+strQue.isEmpty ());
      while (!strQue.isEmpty ()) {
        if (pauseQuery) {
          pauseQuery=false;
          printing=false;
          return;
        }
        if (!hasWait) {
          Que que=strQue.get();
          code=que.str;
          addLayer(que);
          hasWait=send(port, code);
          println("send code:"+code);
          continue;
        }
        while (queue>10) {
          //          try{
          //            Thread.sleep(1);
          //          }catch(Exception e){
          //          }
          long elapsed;
          final long startTime = System.nanoTime();
          do {
            elapsed = System.nanoTime() - startTime;
          } 
          while (elapsed < 1);

          if (pauseQuery) {
            pauseQuery=false;
            printing=false;
            return;
          }
        }
        Que que=strQue.get();
        code=que.str;
        hasWait=send(port, code);
        addLayer(que);
        println("send code:"+code);
      }
    }
  }
  class Layer {
    float minx, maxx;//,miny, maxy;　とりあえずX軸のみ調べる
    boolean hasSet=false;
    void set(String str) {
      if (str.indexOf("G0")==-1&&str.indexOf("G1")==-1) {
        return;
      }
      String data[]=str.split(" ");
      for (String d : data) {
        char xyz=d.charAt(0);
        switch(xyz) {
        case 'X':
          float x=Float.parseFloat(d.substring(1, d.length()));
          if (!hasSet) {
            minx=x;
            maxx=x;
            hasSet=true;
          } else {
            minx=min(minx, x);
            maxx=max(maxx, x);
          }
          break;
          //        case 'Y':
          //          y=Float.parseFloat(d.substring(1, d.length()));
          //          break;
        }
      }
    }
    void drawFront(PApplet apa, int index) {
      if (!hasSet) {
        return;
      }
      float y=0.2*index;
      apa.line(minx, y, maxx, y);
    }
  }
  void addLayer(Que que) {
    final Layer layer1[]=layer;
    final Que que1=que;
    new Thread() {
      public void run() {
        layer1[que1.layer].set(que1.str);
      }
    }
    .start();
  }
}

