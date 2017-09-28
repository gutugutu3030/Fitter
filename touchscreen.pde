class TouchScreen {
  PApplet apa;
  Serial screen;
  int x, y;
  boolean test5_5inch=true;
  boolean testEbay=true;
  boolean rotate180=false;
  float xPos, yPos;
  int mapping[][]= {
    {
      58, 824
    }
    , {
      99, 734
    }
  };
  int oldx=-1, oldy=-1;
  boolean enable=false;
  ;

  TouchScreen(PApplet apa, Serial screen) {
    this.apa=apa;
    this.screen=screen;
    screen.bufferUntil(10);
  }
  void setRotate180(boolean bool){
    rotate180=bool;
  }
  PVector get() {
    if (x>10 && y>10) {
      PVector p=new PVector(map(x, mapping[0][0], mapping[0][1], 0, apa.width), map(y, mapping[1][0], mapping[1][1], 0, apa.height));
      if(test5_5inch){
         p=new PVector(map(x, 177, 561, 500, 1300), map(y, 297,633,200,800));
      }
      if(testEbay){
         p=new PVector(map(x, 123,765,200,1720), map(y, 282,640,200,880));
      }
      if(rotate180){
        p.x=apa.width-p.x;
        p.y=apa.height-p.y;
      }
      return p;
    }
    return null;
  }
  int getX() {
    int p=(int)map(x, mapping[0][0], mapping[0][1], 0, apa.width);
    if(rotate180){
      p=apa.width-p;
    }
    return p;
  }
  int getY() {
    int p=(int)map(y, mapping[1][0], mapping[1][1], 0, apa.height);
    if(rotate180){
      p=apa.height-p;
    }
    return p;
  }
  void start() {
    screen.write(65);
  }
  void setEnable(boolean enable) {
    this.enable=enable;
  }
  boolean isEnable() {
    return enable;
  }
  boolean serialEvent(Serial s) {
    if (screen!=s) {
      return false;
    }
    //文字列の変数stringDataを用意し「10」(ラインフィード)が来るまで読み込む
    String stringData=screen.readStringUntil(10);

    //文字列データが空ではないとき
    if (stringData!=null) {
      //文字列データに含まれる改行記号を取り除く
      stringData=trim(stringData);

      //整数型の配列data[]を用意し、
      //コンマ記号をもとに文字列データを区切って
      //配列data[]に整数化して入れておく
      int data[]=int(split(stringData, ','));

      //配列data[]内のデータが２つなら、
      if (data.length==2) {
        setXY(data);

        //合図用データ送信:send a handshake signal
        screen.write(65);
      }
    }
    return true;
  }

  private void setXY(int data[]) {
    x=data[0];
    y=data[1];
    if (oldx==-1) {
      //初回
      if (enable&&x!=0) {
        mousePressed(getX(), getY());
      }
      oldx=x;
      oldy=y;
      return;
    }
    if (oldx==0&&x!=0) {
      //println(x);
      //println(apa.width);
      //println(map(x, mapping[0][0], mapping[0][1], 0, apa.width));
      if (enable) {
      mousePressed(getX(), getY());
      }
    }
    if (oldx!=0&&x==0) {
      x=oldx;
      y=oldy;
      if (enable) {
      mouseReleased(getX(),getY());
      }
      oldx=0;
      oldy=0;
      return;
    }
    oldx=x;
    oldy=y;
  }
}

