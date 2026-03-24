class ObstacleManager {
    ArrayList<Obstacle> obstacles;

    ObstacleManager() {
        obstacles = new ArrayList<Obstacle>();
    }

    void addObstacle(Obstacle o) {
        obstacles.add(o);
    }

    void drawObstacles() {
        for (Obstacle o : obstacles) {
            o.draw();
        }
    }

    boolean hitsObstacle(float x, float y) {
        for (Obstacle o : obstacles) {
            if (o.hit(x, y)) return true;
        }
        return false;
    }

    void clearObstacles() {
        obstacles.clear();
    }

    void generateRandomRectangles(int count) {
        for (int i = 0; i < count; i++) {
            float w = random(40, 140);
            float h = random(40, 140);
            float x = random(0, WORLD_WIDTH - w);
            float y = random(0, WORLD_HEIGHT - h);

            obstacles.add(new RectObstacle(x, y, w, h));
        }
    }

    void generateRandomCircles(int count) {
        for (int i = 0; i < count; i++) {
            float r = random(20, 60);
            float x = random(r, WORLD_WIDTH - r);
            float y = random(r, WORLD_HEIGHT - r);
            
            obstacles.add(new CircleObstacle(x, y, r));
        }
    }

    void generateRandomTriangles(int count) {
        for (int i = 0; i < count; i++) {
            PVector v1 = new PVector(random(WORLD_WIDTH), random(WORLD_HEIGHT));
            PVector v2 = PVector.add(v1, new PVector(random(-80, 80), random(-80, 80)));
            PVector v3 = PVector.add(v1, new PVector(random(-80, 80), random(-80, 80)));
            
            obstacles.add(new TriangleObstacle(v1, v2, v3));
        }
    }

    void generateRandomObstacles(int count) {
        obstacles.clear();
        for (int i = 0; i < count; i++) {
            int type = (int)random(3);
            if (type == 0) {
                generateRandomRectangles(1);
            } else if (type == 1) {
                generateRandomCircles(1);
            } else {
                generateRandomTriangles(1);
            }
        }
    }
}