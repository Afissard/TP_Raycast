// Ray Casting Implementation

final int WORLD_WIDTH = 800;
final int WORLD_HEIGHT = 600;
final int VIEW3D_WIDTH = 600;

int numRays = 140;
float maxDistance = 350;
int numObstacles = 10;
float fov = PI / 2.0;

boolean useCastV2 = false;

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

    // Cast rays (semicircle centered on view direction)
    // for (int i = 0; i < numRays; i++) {
    //     float angleOffset = map(i, 0, numRays - 1, -PI / 2, PI / 2);
    //     PVector rayDir = PVector.fromAngle(player.dir.heading() + angleOffset);
    //     castRay(rayDir, player.pos);
    // }

    // Cast rays and keep hit info for 3D view
    for (int i = 0; i < numRays; i++) {
        float angleOffset = map(i, 0, numRays - 1, -fov / 2.0, fov / 2.0);
        PVector rayDir = PVector.fromAngle(player.dir.heading() + angleOffset);
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

    if (key == 'r' || key == 'R') {
        obstacleManager.clearObstacles();
        obstacleManager.generateRandomObstacles(numObstacles);
    }

    if (key == 'v' || key == 'V') useCastV2 = !useCastV2;
}

void keyReleased() {
    player.handleKeyRelease(keyCode);
}

void draw3DView() {
    float panelX = WORLD_WIDTH;
    float colW = (float) VIEW3D_WIDTH / numRays;

    // background (ceiling + floor)
    noStroke();
    fill(20, 20, 30);
    rect(panelX, 0, VIEW3D_WIDTH, WORLD_HEIGHT / 2.0);
    fill(30, 25, 20);
    rect(panelX, WORLD_HEIGHT / 2.0, VIEW3D_WIDTH, WORLD_HEIGHT / 2.0);

    for (int i = 0; i < numRays; i++) {
        RayHit h = hits[i];
        if (h == null || !h.hit) continue;

        float d = max(1.0, h.distance);
        float wallH = min(WORLD_HEIGHT, (WORLD_HEIGHT * 90.0) / d);
        float y = (WORLD_HEIGHT - wallH) * 0.5;

        float shade = map(d, 0, maxDistance, 255, 30);
        fill(shade, shade * 0.9, shade * 0.7);
        rect(panelX + i * colW, y, colW + 1, wallH);
    }
}
