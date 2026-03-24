// Ray Casting Implementation

final int WORLD_WIDTH = 800;
final int WORLD_HEIGHT = 600;
final int VIEW3D_WIDTH = 900;

// Raycasting parameters
int numRays = 140;           // Number of rays to cast per frame
float maxDistance = 350;     // Maximum ray travel distance
int numObstacles = 10;       // Number of random obstacles to generate
float fov = PI / 2.0;        // Field of view angle (90 degrees)

// Ray casting algorithm selector
boolean useCastV2 = false;   // false = V1 (pixel march), true = V2 (coarse+refine)

Player player;
ObstacleManager obstacleManager;
RayHit[] hits;

void settings() {
    size(WORLD_WIDTH + VIEW3D_WIDTH, WORLD_HEIGHT, P2D);
}

void setup() {
    player = new Player(width / 2, height / 2);

    obstacleManager = new ObstacleManager();
    obstacleManager.generateRandomObstacles(numObstacles);

    hits = new RayHit[numRays];
}

void draw() {
    background(0);

    obstacleManager.drawObstacles();

    // Update and display player
    player.update();
    player.display();

    // Cast rays and store hit information for 3D view
    for (int i = 0; i < numRays; i++) {
        // Calculate angle offset from center of FOV
        float angleOffset = map(i, 0, numRays - 1, -fov / 2.0, fov / 2.0);
        // Generate ray direction based on player facing + angle offset
        PVector rayDir = PVector.fromAngle(player.dir.heading() + angleOffset);
        // Cast ray and store result (distance corrected for fisheye effect)
        hits[i] = castRay(rayDir, player.pos, angleOffset);
    }
    
    draw3DView();

    // Divider + HUD
    stroke(255, 80);
    line(WORLD_WIDTH, 0, WORLD_WIDTH, WORLD_HEIGHT);

    fill(255);
    text("Ray mode: " + (useCastV2 ? "V2 (coarse+refine)" : "V1 (pixel march)") + "\n[V] switch raycast function\n[R] regenerate", 10, 18);
}

void keyPressed() {
    player.handleKeyPress(keyCode);

    // R key: regenerate random obstacles
    if (key == 'r' || key == 'R') {
        obstacleManager.clearObstacles();
        obstacleManager.generateRandomObstacles(numObstacles);
    }

    // V key: toggle between raycast V1 and V2
    if (key == 'v' || key == 'V') useCastV2 = !useCastV2;
}

void keyReleased() {
    player.handleKeyRelease(keyCode);
}

/**
 * Renders the pseudo-3D first-person view from ray hit data.
 * Uses vertical wall slices based on ray distances to create depth perception.
 */
void draw3DView() {
    float panelX = WORLD_WIDTH;
    float colW = (float) VIEW3D_WIDTH / numRays;  // Width of each wall slice column

    // Draw ceiling (upper half) and floor (lower half) background
    noStroke();
    fill(20, 20, 30);  // Ceiling color (dark blue)
    rect(panelX, 0, VIEW3D_WIDTH, WORLD_HEIGHT / 2.0);
    fill(30, 25, 20);  // Floor color (dark brown)
    rect(panelX, WORLD_HEIGHT / 2.0, VIEW3D_WIDTH, WORLD_HEIGHT / 2.0);

    // Draw wall slices for each ray
    for (int i = 0; i < numRays; i++) {
        RayHit h = hits[i];
        // Skip if no hit or ray didn't intersect
        if (h == null || !h.hit) continue;

        // Calculate perpendicular distance to prevent fisheye distortion
        float d = max(1.0, h.distance);
        // Calculate wall height based on distance (closer = taller)
        float wallH = min(WORLD_HEIGHT, (WORLD_HEIGHT * 90.0) / d);
        // Center wall vertically on screen
        float y = (WORLD_HEIGHT - wallH) * 0.5;

        // Calculate brightness based on distance (fog effect)
        float shade = map(d, 0, maxDistance, 255, 30);
        // Draw wall slice with distance-based shading
        fill(shade, shade * 0.9, shade * 0.7);
        rect(panelX + i * colW, y, colW + 1, wallH);
    }
}