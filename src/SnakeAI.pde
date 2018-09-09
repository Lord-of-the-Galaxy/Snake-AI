import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.FileOutputStream;
import java.io.DataOutputStream;
import java.io.DataInputStream;
import java.util.Arrays;

final int w = 1080, h = 720;

final int ts=12;
final int gw=w/ts, gh=h/ts;

boolean pause = false, restart = false;

Game game;

int gen_in_use = 0;

int hs = 0;
String score_label = "Score : 0";
String hs_label = "High Score : 0";

void settings() {
  size(w+200, h);
}

void setup() {
  game = new Game(new AI());

  /*
  long pt = System.currentTimeMillis();
   float max = 0.0;
   for(int i = 0; i < 100; i++){
   float sc = game.simulate(i);
   if(sc > max)max = sc;
   }
   println("Time taken (100 sims): " + (System.currentTimeMillis() - pt) + "ms");
   println("Max score: " + max);
   game.restart();
   */
  noStroke();
  frameRate(15);
  textSize(20);
  
  initThreading();
  thread("startTraining");
}

void draw() {
  if (pause)return;
  background(0);

  stroke(255);
  line(w, 0, w, h);
  noStroke();

  int s = game.sl - 4;  
  if (game.step() == -1 || restart) {
    if (s > hs) {
      hs = s;
      hs_label = "High Score : " + s;
      if(hs > 15){
        String tmp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        game.ai.save("data/Snake" + tmp + ".ai");
      }
    }
    s = 0;
    restart = false;
    game.restart();
    gen_in_use = cg;
    game.putAI(cb.clone());//once training is started, it will use the best AI trained so far
  }
  game.draw();

  score_label = "Score : " + s;

  fill(255);
  text(score_label, w+20, 50);
  text(hs_label, w+20, 100);
  text("Gen in use: " + gen_in_use, w+20, 200);
  text("Current Gen: " + cg, w+20, 250);
}

void keyPressed() {
  if (key == 'P' || key == 'p') {
    pause = !pause;
  } else if (key == 'M' || key == 'm') {
    game.manual();
  } else if (key == 'A' || key == 'a') {
    game.useAI();
  } else if (key == 'R' || key == 'r') {
    restart = true;
  } else if (key == 'S' || key == 's') {
    String tmp = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    game.ai.save("data/Snake" + tmp + ".ai");
  } else if (!pause && key == CODED) {
    game.keyPressed(keyCode);
  }
}
