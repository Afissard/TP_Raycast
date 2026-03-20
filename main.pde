// Ray Casting Implementation

// Define the number of rays to cast
int numRays = 25;
// Define the maximum distance for ray casting
float maxDistance = 200;

Player player;

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
  player = new Player(width / 2, height / 2);
}

void draw() {
  background(0);

  // Draw obstacles
  drawObstacles();

  // Update and display player
  player.update();
  player.display();

  // Cast rays (semicircle centered on view direction)
  for (int i = 0; i < numRays; i++) {
    float angleOffset = map(i, 0, numRays - 1, -PI / 2, PI / 2);
    PVector rayDir = PVector.fromAngle(player.dir.heading() + angleOffset);
    castRay(rayDir, player.pos);
  }
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

void castRay(PVector rayDir,  PVector playerPos) {
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
  player.handleKeyPress(keyCode);
}

void keyReleased() {
  player.handleKeyRelease(keyCode);
}