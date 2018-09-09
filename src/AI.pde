final int[] CODES = new int[]{RIGHT, LEFT, UP, DOWN};
final int INPUT = 24, HIDDEN = 16, OUTPUT = 4;
class AI implements Comparable<AI>{
  final mat w1, w2;
  final vec b1, b2;
  double score = 0.0;
  
  //for manual initialization (as if)
  AI(double[][] w1_, double[][] w2_, double[] b1_, double[] b2_){
    w1 = new mat(w1_);
    w2 = new mat(w2_);
    b1 = new vec(b1_);
    b2 = new vec(b2_);
    if(w1.m != HIDDEN)throw new RuntimeException("Incorrect input!");
    if(w1.n != INPUT)throw new RuntimeException("Incorrect input!");
    if(w2.n != HIDDEN)throw new RuntimeException("Incorrect input!");
    if(w2.m != OUTPUT)throw new RuntimeException("Incorrect input!");
    if(b1.n != HIDDEN)throw new RuntimeException("Incorrect input!");
    if(b2.n != OUTPUT)throw new RuntimeException("Incorrect input!");
  }
  
  //for the GA
  AI(mat w1_, mat w2_, vec b1_, vec b2_){
    //don't expect improper data here
    w1 = w1_;
    w2 = w2_;
    b1 = b1_;
    b2 = b2_;
  }
  
  AI(){
    w1 = new mat(HIDDEN, INPUT).randomize();
    w2 = new mat(OUTPUT, HIDDEN).randomize();
    b1 = new vec(HIDDEN).randomize().mult(0.1);
    b2 = new vec(OUTPUT).randomize().mult(0.1);
    //println(w1);
    //println(w2);
  }
  
  @Override
  public int compareTo(AI b){
    return ((Double)b.score).compareTo(score);
  }
  
  @Override
  AI clone(){
    return new AI(w1.clone(), w2.clone(), b1.clone(), b2.clone());
  }
  
  //the name of file
  void save(String fn){
    try{
      FileOutputStream fos = new FileOutputStream(savePath(fn));
      save_internal(new DataOutputStream(fos));
      fos.close();
      println("Saved!");
    }catch(Exception e){
      System.err.println("Error trying to save, save aborted");
      e.printStackTrace();
    }
  }
  
  //the output stream to save to
  void save_internal(DataOutputStream dos) throws IOException{
    dos.writeBytes("SnakeAI:");
    w1.writeToDOS(dos);
    w2.writeToDOS(dos);
    b1.writeToDOS(dos);
    b2.writeToDOS(dos);
    dos.flush();
  }
  
  //0 - right
  //1 - left
  //2 - up
  //3 - down
  int feed(vec in){
    if(in.n != INPUT)throw new RuntimeException("Incorrect input!");
    vec p = sigmoid(w2.mult(sigmoid(w1.mult(in).add(b1))).add(b2));
    //println(p + " - " + p.max_index());
    return p.max_index();
  }
  
  //this is the complicated part
  //partner, mutation rate for weights, mutation rate for bias
  AI reproduce(AI partner, float mw, float mb){
    mat w1_, w2_;
    vec b1_ = mutate(b1, mb), b2_ = mutate(b2, mb);
    int p1 = floor(random(HIDDEN*INPUT)), p2 = floor(random(OUTPUT*HIDDEN));//division point
    double[] w1d = new double[HIDDEN*INPUT], w2d = new double[OUTPUT*HIDDEN];
    for(int i = 0; i < HIDDEN*INPUT; i++){
      if(i <= p1){
        w1d[i] = w1.data[i];
      }else{
        w1d[i] = partner.w1.data[i];
      }
    }
    for(int i = 0; i < OUTPUT*HIDDEN; i++){
      if(i <= p2){
        w2d[i] = w2.data[i];
      }else{
        w2d[i] = partner.w2.data[i];
      }
    }
    w1_ = mutate(new mat(w1d, HIDDEN, INPUT), mw);
    w2_ = mutate(new mat(w2d, OUTPUT, HIDDEN), mw);
    return new AI(w1_, w2_, b1_, b2_);
  }
  
  //partner, mutation rate
  AI reproduce(AI partner, float m){
    return reproduce(partner, m, m*2);
  }
  
  //mutation rate for weights, mutation rate for bias
  AI reproduce(float mw, float mb){
    return new AI(mutate(w1, mw), mutate(w2, mw), mutate(b1, mb), mutate(b2, mb));
  }
  
  //mutation rate
  AI reproduce(float m){
    return new AI(mutate(w1, m), mutate(w2, m), mutate(b1, m*2), mutate(b2, m*2));
  }
}

//input, mutation rate
vec mutate(vec in, float m){
  vec out = new vec(in.n);
  for(int i = 0; i < in.n; i++){
    if(Math.random() < m){
      double d = randomGaussian()/5.0;
      out.data[i] = in.data[i] + d;
    }else{
      out.data[i] = in.data[i];
    }
  }
  return out;
}

//input, mutation rate
mat mutate(mat in, float m){
  mat out = new mat(in.m, in.n);
  for(int i = 0; i < in.m*in.n; i++){
    if(Math.random() < m){
      double d = randomGaussian()/5.0;
      out.data[i] = in.data[i] + d;
    }else{
      out.data[i] = in.data[i];
    }
  }
  return out;
}
