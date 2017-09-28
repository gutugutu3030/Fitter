import extraWindow.ExtraWindow;
import java.awt.Label;
import java.awt.Choice;
import java.awt.Button;
import java.awt.Checkbox;
import java.awt.event.*;
import java.awt.TextField;
import java.awt.datatransfer.DataFlavor;  
import java.awt.datatransfer.Transferable;  
import java.awt.datatransfer.UnsupportedFlavorException;  
import java.awt.dnd.DnDConstants;  
import java.awt.dnd.DropTarget;  
import java.awt.dnd.DropTargetDragEvent;  
import java.awt.dnd.DropTargetDropEvent;  
import java.awt.dnd.DropTargetEvent;  
import java.awt.dnd.DropTargetListener;  
import java.io.File;  
import java.io.IOException;  
import java.util.*;
import java.util.*;

class Control extends ExtraWindow {
  PApplet apa;
  Choice comSelect, howToPrint, creationType;
  Label temp;
  TextField tempT;
  boolean serialReady=false;
  Checkbox support;
  Control(PApplet theApplet, final String theName) {
    super(theApplet, theName, 0, 0, 400, 150);
    apa=theApplet;
  }
  void windowClosing(WindowEvent e) {
    apa.exit();
    super.windowClosing(e);
  }
  void setup() {
    drop_init();
    comSelect=new Choice();
    serialListLength=Serial.list().length;
    comSelect.removeAll();
    for (String com : Serial.list ()) {
      comSelect.add(com);
    }
    add(comSelect);
    Button connectButton=new Button("接続");
    connectButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        connectPrinter();
      }
    }
    );
    add(connectButton);
    Checkbox heat = new Checkbox("set");
    heat.addItemListener(new ItemListener() {
      public void itemStateChanged(ItemEvent e) {
        setHeater(e.getStateChange() == ItemEvent.SELECTED);
      }
    }
    );
    add(heat);
    tempT=new TextField("200");
    add(tempT);
    temp=new Label("------℃");
    add(temp);
    howToPrint=new Choice();
    howToPrint.add("サポート無し");
    howToPrint.add("サポートあり");
    howToPrint.add("0.1mmピッチ");
    howToPrint.select(0);
    add(howToPrint);
    creationType=new Choice();
    creationType.add("完全三次元");
    creationType.add("半分");
    creationType.add("入れ物");
    creationType.add("入れ物2");
    creationType.add("auto");
    creationType.select(4);
    add(creationType);
    Button print=new Button("造形開始");
    print.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        startPrint();
      }
    }
    );
    add(print);
    final Checkbox touch = new Checkbox("touch");
    touch.addItemListener(new ItemListener() {
      public void itemStateChanged(ItemEvent e) {
        touchScreen.setEnable(e.getStateChange() == ItemEvent.SELECTED);
      }
    }
    );
    if (!debugMode) {
      new Thread() {
        public void run() {
          try {
            Thread.sleep(100);
          }
          catch(Exception e) {
          }
          touchScreen.setEnable(true);
        }
      }
      .start();

      add(touch);
      textSize(24);
      new Thread() {
        public void run() {
          try {
            Thread.sleep(100);
          }
          catch(Exception e) {
          }
          touchScreen.setEnable(true);
        }
      }
      .start();
    }
  }
  void startPrint() {
    if (gcode==null) {
      println("slice");
      for (DrawSTL stl : stls) {
        if (stl.outOfField()) {
          println("造形範囲外です");
          return;
        }
      }
      gcode=saveAndCreateGCode();
    }
    if (gcode.printing) {
      println("pause");
      gcode.pausePrinting();
    } else {
      if (printer!=null) {
        println("start printing");
        touchScreen.setEnable(false);
        gcode.printAll(printer);
      }
    }
  }
  void connectPrinter() {
    Serial tmp=new Serial(apa, comSelect.getSelectedItem(), 250000);
    try {
      Thread.sleep(3000);
    }
    catch(Exception e) {
    }
    tmp.write("G28\n");//現在地をホームポジションに戻す
    println("send to pinter: G28");
    tmp.write("G0 X0 Y130 Z30\n");//Z30
    println("send to pinter: G0 X0 Y130 Z30");
    tmp.write("M84\n");//トルクロックを切る
    println("send to pinter: M84");
    printer=tmp;
  }
  void setHeater(boolean on) {
    printer.write((on)?("M104 S"+tempT.getText()+"\n"):"M104 S0\n");
    println("send to pinter: "+((on)?"M104 S200":"M104 S0"));
  }
  int serialListLength=0;
  void draw() {
    background(200);
    if (serialListLength!=Serial.list().length) {
      serialListLength=Serial.list().length;
      comSelect.removeAll();
      for (String com : Serial.list ()) {
        comSelect.add(com);
      }
    }
    if (gcode!=null&&gcode.printing) {
      fill(255, 0, 0);
      text(gcode.getTimeString(), 10, 50);
      return;
    }
    if (printer==null||!serialReady) {
      return;
    }
    //printer.write("M114\n");//現在地確認
    //println("send to pinter: M114");
    if (frameCount%10==0) {
      printer.write("M105\n");//温度確認
      //println("send to pinter: M105");
    }
  }
  void fileSelected(List<File> fs) {
    for (File f : fs) {
      String name=f.getName();
      if (name.indexOf(".gcode")!=-1) {
        gcode=new GCode(f.getAbsolutePath());
        return;
      }
      if (name.indexOf(".stl")!=-1) {
        stls.add(new DrawSTL(f.getAbsolutePath(), true));
        return;
      }
    }
  }
  DropTarget dropTarget;

  void drop_init() {  
    dropTarget = new DropTarget(this, new DropTargetListener() {  
      public void dragEnter(DropTargetDragEvent dtde) {
      }  
      public void dragOver(DropTargetDragEvent dtde) {
      }  
      public void dropActionChanged(DropTargetDragEvent dtde) {
      }  
      public void dragExit(DropTargetEvent dte) {
      }  
      public void drop(DropTargetDropEvent dtde) {  
        dtde.acceptDrop(DnDConstants.ACTION_COPY_OR_MOVE);  
        Transferable trans = dtde.getTransferable();  
        List<File> fileNameList = null;  
        if (trans.isDataFlavorSupported(DataFlavor.javaFileListFlavor)) {  
          try {  
            fileNameList = (List<File>)  
              trans.getTransferData(DataFlavor.javaFileListFlavor);
          } 
          catch (UnsupportedFlavorException ex) {
          } 
          catch (IOException ex) {
          }
        }  
        if (fileNameList == null) return;  
        fileSelected(fileNameList);
      }
    }
    );
  }
  void keyPressed() {
    println("aaaa");
  }
}

