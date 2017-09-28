File searchLatestSTL(String path){
  File[] files = new File(path).listFiles();
  File tmp=null;
  for(File f:files){
    String name=f.getName();
    if(name.indexOf(".stl")!=-1||name.indexOf(".STL")!=-1){
    println(name);
      tmp=f;
    }
  }
  return tmp;
}
