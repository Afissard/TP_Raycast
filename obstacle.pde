abstract class Obstacle {
    abstract void draw();
    abstract boolean hit(float x, float y);
}

class RectObstacle extends Obstacle {
    float x, y, w, h;

    RectObstacle(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    @Override
    void draw() {
        fill(120, 120, 140);
        noStroke();
        rect(x, y, w, h);
    }

    @Override
    boolean hit(float px, float py) {
        return px >= x && px <= x + w && py >= y && py <= y + h;
    }
}

class CircleObstacle extends Obstacle {
    float x, y, r;

    CircleObstacle(float x, float y, float r) {
        this.x = x;
        this.y = y;
        this.r = r;
    }

    @Override
    void draw() {
        fill(140, 120, 120);
        noStroke();
        circle(x, y, r * 2.0);
    }

    @Override
    boolean hit(float px, float py) {
        float dx = px - x;
        float dy = py - y;
        return dx * dx + dy * dy <= r * r;
    }
}

class triangleObstacle extends Obstacle {
    PVector v1, v2, v3;

    triangleObstacle(PVector v1, PVector v2, PVector v3) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }

    @Override
    void draw() {
        fill(120, 140, 120);
        noStroke();
        triangle(v1.x, v1.y, v2.x, v2.y, v3.x, v3.y);
    }

    @Override
    boolean hit(float px, float py) {
        // Barycentric technique
        float A = area(v1, v2, v3);
        float A1 = area(new PVector(px, py), v2, v3);
        float A2 = area(v1, new PVector(px, py), v3);
        float A3 = area(v1, v2, new PVector(px, py));
        return abs(A - (A1 + A2 + A3)) < 0.01;
    }

    float area(PVector a, PVector b, PVector c) {
        return abs((a.x*(b.y-c.y) + b.x*(c.y-a.y) + c.x*(a.y-b.y)) / 2.0);
    }
}