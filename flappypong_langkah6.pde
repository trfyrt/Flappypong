// Variabel Global
// 0: Initial screen
// 1: Game screen
// 2: Game over screen

PImage bg;
int score = 0; //skor pemain
int maxHealth = 100; //nyawa maksimum
float health = 100; //nyawa awal
float healthDecrease = 1; //tingkat penurunan nyawa
int healthBarWidth = 60; //lebar bar nyawa
int racketBounceRate = 20; //tingkat pantulan raket
int ballX, ballY; //koordinat bola
int ballSize = 20; //ukuran bola
int ballColor = color(235, 198, 52); //warna bola
int gameScreen = 0;
int wallSpeed = 5; //kecepatan dinding
int wallInterval = 1000; //interval dinding
float lastAddTime = 0; //waktu terakhir dinding ditambahkan
int minGapHeight = 200; //tinggi celah minimum
int maxGapHeight = 300; //tinggi celah maksimum
int wallWidth = 80; //lebar dinding
float gravity = 1; //gravitasi
float ballSpeedVert = 0; //kecepatan bola di sumbu vertikal
float airFriction = 0.01; //gesekan udara
float friction = 0.1; //gesekan permukaan
float racketWidth = 100; //lebar raket
float racketHeight = 10; //tinggi raket
float ballSpeedHorizon = 10; //kecepatan bola di sumbu horizontal
color racketColor = color(64, 69, 86); //warna raket
color wallColors = color(64, 69, 86); //warna dinding
// Daftar array ini menyimpan deata celah antara dinding.
// [gapWallX, gapWallY, gapWallHeight]
ArrayList<int[]> walls = new ArrayList<int[]>();

void setup() {
  size(500, 500);
  ballX= width/4; //mengatur posisi bola di sumbu x
  ballY= height/5;  //mengatur posisi bola di sumbu y
  bg = loadImage("background.png");
}

void draw() {
  if (gameScreen == 0) {
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    gameOverScreen();
  }
}

void initScreen() {
  background(0);
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("Click to Start", width/2, height/2);
}

void gameScreen() {
  image(bg, 0, 0, width, height);  // menampilkan gambar sebagai background

  drawBall();
  drawRacket();
  applyGravity();
  keepInScreen();
  watchRacketBounce();
  applyHorizontalSpeed();
  wallAdder();
  wallHandler();
  drawHealthBar();
  printScore();
}

void gameOverScreen() {
  background(0);
  fill(255);
  textAlign(CENTER);
  textSize(30);
  text("Game Over", width/2, height/2);
  textSize(20);
  text("Click to Restart", width/2, height/2 + 30);
  text("Score: " + score, width/2, height/2 + 60);
}

// INPUTS
public void mousePressed() {
  // Jika pemain mengklik layar awal maka game dimulai
  if (gameScreen == 0) {
    startGame();
  }
  if (gameScreen == 2) {
    restart();
  }
}

void restart() {
  score = 0;
  health = maxHealth;
  ballX= width/4; //mengatur posisi bola di sumbu x
  ballY= height/5;  //mengatur posisi bola di sumbu y
  lastAddTime = 0;
  walls.clear();
  gameScreen = 0;
}
void startGame() {
  gameScreen = 1;
}

void drawBall() {
  fill(ballColor); //memberikan warna pada bola
  ellipse(ballX, ballY, ballSize, ballSize); //membuat bola
}

void applyGravity() {
  ballSpeedVert += gravity; //menambahkan gravitasi ke kecepatan vertikal bola
  ballY += ballSpeedVert; //mengubah posisi bola berdasarkan kecepatan vertikal
  ballSpeedVert -=(ballSpeedVert * airFriction); //mengurangi kecepatan vertikal bola berdasarkan gesekan udara
}

void makeBounceBottom(int surface) {
  ballY = surface - (ballSize/2); //mengatur posisi bola di atas permukaan
  ballSpeedVert *= -1; //mengubah arah kecepatan vertikal bola dan mengurangi kecepatannya
  ballSpeedVert -=(ballSpeedVert * friction); //mengurangi kecepatan vertikal bola berdasarkan gesekan permukaan
}

void makeBounceTop(int surface) {
  ballY = surface + (ballSize/2); //mengatur posisi bola di atas permukaan
  ballSpeedVert *= -1; //mengubah arah kecepatan vertikal bola dan mengurangi kecepatannya
  ballSpeedVert -=(ballSpeedVert * friction); //mengurangi kecepatan vertikal bola berdasarkan gesekan permukaan
}

// menjaga bola tetap berada di layar
void keepInScreen() {
  // jika bola menabrak bagian bawah layar
  if (ballY + (ballSize/2) > height) {
    makeBounceBottom(height);
  }
  // jika bola menabrak bagian atas layar
  if (ballY - (ballSize/2) < 0) {
    makeBounceTop(0);
  }
  if (ballX - (ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  if (ballX + (ballSize/2) > width) {
    makeBounceRight(width);
  }
}

void drawRacket() {
  fill(racketColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight);
}

void watchRacketBounce() {
  float overhead = mouseY - pmouseY;
  if ((ballX+(ballSize/2) > mouseX-(racketWidth/2)) && (ballX-(ballSize/2) < mouseX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, mouseY) <= (ballSize/2)+abs(overhead)) {
      makeBounceBottom(mouseY);
      ballSpeedHorizon = (ballX-mouseX)/5;
      // racket moving up
      if (overhead<0) {
        ballY+=overhead;
        ballSpeedVert+=overhead;
      }
    }
  }
}

void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -=(ballSpeedHorizon * airFriction);
}

void makeBounceLeft(int surface) {
  ballX = surface + (ballSize/2); //mengatur posisi bola di atas permukaan
  ballSpeedHorizon *= -1; //mengubah arah kecepatan horizontal bola dan mengurangi kecepatannya
  ballSpeedHorizon -=(ballSpeedHorizon * friction); //mengurangi kecepatan horizontal bola berdasarkan gesekan permukaan
}

void makeBounceRight(int surface) {
  ballX = surface - (ballSize/2); //mengatur posisi bola di atas permukaan
  ballSpeedHorizon *= -1; //mengubah arah kecepatan horizontal bola dan mengurangi kecepatannya
  ballSpeedHorizon -=(ballSpeedHorizon * friction); //mengurangi kecepatan horizontal bola berdasarkan gesekan permukaan
}


void wallAdder() {
  if (millis() - lastAddTime > wallInterval) {
    int randHeight = int(random(minGapHeight, maxGapHeight));
    int randY = round(random(0, height - randHeight));

    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight}
    int[] randWall = {width, randY, wallWidth, randHeight, 0};
    walls.add(randWall);
    lastAddTime = millis();
  }
}

void wallHandler() {
  for (int i = 0; i<walls.size(); i++) {
    wallRemover(i);
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
  }
}

void wallDrawer(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  // draw actual walls
  rectMode(CORNER);
  fill(wallColors);
  rect(gapWallX, 0, gapWallWidth, gapWallY); //top wall
  rect(gapWallX, gapWallY + gapWallHeight, gapWallWidth, height - (gapWallY + gapWallHeight)); //bottom wall
}

void wallMover(int index) {
  int[] wall = walls.get(index);
  wall[0] -= wallSpeed;
}

void wallRemover(int index) {
  int[] wall = walls.get(index);
  if (wall[0] + wall[2] < 0) {
    walls.remove(index);
  }
}

void watchWallCollision(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int wallScored = wall[4];
  int wallTopX = gapWallX;
  int wallTopY = 0;
  int wallTopWidth = gapWallWidth;
  int wallTopHeight = gapWallY;
  int wallBottomX = gapWallX;
  int wallBottomY = gapWallY + gapWallHeight;
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height - (gapWallY + gapWallHeight);
  if ((ballX+(ballSize/2) > wallTopX) && (ballX-(ballSize/2) < wallTopX + wallTopWidth) && (ballY+(ballSize/2) > wallTopY) && (ballY-(ballSize/2) < wallTopY + wallTopHeight)) {
    decreaseHealth();
  }
  if ((ballX+(ballSize/2) > wallBottomX) && (ballX-(ballSize/2) < wallBottomX + wallBottomWidth) && (ballY+(ballSize/2) > wallBottomY) && (ballY-(ballSize/2) < wallBottomY + wallBottomHeight)) {
    decreaseHealth();
  }
  if (ballX > gapWallX + (gapWallWidth/2) && (wallScored == 0)) {
    wall[4] = 1; //mark as scored
    score();
  }
}

void drawHealthBar() {
  noStroke();
  fill(236, 240, 241);
  rectMode(CORNER);
  rect(ballX-(healthBarWidth/2), ballY - 30, healthBarWidth, 5);
  if (health > 60) {
    fill(46, 204, 113);
  } else if (health > 30) {
    fill(241, 196, 15);
  } else {
    fill(231, 76, 60);
  }
  rectMode(CORNER);
  rect(ballX-(healthBarWidth/2), ballY - 30, healthBarWidth * (health / maxHealth), 5);
}

void decreaseHealth() {
  health -= healthDecrease;
  if (health <= 0) {
    gameOver();
  }
}

void score() {
  score++;
}

void printScore() {
  fill(255);
  textAlign(LEFT, TOP);
  textSize(30);
  text(score, 10, 10);
}


void gameOver() {
  gameScreen = 2;
}
