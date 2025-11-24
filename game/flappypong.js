// Variabel Global
let bg;
let score = 0;
let maxHealth = 100;
let health = 100;
let healthDecrease = 1;
let healthBarWidth = 60;
let racketBounceRate = 20;

let ballX, ballY;
let ballSize = 20;
let ballColor;

let gameScreen = 0;

let wallSpeed = 5;
let wallInterval = 1000;
let lastAddTime = 0;

let minGapHeight = 200;
let maxGapHeight = 300;
let wallWidth = 80;

let gravity = 1;
let ballSpeedVert = 0;
let airFriction = 0.01;
let friction = 0.1;

let racketWidth = 100;
let racketHeight = 10;

let ballSpeedHorizon = 10;

let racketColor;
let wallColors;

// Array of {x, y, w, h, scored}
let walls = [];

function preload() {
  bg = loadImage("background.png");
}

function setup() {
  createCanvas(500, 500);

  ballX = width / 4;
  ballY = height / 5;

  ballColor = color(235, 198, 52);
  racketColor = color(64, 69, 86);
  wallColors = color(64, 69, 86);
}

function draw() {
  if (gameScreen === 0) initScreen();
  else if (gameScreen === 1) gameScreenFunc();
  else if (gameScreen === 2) gameOverScreen();
}

function initScreen() {
  background(0);
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("Click to Start", width / 2, height / 2);
}

function gameScreenFunc() {
  image(bg, 0, 0, width, height);

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

function gameOverScreen() {
  background(0);
  fill(255);
  textAlign(CENTER);
  textSize(30);
  text("Game Over", width / 2, height / 2);
  textSize(20);
  text("Click to Restart", width / 2, height / 2 + 30);
  text("Score: " + score, width / 2, height / 2 + 60);
}

// INPUTS
function mousePressed() {
  if (gameScreen === 0) startGame();
  if (gameScreen === 2) restart();
}

function restart() {
  score = 0;
  health = maxHealth;
  ballX = width / 4;
  ballY = height / 5;
  lastAddTime = 0;
  walls = [];
  gameScreen = 0;
}

function startGame() {
  gameScreen = 1;
}

function drawBall() {
  fill(ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

function applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= ballSpeedVert * airFriction;
}

function makeBounceBottom(surface) {
  ballY = surface - ballSize / 2;
  ballSpeedVert *= -1;
  ballSpeedVert -= ballSpeedVert * friction;
}

function makeBounceTop(surface) {
  ballY = surface + ballSize / 2;
  ballSpeedVert *= -1;
  ballSpeedVert -= ballSpeedVert * friction;
}

function keepInScreen() {
  if (ballY + ballSize / 2 > height) makeBounceBottom(height);
  if (ballY - ballSize / 2 < 0) makeBounceTop(0);

  if (ballX - ballSize / 2 < 0) makeBounceLeft(0);
  if (ballX + ballSize / 2 > width) makeBounceRight(width);
}

function drawRacket() {
  fill(racketColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight);
}

function watchRacketBounce() {
  let overhead = mouseY - pmouseY;

  if (
    ballX + ballSize / 2 > mouseX - racketWidth / 2 &&
    ballX - ballSize / 2 < mouseX + racketWidth / 2
  ) {
    if (dist(ballX, ballY, ballX, mouseY) <= ballSize / 2 + abs(overhead)) {
      makeBounceBottom(mouseY);
      ballSpeedHorizon = (ballX - mouseX) / 5;

      if (overhead < 0) {
        ballY += overhead;
        ballSpeedVert += overhead;
      }
    }
  }
}

function applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= ballSpeedHorizon * airFriction;
}

function makeBounceLeft(surface) {
  ballX = surface + ballSize / 2;
  ballSpeedHorizon *= -1;
  ballSpeedHorizon -= ballSpeedHorizon * friction;
}

function makeBounceRight(surface) {
  ballX = surface - ballSize / 2;
  ballSpeedHorizon *= -1;
  ballSpeedHorizon -= ballSpeedHorizon * friction;
}

function wallAdder() {
  if (millis() - lastAddTime > wallInterval) {
    let randHeight = int(random(minGapHeight, maxGapHeight));
    let randY = round(random(0, height - randHeight));

    walls.push({
      x: width,
      y: randY,
      w: wallWidth,
      h: randHeight,
      scored: 0
    });

    lastAddTime = millis();
  }
}

function wallHandler() {
  for (let i = walls.length - 1; i >= 0; i--) {
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
    if (walls[i].x + walls[i].w < 0) walls.splice(i, 1);
  }
}

function wallDrawer(i) {
  let w = walls[i];

  fill(wallColors);
  rect(w.x, 0, w.w, w.y);
  rect(w.x, w.y + w.h, w.w, height - (w.y + w.h));
}

function wallMover(i) {
  walls[i].x -= wallSpeed;
}

function watchWallCollision(i) {
  let w = walls[i];

  let topX = w.x;
  let topY = 0;
  let topW = w.w;
  let topH = w.y;

  let bottomX = w.x;
  let bottomY = w.y + w.h;
  let bottomW = w.w;
  let bottomH = height - bottomY;

  if (
    ballX + ballSize / 2 > topX &&
    ballX - ballSize / 2 < topX + topW &&
    ballY + ballSize / 2 > topY &&
    ballY - ballSize / 2 < topY + topH
  ) {
    decreaseHealth();
  }

  if (
    ballX + ballSize / 2 > bottomX &&
    ballX - ballSize / 2 < bottomX + bottomW &&
    ballY + ballSize / 2 > bottomY &&
    ballY - ballSize / 2 < bottomY + bottomH
  ) {
    decreaseHealth();
  }

  if (ballX > w.x + w.w / 2 && w.scored === 0) {
    w.scored = 1;
    score++;
  }
}

function drawHealthBar() {
  noStroke();
  fill(236, 240, 241);
  rect(ballX - healthBarWidth / 2, ballY - 30, healthBarWidth, 5);

  if (health > 60) fill(46, 204, 113);
  else if (health > 30) fill(241, 196, 15);
  else fill(231, 76, 60);

  rect(
    ballX - healthBarWidth / 2,
    ballY - 30,
    healthBarWidth * (health / maxHealth),
    5
  );
}

function decreaseHealth() {
  health -= healthDecrease;
  if (health <= 0) gameOver();
}

function printScore() {
  fill(255);
  textAlign(LEFT, TOP);
  textSize(30);
  text(score, 10, 10);
}

function gameOver() {
  gameScreen = 2;
}
