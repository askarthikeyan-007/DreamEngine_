import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mock Path Provider Method Channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.'; // Mock directory path
        }
        return null;
      },
    );

    // Mock Hardware Service Method Channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dream_engine_ai/hardware'),
      (MethodCall methodCall) async {
        return {
          'totalRam': 8589934592, // 8 GB
          'availRam': 4294967296, // 4 GB
          'temperature': 32.5,
          'isSimulated': true,
        };
      },
    );
  });

  group('Rusty Tokens State Tests', () {
    late EngineState state;

    setUp(() {
      state = EngineState();
    });

    test('Initial token balance should be 1500 RT', () {
      expect(state.rustyTokens, equals(1500.0));
    });

    test('Recharging tokens should increment the balance', () {
      state.rechargeRustyTokens(1000.0);
      expect(state.rustyTokens, equals(2500.0));
      expect(state.stockMarketLogs.last, contains("RECHARGED 1000 RT VIA RAZERPAY"));
    });

    test('Purchasing a free asset should succeed and not deduct tokens', () {
      final gratisAssetTitle = "Cyberpunk Voxel V2 Pack";
      final success = state.purchaseAsset(gratisAssetTitle);
      expect(success, isTrue);
      expect(state.rustyTokens, equals(1500.0)); // No change
    });

    test('Purchasing an asset with sufficient balance should succeed and deduct tokens', () {
      final assetTitle = "SynthWave Sound Pack v2"; // Costs 1200 RT
      final success = state.purchaseAsset(assetTitle);
      expect(success, isTrue);
      expect(state.rustyTokens, equals(300.0)); // 1500 - 1200
      expect(state.stockMarketLogs.last, contains("ACQUIRED ASSET"));
    });

    test('Purchasing an asset with insufficient balance should fail and not deduct tokens', () {
      final assetTitle = "Netrunner NPC Mesh Model"; // Costs 2500 RT
      final success = state.purchaseAsset(assetTitle);
      expect(success, isFalse);
      expect(state.rustyTokens, equals(1500.0)); // Unchanged
    });
  });
}
