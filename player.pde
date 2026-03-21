// player class

class Player {
    PVector pos;
    PVector dir;
    float moveSpeed = 2.5;
    
    // Input tracking
    boolean upPressed, downPressed, leftPressed, rightPressed;

    Player(float x, float y) {
        pos = new PVector(x, y);
        dir = new PVector(1, 0); // Facing right
    }

    void update() {
        // Look at mouse
        dir = new PVector(mouseX - pos.x, mouseY - pos.y);
        if (dir.magSq() > 0.0001) {
            dir.normalize();
        }

        // Move with arrow keys
        PVector right = new PVector(-dir.y, dir.x);

        if (upPressed)      pos.add(PVector.mult(dir, moveSpeed));
        if (downPressed)    pos.sub(PVector.mult(dir, moveSpeed));
        if (rightPressed)   pos.add(PVector.mult(right, moveSpeed));
        if (leftPressed)    pos.sub(PVector.mult(right, moveSpeed));

        // Keep player inside screen
        // pos.x = constrain(pos.x, 0, width);
        // pos.y = constrain(pos.y, 0, height);
        pos.x = constrain(pos.x, 0, WORLD_WIDTH);
        pos.y = constrain(pos.y, 0, WORLD_HEIGHT);
    }

    void display() {
        // Draw player
        fill(255, 80, 80);
        noStroke();
        circle(pos.x, pos.y, 8);

        // Draw facing direction line
        stroke(80, 180, 255);
        line(pos.x, pos.y, pos.x + dir.x * 30, pos.y + dir.y * 30);
    }

    void handleKeyPress(int keyCode) {
        if (keyCode == UP)      upPressed = true;
        if (keyCode == DOWN)    downPressed = true;
        if (keyCode == LEFT)    leftPressed = true;
        if (keyCode == RIGHT)   rightPressed = true;
    }

    void handleKeyRelease(int keyCode) {
        if (keyCode == UP)      upPressed = false;
        if (keyCode == DOWN)    downPressed = false;
        if (keyCode == LEFT)    leftPressed = false;
        if (keyCode == RIGHT)   rightPressed = false;
    }
}