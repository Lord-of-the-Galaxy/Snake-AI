class vec2 {
  int x, y;
  vec2(int x_, int y_) {
    x = x_;
    y = y_;
  }
}

vec2[] dirs = new vec2[]{new vec2(-1, -1), new vec2(-1, 0), new vec2(-1, 1), new vec2(0, -1), new vec2(0, 1), new vec2(1, -1), new vec2(1, 0), new vec2(1, 1)};

class Game {
  boolean manual;
  AI ai;

  int vx=1, vy=0;
  int px=gw/2, py=gh/2;


  ArrayList<vec2> trail = new ArrayList<vec2>();
  int sl = 4;//length

  int ax, ay;

  Game() {
    manual = true;
    ai = null;
  }

  Game(AI ai_) {
    manual = false;
    ai = ai_;
  }

  Game putAI(AI ai_) {
    ai = ai_;
    return this;
  }

  Game useAI() {
    if (ai == null) {
      System.err.println("No AI specified so far, reverting to manual mode");
    } else {
      manual = false;
    }
    return this;
  }

  Game manual() {
    manual = true;
    return this;
  }

  //returns score gained by AI
  //simulates twice to reduce the role of luck - you don't get lucky twice ;)
  //score = turns/150 + (length-4) for first 150 generations
  //score = length-4 for next 350 generations
  //score = (length-4)*(1+1/turns) afterwards
  float t1 = 150;
  float t2 = 500;
  float tr = 150;
  double simulate(int gen) {
    int turn = 0;
    int last_food = 0;
    double s1, s2;
    while (true) {
      turn++;
      int r = step();
      if (r == -1) {
        break;
      } else if (r == 1) {
        last_food = turn;
      }
      if (turn - last_food > 100)break;
    }
    if (gen <= t1) {
      s1 = turn/tr + (sl-4);
    } else if (gen <= t2) {
      s1 = (sl-4);
    } else {
      s1 = (sl-4)*(1 + 1.0f/turn);
    }
    restart();//reset everything
    turn = 0;
    last_food = 0;
    while (true) {
      turn++;
      int r = step();
      if (r == -1) {
        break;
      } else if (r == 1) {
        last_food = turn;
      }
      if (turn - last_food > 100)break;
    }
    if (gen <= t1) {
      s2 = turn/tr + (sl-4);
    } else if (gen <= t2) {
      s2 = (sl-4);
    } else {
      s2 = (sl-4)*(1 + 1.0f/turn);
    }
    restart();//again
    ai.score = (s1 + s2)/2.0;
    return ai.score;
  }

  void draw() {//draw state to framebuffer
    //draw apple
    fill(255, 0, 0);
    rect(ax*ts, ay*ts, ts, ts);

    //draw snake
    fill(0, 255, 0);   
    for (int i=0; i<trail.size(); i++) {
      rect(trail.get(i).x*ts, trail.get(i).y*ts, ts-1, ts-1);
    }
  }

  //-1 = dead
  // 0 = nothing
  //+1 = ate apple
  int step() {
    if (!manual)arrowPressed(CODES[ai.feed(calculateInputs())]);

    px+=vx;
    py+=vy;

    if (px >= gw || py >= gh || px < 0 || py < 0) {//WALL
      return -1;
    }

    trail.add(new vec2(px, py));
    if (trail.size()>sl)trail.remove(0);

    int a = 0;
    if (px==ax && py==ay) {
      sl++;
      apple();
      a = 1;
    }

    for (int i=0; i<trail.size()-1; i++) {
      if (px==trail.get(i).x && py==trail.get(i).y) {
        //run into yourself
        return -1;
      }
    }
    return a;
  }

  void apple() {
    ax = floor(random(gw));
    ay = floor(random(gh));
    for (int i=0; i<trail.size(); i++) {
      if (ax==trail.get(i).x && ay==trail.get(i).y) {
        apple();//if it's on the snake, relocate it
        break;
      }
    }
  }

  vec calculateInputs() {
    vec o = new vec(INPUT);
    //Currently, 24 inputs
    for (int i = 0; i < 8; i++) {
      double[] n = calculateInputsInDirection(dirs[i]);
      o.data[i*3] = n[0];
      o.data[i*3+1] = n[1];
      o.data[i*3+2] = n[2];
    }
    return o;
  }

  double[] calculateInputsInDirection(vec2 dir) {
    double[] o = new double[3];
    //first - reciprocal of distance to food
    //second - reciprocal of distance to wall
    //third - reciprocal of distance to snake body

    //current position - (px, py)
    int cx = px, cy = py;
    int d = 0;
    boolean f = false, w = false, sb = false;//food, wall, snake body
    while (true) {
      if (!f) {//FOOD
        if (ax == cx && ay == cy) {
          o[0] = 10.0d/sqrt(d);
          f = true;
        }
      }
      if (!w) {//WALL
        if (cx >= gw || cy >= gh || cx < 0 || cy < 0) {
          o[1] = 2.0d/d;
          w = true;
        }
      }
      if (!sb) {//SNAKE BODY
        for (int i=0; i<trail.size()-1; i++) {
          if (cx==trail.get(i).x && cy==trail.get(i).y) {
            //run into yourself
            sb = true;
            o[2] = 1.0d/d;
            break;
          }
        }
      }  
      if (f && w && sb)break;
      d++;
      cx += dir.x;
      cy += dir.y;
      if (d == 100) {
        if (!f) o[0] = -0.1d;
        if (!w) o[1] = -0.05d;
        if (!sb) o[2] = -0.02d;
        break;
      }
    }

    return o;
  }

  void keyPressed(int code) {
    if (manual)arrowPressed(code);
  }

  void restart() {
    sl = 4;
    trail.clear();
    px=gw/2;
    py=gh/2;
    double r = Math.random();
    if(r < 0.25){
      vx=1;
      vy=0;
    }else if(r < 0.5){
      vx=-1;
      vy=0;
    }else if(r < 0.75){
      vx=0;
      vy=1;
    }else{
      vx=0;
      vy=-1;
    } 
    apple();
  }

  //to allow simulation of key presses
  void arrowPressed(int code) {
    switch(code) {
    case DOWN:
      if (vy!=-1) {
        vx=0;
        vy=1;
      }
      break;

    case UP:
      if (vy!=1) {
        vx=0;
        vy=-1;
      }
      break;

    case LEFT:
      if (vx!=1) {
        vx=-1;
        vy=0;
      }
      break;

    case RIGHT:
      if (vx!=-1) {
        vx=1;
        vy=0;
      }
      break;
    }
  }
}
