class RayHit {
    boolean hit;
    float distance;
    PVector point;

    RayHit(boolean hit, float distance, PVector point) {
        this.hit = hit;
        this.distance = distance;
        this.point = point;
    }
}

RayHit castRay(PVector rayDir, PVector playerPos, float angleOffset) {
    return useCastV2
        ? castRayV2(rayDir, playerPos, angleOffset)
        : castRayV1(rayDir, playerPos, angleOffset);
}

// V1: original pixel-by-pixel ray march
/*
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
*/
RayHit castRayV1(PVector rayDir, PVector playerPos, float angleOffset) {
    PVector dir = rayDir.copy();
    dir.normalize();
    PVector rayPos = playerPos.copy();

    for (float d = 0; d < maxDistance; d += 1) {
        rayPos.add(dir);

        if (rayPos.x < 0 || rayPos.x > WORLD_WIDTH || rayPos.y < 0 || rayPos.y > WORLD_HEIGHT) break;

        if (obstacleManager.hitsObstacle(rayPos.x, rayPos.y)) {
            stroke(255, 220, 100);
            line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
            noStroke();
            fill(255, 180, 80);
            circle(rayPos.x, rayPos.y, 4);
            float dist = PVector.dist(playerPos, rayPos) * cos(angleOffset);
            return new RayHit(true, max(0.0001, dist), rayPos.copy());
        }
    }

    stroke(255, 100);
    line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
    return new RayHit(false, maxDistance, rayPos.copy());
}

// V2: coarse step + 1px refinement (ray marching with early exit for better performance)
/*
* How it works:
* 1. Move the ray in larger steps (e.g., 4 pixels) until it hits an obstacle or reaches max distance.
* 2. If a hit is detected, move back to the last position before the hit and then step forward in 1 pixel increments to find the exact hit point.
* Advantages:
* - Much faster on average, especially for long rays with few hits, since it reduces the number of collision checks significantly.
* - Still maintains good accuracy due to the refinement step.
*/
RayHit castRayV2(PVector rayDir, PVector playerPos, float angleOffset) {
    PVector dir = rayDir.copy();
    dir.normalize();
    float coarseStep = 4.0;
    PVector step = PVector.mult(dir, coarseStep);
    PVector rayPos = playerPos.copy();

    for (float d = 0; d < maxDistance; d += coarseStep) {
        rayPos.add(step);

        if (rayPos.x < 0 || rayPos.x > WORLD_WIDTH || rayPos.y < 0 || rayPos.y > WORLD_HEIGHT) break;

        if (obstacleManager.hitsObstacle(rayPos.x, rayPos.y)) {
            // Refine last segment at 1px precision
            PVector refinePos = PVector.sub(rayPos, step);
            for (float r = 0; r < coarseStep; r += 1) {
                refinePos.add(dir);
                if (refinePos.x < 0 || refinePos.x > WORLD_WIDTH || refinePos.y < 0 || refinePos.y > WORLD_HEIGHT) break;
                if (obstacleManager.hitsObstacle(refinePos.x, refinePos.y)) {
                    stroke(120, 220, 255);
                    line(playerPos.x, playerPos.y, refinePos.x, refinePos.y);
                    noStroke();
                    fill(120, 220, 255);
                    circle(refinePos.x, refinePos.y, 4);
                    float dist = PVector.dist(playerPos, refinePos) * cos(angleOffset);
                    return new RayHit(true, max(0.0001, dist), refinePos.copy());
                }
            }
            // Fallback if refine loop missed exact edge
            float dist = PVector.dist(playerPos, rayPos) * cos(angleOffset);
            return new RayHit(true, max(0.0001, dist), rayPos.copy());
        }
    }
    
    stroke(120, 220, 255, 120);
    line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
    return new RayHit(false, maxDistance, rayPos.copy());
}
