import 'dart:math';

/// Simulated module for ClothSimulation in the GPU Physics System layer.
/// Implements a Verlet mass-spring particle grid system.
class ClothSimulation {
  final double gravityScale = 1.0;
  bool simulationRunning = false;
  
  final List<ClothParticle> particles = [];
  final List<ClothConstraint> constraints = [];

  void startSim() {
    simulationRunning = true;
    _initializeClothGrid();
  }

  void _initializeClothGrid() {
    particles.clear();
    constraints.clear();
    
    // Create a 5x5 grid of particles
    const int cols = 5;
    const int rows = 5;
    
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final double px = x * 10.0;
        final double py = y * 10.0;
        final double pz = 0.0;
        // Top row is pinned (static)
        final bool isPinned = (y == 0);
        
        particles.add(
          ClothParticle(
            id: y * cols + x,
            x: px,
            y: py,
            z: pz,
            isPinned: isPinned,
          ),
        );
      }
    }

    // Create structural constraints between neighboring particles
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final int currentId = y * cols + x;
        
        // Horizontal constraint
        if (x < cols - 1) {
          constraints.add(ClothConstraint(currentId, currentId + 1, 10.0));
        }
        // Vertical constraint
        if (y < rows - 1) {
          constraints.add(ClothConstraint(currentId, currentId + cols, 10.0));
        }
      }
    }
  }

  void stepSimulation(double deltaTime) {
    if (!simulationRunning) return;
    if (particles.isEmpty) _initializeClothGrid();

    // 1. Apply gravity and integrate particles using Verlet Integration
    const double gY = -9.81; // Gravity points down
    for (var p in particles) {
      if (p.isPinned) continue;
      
      final double tempX = p.x;
      final double tempY = p.y;
      final double tempZ = p.z;

      // Verlet Integration: pos = pos + (pos - prevPos) + acc * dt^2
      p.x += (p.x - p.prevX);
      p.y += (p.y - p.prevY) + (gY * gravityScale) * deltaTime * deltaTime;
      p.z += (p.z - p.prevZ);

      p.prevX = tempX;
      p.prevY = tempY;
      p.prevZ = tempZ;
    }

    // 2. Solve Constraints (3 iterations)
    for (int iter = 0; iter < 3; iter++) {
      for (var c in constraints) {
        final p1 = particles[c.p1Id];
        final p2 = particles[c.p2Id];

        final double dx = p2.x - p1.x;
        final double dy = p2.y - p1.y;
        final double dz = p2.z - p1.z;
        
        final double dist = sqrt(dx * dx + dy * dy + dz * dz);
        if (dist == 0) continue;
        
        final double diff = (c.restLength - dist) / dist;
        
        // Offset vector
        final double offsetX = dx * 0.5 * diff;
        final double offsetY = dy * 0.5 * diff;
        final double offsetZ = dz * 0.5 * diff;

        if (!p1.isPinned) {
          p1.x -= offsetX;
          p1.y -= offsetY;
          p1.z -= offsetZ;
        }
        if (!p2.isPinned) {
          p2.x += offsetX;
          p2.y += offsetY;
          p2.z += offsetZ;
        }
      }
    }
  }
}

class ClothParticle {
  final int id;
  double x, y, z;
  double prevX, prevY, prevZ;
  final bool isPinned;

  ClothParticle({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    required this.isPinned,
  })  : prevX = x,
        prevY = y,
        prevZ = z;
}

class ClothConstraint {
  final int p1Id;
  final int p2Id;
  final double restLength;

  ClothConstraint(this.p1Id, this.p2Id, this.restLength);
}
