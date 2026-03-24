/**
 * RayHit: Data structure to store the result of a ray cast operation.
 */
class RayHit {
    boolean hit;        // Whether the ray intersected an obstacle
    float distance;     // Perpendicular distance to hit point (corrected for fisheye)
    PVector point;      // World coordinates of the hit point

    RayHit(boolean hit, float distance, PVector point) {
        this.hit = hit;
        this.distance = distance;
        this.point = point;
    }
}

/**
 * Dispatcher function that selects between V1 and V2 ray casting algorithms.
 * @param rayDir Direction vector of the ray
 * @param playerPos Player's current position
 * @param angleOffset Angle offset from center FOV (used for fisheye correction)
 * @return RayHit object containing hit status, distance, and point
 */
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

/**
 * V1: Pixel-by-pixel ray marching (1px steps).
 * Slower but accurate; tests every pixel along the ray path.
 * @param rayDir Normalized ray direction
 * @param playerPos Ray origin (player position)
 * @param angleOffset Angle from FOV center (for fisheye correction via cosine)
 * @return RayHit with hit status and corrected distance
 */
RayHit castRayV1(PVector rayDir, PVector playerPos, float angleOffset) {
    // Copy and normalize direction vector
    PVector dir = rayDir.copy();
    dir.normalize();
    // Start ray at player position
    PVector rayPos = playerPos.copy();

    // Step through world in 1px increments
    for (float d = 0; d < maxDistance; d += 1) {
        rayPos.add(dir);

        // Exit if ray leaves world bounds
        if (rayPos.x < 0 || rayPos.x > WORLD_WIDTH || rayPos.y < 0 || rayPos.y > WORLD_HEIGHT) break;

        // Check for obstacle collision
        if (obstacleManager.hitsObstacle(rayPos.x, rayPos.y)) {
            // Draw ray line from player to hit point (orange)
            stroke(255, 220, 100);
            line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
            // Draw hit marker circle
            noStroke();
            fill(255, 180, 80);
            circle(rayPos.x, rayPos.y, 4);
            // Calculate perpendicular distance (multiply by cos to remove fisheye distortion)
            float dist = PVector.dist(playerPos, rayPos) * cos(angleOffset);
            return new RayHit(true, max(0.0001, dist), rayPos.copy());
        }
    }

    // No hit: draw faint ray to max distance
    stroke(255, 100);
    line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
    return new RayHit(false, maxDistance, rayPos.copy());
}

/**
 * V2: Coarse-step + 1px refinement ray marching (optimized).
 * 
 * Algorithm:
 * 1. March in large 4px steps until collision detected or max distance reached
 * 2. Upon collision, step back to last safe position
 * 3. Refine forward 1px at a time to find exact hit point
 * 
 * Advantages:
 * - Much faster on long rays with few obstacles (fewer collision checks)
 * - Maintains accuracy through refinement phase
 * - Better for real-time performance
 */
RayHit castRayV2(PVector rayDir, PVector playerPos, float angleOffset) {
    // Copy and normalize direction vector
    PVector dir = rayDir.copy();
    dir.normalize();
    
    // Coarse step size for initial ray march
    float coarseStep = 4.0;
    // Pre-calculate step vector to avoid repeated multiplication
    PVector step = PVector.mult(dir, coarseStep);
    // Start ray at player position
    PVector rayPos = playerPos.copy();

    // Phase 1: Coarse stepping (4px increments)
    for (float d = 0; d < maxDistance; d += coarseStep) {
        rayPos.add(step);

        // Exit if ray leaves world bounds
        if (rayPos.x < 0 || rayPos.x > WORLD_WIDTH || rayPos.y < 0 || rayPos.y > WORLD_HEIGHT) break;

        // Check for obstacle collision
        if (obstacleManager.hitsObstacle(rayPos.x, rayPos.y)) {
            // Phase 2: Refinement - back up to last known safe position
            PVector refinePos = PVector.sub(rayPos, step);
            
            // Step forward 1px at a time to find exact hit point
            for (float r = 0; r < coarseStep; r += 1) {
                refinePos.add(dir);
                
                // Exit if refinement leaves world bounds
                if (refinePos.x < 0 || refinePos.x > WORLD_WIDTH || refinePos.y < 0 || refinePos.y > WORLD_HEIGHT) break;
                
                // Check refined position for collision
                if (obstacleManager.hitsObstacle(refinePos.x, refinePos.y)) {
                    // Draw ray line from player to refined hit point (cyan)
                    stroke(120, 220, 255);
                    line(playerPos.x, playerPos.y, refinePos.x, refinePos.y);
                    // Draw hit marker circle
                    noStroke();
                    fill(120, 220, 255);
                    circle(refinePos.x, refinePos.y, 4);
                    // Calculate perpendicular distance with fisheye correction
                    float dist = PVector.dist(playerPos, refinePos) * cos(angleOffset);
                    return new RayHit(true, max(0.0001, dist), refinePos.copy());
                }
            }
            
            // Fallback: if refinement loop didn't find exact hit, return coarse position
            float dist = PVector.dist(playerPos, rayPos) * cos(angleOffset);
            return new RayHit(true, max(0.0001, dist), rayPos.copy());
        }
    }
    
    // No hit: draw faint ray to max distance
    stroke(120, 220, 255, 120);
    line(playerPos.x, playerPos.y, rayPos.x, rayPos.y);
    return new RayHit(false, maxDistance, rayPos.copy());
}
