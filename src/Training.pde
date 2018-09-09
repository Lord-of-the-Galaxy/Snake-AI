//This is where the training happens
//Goes on in other thread(s)

final int POP = 1500;//population

//THREADING
//It automatically uses more threads if there's at least 6 threads available to the JVM at initilization
//As there wouldn't be any significant gains with less then 6 threads
boolean HEAVY_MULTITHREADING;//should it make more than the default 2 threads?
int NUM_THREADS;//threads other than scheduling and drawing threads
Thread[] threads;//array of threads
int batchSize;//how many AIs each thread simulates

void initThreading() {
  int n = Runtime.getRuntime().availableProcessors();//number of available threads
  HEAVY_MULTITHREADING = (n >= 6);//only use if 6 threads available
  NUM_THREADS = n - 2;//Leave a couple threads for other jobs
  batchSize = ceil(POP/(float)NUM_THREADS); 
  threads = new Thread[NUM_THREADS];
}

volatile int cg = 0;//current generation
volatile AI cb;//current best

volatile Game[] sims = new Game[POP];
volatile AI[] ais = new AI[POP];

//TRAIN IT!!!!
//Genetic Algorithm
void startTraining() throws InterruptedException {
  println("Started training");
  println("Population - " + POP);
  if (HEAVY_MULTITHREADING)println("Using " + NUM_THREADS + " threads for training");

  //initialization
  for (int i = 0; i < POP; i++) {
    AI a = new AI();
    ais[i] = a;
    sims[i] = new Game(a);
  }

  long pt = System.currentTimeMillis();
  while (true) {

    float TR = 0.1;
    int n = floor(cg/100.0);
    TR -= n*0.015;
    if (TR < 0.1) TR = 0.1;
    //simulate them all
    float[] cumulativeScores = new float[POP];
    float sum = 0;
    double max = 0.0;//just for keeping track
    int max_i = -1;
    if (!HEAVY_MULTITHREADING) {
      for (int i = 0; i < POP; i++) {
        sims[i].putAI(ais[i]);
        sum += sims[i].simulate(cg);//scores are stored by the AIs, we need only cumulative ones
        cumulativeScores[i] = sum;
        if (sims[i].ai.score > max) {
          max = sims[i].ai.score;
          max_i = i;
        }
      }
    } else {
      for (int i = 0; i < NUM_THREADS; i++) {
        threads[i] = new Thread(new Trainer(i*batchSize, min((i+1)*batchSize, POP)));
        threads[i].start();
      }
      for (int i = 0; i < NUM_THREADS; i++) threads[i].join();

      for (int i = 0; i < POP; i++) {
        sum += sims[i].ai.score;
        cumulativeScores[i] = sum;
        if (sims[i].ai.score > max) {
          max = sims[i].ai.score;
          max_i = i;
        }
      }
    }

    for (int i = 0; i < POP; i++) {
      cumulativeScores[i] /= sum;//normalize fitness
    }

    //reproduction
    AI[] nais = new AI[POP];//new ais
    //90% - sexual
    int i;
    for (i = 0; i < POP*0.9; i++) {
      double r = Math.random();
      int j = 0;
      while (j < POP) {
        if (r < cumulativeScores[j])break;
        j++;
      }
      r = Math.random();
      int k = 0;
      while (k < POP) {
        if (r < cumulativeScores[k])break;
        k++;
      }
      //(j, k) - two parents
      nais[i] = ais[j].reproduce(ais[k], TR);
    }
    //10% - asexual
    for (; i < POP; i++) {
      double r = Math.random();
      int j = 0;
      while (j < POP) {
        if (r < cumulativeScores[j])break;
        j++;
      }
      nais[i] = ais[j].reproduce(TR*0.75);
    }
    ais = nais;

    cb = ais[max_i];//current best

    println("Max score: " + max);
    println("Average score: " + (sum/POP));

    println("Time taken (generation " + (cg+1) + "): " + (System.currentTimeMillis() - pt) + "ms");
    pt = System.currentTimeMillis();
    cg++;
  }
}

class Trainer implements Runnable {

  final int start, stop;

  Trainer(int start_, int stop_) {
    start = start_;
    stop = stop_;
  }

  void run() {
    for (int i = start; i < stop; i++) {
      sims[i].putAI(ais[i]);
      sims[i].simulate(cg);
    }
  }
}
