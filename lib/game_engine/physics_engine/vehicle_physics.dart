/// Simulated module for VehiclePhysics in the GPU Physics System layer.
class VehiclePhysics {
  double gravityScale = 1.0;
  double torque = 150.0;
  double suspensionStiffness = 50.0;

  double speed = 0.0; // km/h
  double rpm = 800.0;
  double tilt = 0.0;  // chassis tilt in radians
  double distance = 0.0; // total meters traveled
  bool simulationRunning = false;

  void startSim() {
    simulationRunning = true;
  }

  void stopSim() {
    simulationRunning = false;
    speed = 0.0;
    rpm = 800.0;
    tilt = 0.0;
    distance = 0.0;
  }

  void stepSimulation(double deltaTime, bool isAccelerating, bool isBraking) {
    if (!simulationRunning) return;

    if (isAccelerating) {
      rpm = (rpm + 2500.0 * deltaTime).clamp(800.0, 8000.0);
      // Speed increases based on torque and gravity scaling
      double acc = (torque * 0.12) / gravityScale;
      speed = (speed + acc * deltaTime).clamp(0.0, 220.0);
      
      // Chassis tilts backward due to rear weight transfer under acceleration, stabilized by suspension
      double targetTilt = 0.25 * (torque / 150.0) / (suspensionStiffness / 50.0);
      tilt = (tilt + (targetTilt - tilt) * 4.0 * deltaTime).clamp(-0.4, 0.4);
    } else if (isBraking) {
      rpm = (rpm - 3500.0 * deltaTime).clamp(800.0, 8000.0);
      // Braking speed reduction
      speed = (speed - 90.0 * deltaTime).clamp(0.0, 220.0);
      
      // Chassis tilts forward under braking
      double targetTilt = -0.3 / (suspensionStiffness / 50.0);
      tilt = (tilt + (targetTilt - tilt) * 5.0 * deltaTime).clamp(-0.4, 0.4);
    } else {
      // Natural rolling friction deceleration
      rpm = (rpm - 1200.0 * deltaTime).clamp(800.0, 8000.0);
      speed = (speed - 12.0 * deltaTime).clamp(0.0, 220.0);
      
      // Suspension relaxes tilt back to neutral
      tilt = tilt * (1.0 - 3.0 * deltaTime);
    }

    // Distance accumulated in meters: km/h converted to m/s
    distance += (speed * 0.277778) * deltaTime;
  }
}
