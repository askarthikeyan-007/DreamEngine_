import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class HardwareService {
  static const MethodChannel _channel = MethodChannel('dream_engine_ai/hardware');
  static final Random _random = Random();

  // Simulated metrics tracking for fallback (Windows/macOS/Linux/Web)
  static double _simulatedTemp = 31.2;
  static double _simulatedAvailRamPct = 0.55;

  /// Simulates a system cooling and RAM purging action for non-mobile testing
  static void simulateCooldownAndPurge() {
    _simulatedTemp = 28.5;
    _simulatedAvailRamPct = 0.75; // 75% available RAM (25% usage)
  }

  /// Retrieves real-time hardware telemetry stats
  static Future<Map<String, dynamic>> getHardwareStats() async {
    // Only invoke MethodChannel on mobile platforms (Android/iOS)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final Map<dynamic, dynamic>? result =
            await _channel.invokeMethod('getHardwareStats');
        if (result != null) {
          return Map<String, dynamic>.from(result);
        }
      } on PlatformException catch (e) {
        debugPrint("PlatformException calling getHardwareStats: $e");
      }
    }

    // Fallback: Generate realistic fluctuating telemetry for desktop/web testing
    // Temperature: slowly fluctuates between 28C and 44C
    _simulatedTemp += (_random.nextDouble() - 0.5) * 0.8;
    _simulatedTemp = _simulatedTemp.clamp(28.0, 44.0);

    // Memory: fluctuates between 40% and 85% free
    _simulatedAvailRamPct += (_random.nextDouble() - 0.5) * 0.04;
    _simulatedAvailRamPct = _simulatedAvailRamPct.clamp(0.15, 0.85);

    final double totalRamBytes = 8.0 * 1024 * 1024 * 1024; // Assume 8GB total RAM
    final double availRamBytes = totalRamBytes * _simulatedAvailRamPct;

    return {
      "totalRam": totalRamBytes.toInt(),
      "availRam": availRamBytes.toInt(),
      "temperature": double.parse(_simulatedTemp.toStringAsFixed(1)),
      "isSimulated": true,
    };
  }
}
