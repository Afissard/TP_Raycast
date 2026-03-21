// Ray Casting Implementation

// Define the number of rays to cast
int numRays = 50;
// Define the maximum distance for ray casting
float maxDistance = 200;
// Define the number of obstacles to generate
int numObstacles = 10;

Player player;
ObstacleManager obstacleManager;

void settings() {
    // Call init in settings to ensure it runs before setup
    // Use P2D renderer for better performance with many rays
    size(800, 600, P2D);
}

void setup() {
    player = new Player(width / 2, height / 2);

    obstacleManager = new ObstacleManager();
    obstacleManager.generateRandomObstacles(numObstacles);
}

void draw() {
    background(0);

    obstacleManager.drawObstacles();

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

void keyPressed() {
    player.handleKeyPress(keyCode);

    if (key == 'r' || key == 'R') {
        obstacleManager.clearObstacles();
        obstacleManager.generateRandomObstacles(numObstacles);
    }
}

void keyReleased() {
    player.handleKeyRelease(keyCode);
}

void castRay(PVector rayDir, PVector playerPos) {
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
        if (obstacleManager.hitsObstacle(rayPos.x, rayPos.y)) {
            stroke(255, 220, 100);
            line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);

            // Hit marker
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

