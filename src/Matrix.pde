class mat {
  final double[] data;
  final int m, n;

  mat(double[][] d) {
    m = d.length;
    if (m != 0)n = d[0].length;
    else n = 0;
    data = new double[m*n];
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        data[i*n+j] = d[i][j];
      }
    }
  }

  mat(double[] d, int m_, int n_) {
    m = m_;
    n = n_;
    if (d.length != m*n)throw new RuntimeException("Improper data!");
    data = new double[m*n];
    for (int i = 0; i < m*n; i++) {
      data[i] = d[i];
    }
  }

  mat(int m_, int n_) {
    m = m_;
    n = n_;
    data = new double[m*n];
  }

  //-1 to +1
  mat randomize() {
    for (int i = 0; i < m*n; i++) {
      data[i] = Math.random()*2 - 1.0;
    }
    return this;
  }

  void writeToDOS(DataOutputStream dos) throws IOException {
    dos.writeChar(2);
    dos.writeBytes("Matrix:");
    dos.writeInt(m);
    dos.writeInt(n);
    for (int i = 0; i < m*n; i++) {
      dos.writeDouble(data[i]);
    }
    dos.writeChar(3);//meh
  }

  @Override
    mat clone() {
    return new mat(data, m, n);
  }

  vec mult(vec v) {
    if (v.n != n)throw new RuntimeException("Improper data!");
    vec o = new vec(m);
    for (int i = 0; i < m; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        sum += data[i*n+j]*v.data[j];
      }
      o.data[i] = sum;
    }
    return o;
  }

  mat mult(double k) {
    mat c = new mat(m, n);
    for (int i = 0; i < m*n; i++) {
      c.data[i] = data[i]*k;
    }
    return c;
  }

  @Override
    String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("mat:[\n");
    for (int i = 0; i < m; i++) {
      sb.append("[ ");
      for (int j = 0; j < n; j++) {
        sb.append(String.format("%.4f", data[i*n+j]));
        if (j != n-1)sb.append(", ");
      }
      sb.append("]\n");
    }
    sb.append("]");
    return sb.toString();
  }
}
