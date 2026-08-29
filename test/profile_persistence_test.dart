import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/services/sqlite_service.dart';
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
          return '.';
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
          'totalRam': 8589934592,
          'availRam': 4294967296,
          'temperature': 32.5,
          'isSimulated': true,
        };
      },
    );
  });

  group('Profile Persistence and Unique Username Tests', () {
    late EngineState state;

    setUp(() {
      state = EngineState();
    });

    test('Should register user and prevent duplicate usernames', () async {
      final reg1 = await state.registerOperator(
        email: 'agent.zero@cyber.io',
        password: 'password123',
        name: 'AGENT_ZERO',
        avatarIndex: 2,
        phone: '1234567890',
      );
      expect(reg1, isTrue);

      // Attempt to register another account with the EXACT same username
      final regDuplicate = await state.registerOperator(
        email: 'other.agent@cyber.io',
        password: 'password123',
        name: 'AGENT_ZERO', // Duplicate username
        avatarIndex: 1,
        phone: '0987654321',
      );
      expect(regDuplicate, isFalse);

      // Also check case-insensitive duplication
      final regDuplicateLower = await state.registerOperator(
        email: 'third.agent@cyber.io',
        password: 'password123',
        name: 'agent_zero', // Lowercase duplicate
        avatarIndex: 1,
        phone: '1122334455',
      );
      expect(regDuplicateLower, isFalse);
    });

    test('Should update profile and persist changes', () async {
      await state.loginOperator(
        emailOrPhone: 'agent.zero@cyber.io',
        password: 'password123',
      );

      final updateSuccess = await state.updateOperatorProfile(
        name: 'CYBER_PHANTOM',
        email: 'agent.zero@cyber.io',
        bio: 'Elite Quantum Neural Hacker',
        role: 'LEAD SYSTEM OVERSEER',
      );
      expect(updateSuccess, isTrue);
      expect(state.operatorName, equals('CYBER_PHANTOM'));
      expect(state.operatorBio, equals('Elite Quantum Neural Hacker'));
      expect(state.operatorRole, equals('LEAD SYSTEM OVERSEER'));

      // Verify active session was persisted
      final activeEmail = await SqliteService.getActiveSession();
      expect(activeEmail, equals('agent.zero@cyber.io'));

      final loaded = await SqliteService.getOperatorByEmail('agent.zero@cyber.io');
      expect(loaded?['name'], equals('CYBER_PHANTOM'));
      expect(loaded?['bio'], equals('Elite Quantum Neural Hacker'));
      expect(loaded?['role'], equals('LEAD SYSTEM OVERSEER'));
    });

    test('Should reject profile update if new username is already taken by another operator', () async {
      // Register a second operator
      final reg2 = await state.registerOperator(
        email: 'neo.matrix@cyber.io',
        password: 'password123',
        name: 'THE_ONE',
        avatarIndex: 0,
        phone: '9988776655',
      );
      expect(reg2, isTrue);

      // Login back as agent.zero
      await state.loginOperator(
        emailOrPhone: 'agent.zero@cyber.io',
        password: 'password123',
      );

      // Try to rename agent.zero to THE_ONE (which belongs to neo.matrix)
      final conflictUpdate = await state.updateOperatorProfile(
        name: 'THE_ONE', // Already taken by neo.matrix
        email: 'agent.zero@cyber.io',
        bio: 'Trying to steal name',
        role: 'IMPOSTOR',
      );
      expect(conflictUpdate, isFalse);
    });
  });
}
