class vec{
  final double[] data;
  final int n;
  
  vec(double[] d){
    n = d.length;
    data = new double[n];
    for(int i = 0; i < n; i++){
      data[i] = d[i];
    }
  }
  
  vec(int n_){
    n = n_;
    data = new double[n];
  }
  
  void writeToDOS(DataOutputStream dos) throws IOException {
    dos.writeChar(2);
    dos.writeBytes("Vector:");
    dos.writeInt(n);
    for (int i = 0; i < n; i++) {
      dos.writeDouble(data[i]);
    }
    dos.writeChar(3);//meh
  }
  
  @Override
  vec clone(){
    return new vec(data);
  }
  
  //-1 to +1
  vec randomize(){
    for(int i = 0; i < n; i++){
      data[i] = Math.random()*2 - 1.0;
    }
    return this;
  }
  
  vec add(vec b){
    if(n != b.n)throw new RuntimeException("Vectors are of different dimensions");
    vec c = new vec(n);
    for(int i = 0; i < n; i++){
      c.data[i] = data[i] + b.data[i];
    }
    return c;
  }
  
  vec sub(vec b){
    if(n != b.n)throw new RuntimeException("Vectors are of different dimensions");
    vec c = new vec(n);
    for(int i = 0; i < n; i++){
      c.data[i] = data[i] - b.data[i];
    }
    return c;
  }
  
  double dot(vec b){
    if(n != b.n)throw new RuntimeException("Vectors are of different dimensions");
    double sum = 0;
    for(int i = 0; i < n; i++){
      sum += data[i]*b.data[i];
    }
    return sum;
  }
  
  vec mult(double k){
    vec c = new vec(n);
    for(int i = 0; i < n; i++){
      c.data[i] = data[i]*k;
    }
    return c;
  }
  
  int max_index(){
    if(n == 0)throw new RuntimeException("Vector is Zero dimensional");
    double max = data[0];
    int m = 0;
    for(int i = 1; i < n; i++){
      if(data[i] > max){
        m = i;
        max = data[i];
      }
    }
    return m;
  }
  
  @Override
  String toString(){
    StringBuilder sb = new StringBuilder();
    sb.append("vec:[ ");
    for(int i = 0; i < n; i++){
      sb.append(String.format("%.4f", data[i]));
      if(i != n-1)sb.append(", ");
    }
    sb.append("]");
    return sb.toString();
  }
}

vec sigmoid(vec in){
  vec out = new vec(in.n);
  for(int i = 0; i < in.n; i++){
    out.data[i] = sigmoid(in.data[i]);
  }
  return out;
}

double sigmoid(double in){
  return 1/(1 + Math.exp(-in));
}
