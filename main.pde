// Ray Casting Implementation

// Define the number of rays to cast
int numRays = 25;
// Define the maximum distance for ray casting
float maxDistance = 200;

// Define the player's position and direction
PVector playerPos;
PVector playerDir;

// Movement
float moveSpeed = 2.5;
boolean upPressed, downPressed, leftPressed, rightPressed;

// Obstacles: rectangles (x, y, w, h)
float[][] rectObstacles = {
  {120, 100, 120, 60},
  {500, 140, 80, 180},
  {300, 420, 180, 50}
};

// Obstacles: circles (x, y, r)
float[][] circleObstacles = {
  {650, 420, 45},
  {220, 320, 35}
};

void setup() {
  size(800, 600);
  // Initialize player's position and direction
  playerPos = new PVector(width / 2, height / 2);
  playerDir = new PVector(1, 0); // Facing right
}

void draw() {
  background(0);

  // Draw obstacles
  drawObstacles();

  // Look at mouse
  playerDir = new PVector(mouseX - playerPos.x, mouseY - playerPos.y);
  if (playerDir.magSq() > 0.0001) {
    playerDir.normalize();
  }

  // Move with arrow keys:
  // Up/Down = forward/backward
  // Left/Right = strafe
  PVector right = new PVector(-playerDir.y, playerDir.x);

  if (upPressed)    playerPos.add(PVector.mult(playerDir, moveSpeed));
  if (downPressed)  playerPos.sub(PVector.mult(playerDir, moveSpeed));
  if (rightPressed) playerPos.add(PVector.mult(right, moveSpeed));
  if (leftPressed)  playerPos.sub(PVector.mult(right, moveSpeed));

  // Keep player inside screen
  playerPos.x = constrain(playerPos.x, 0, width);
  playerPos.y = constrain(playerPos.y, 0, height);

  // Cast rays (semicircle centered on view direction)
  for (int i = 0; i < numRays; i++) {
    float angleOffset = map(i, 0, numRays - 1, -PI / 2, PI / 2);
    PVector rayDir = PVector.fromAngle(playerDir.heading() + angleOffset);
    castRay(rayDir);
  }

  // Draw player
  fill(255, 80, 80);
  noStroke();
  circle(playerPos.x, playerPos.y, 8);

  // Draw facing direction line
  stroke(80, 180, 255);
  line(playerPos.x, playerPos.y, playerPos.x + playerDir.x * 30, playerPos.y + playerDir.y * 30);
}

void drawObstacles() {
  noStroke();
  fill(120, 120, 140);

  // Rectangles
  for (int i = 0; i < rectObstacles.length; i++) {
    float[] r = rectObstacles[i];
    rect(r[0], r[1], r[2], r[3]);
  }

  // Circles
  fill(140, 120, 120);
  for (int i = 0; i < circleObstacles.length; i++) {
    float[] c = circleObstacles[i];
    circle(c[0], c[1], c[2] * 2.0);
  }
}

boolean hitsObstacle(float x, float y) {
  // Check rectangles
  for (int i = 0; i < rectObstacles.length; i++) {
    float[] r = rectObstacles[i];
    if (x >= r[0] && x <= r[0] + r[2] &&
      y >= r[1] && y <= r[1] + r[3]) {
      return true;
    }
  }

  // Check circles
  for (int i = 0; i < circleObstacles.length; i++) {
    float[] c = circleObstacles[i];
    float dx = x - c[0];
    float dy = y - c[1];
    if (dx * dx + dy * dy <= c[2] * c[2]) {
      return true;
    }
  }

  return false;
}

void castRay(PVector rayDir) {
  // Normalize the ray direction
  rayDir.normalize();
  // Initialize the ray's current position
  PVector rayPos = playerPos.copy();

  // Cast the ray until it reaches max distance
  for (float d = 0; d < maxDistance; d += 1) {
    rayPos.add(PVector.mult(rayDir, 1)); // Move the ray in the direction

    // Stop if out of screen
    if (rayPos.x < 0 || rayPos.x > width || rayPos.y < 0 || rayPos.y > height) {
      break;
    }

    // Stop if hits obstacle
    if (hitsObstacle(rayPos.x, rayPos.y)) {
      stroke(255, 220, 100);
      line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);

      // Optional: hit marker
      noStroke();
      fill(255, 180, 80);
      circle(rayPos.x, rayPos.y, 4);
      return;
    }
  }

  // If no hit, draw full ray
  stroke(255, 100);
  line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
}

void keyPressed() {
  if (keyCode == UP)    upPressed = true;
  if (keyCode == DOWN)  downPressed = true;
  if (keyCode == LEFT)  leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
}

void keyReleased() {
  if (keyCode == UP)    upPressed = false;
  if (keyCode == DOWN)  downPressed = false;
  if (keyCode == LEFT)  leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
}