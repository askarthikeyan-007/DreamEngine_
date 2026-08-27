import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dream_engine_ai/main.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Disable Google Fonts runtime HTTP requests
    GoogleFonts.config.allowRuntimeFetching = false;

    // Build mock asset manifest listing google fonts
    final manifestMap = {
      'google_fonts/ShareTechMono-Regular.ttf': ['google_fonts/ShareTechMono-Regular.ttf'],
      'google_fonts/Orbitron-Bold.ttf': ['google_fonts/Orbitron-Bold.ttf'],
      'google_fonts/Orbitron-SemiBold.ttf': ['google_fonts/Orbitron-SemiBold.ttf'],
      'google_fonts/Orbitron-Regular.ttf': ['google_fonts/Orbitron-Regular.ttf'],
    };
    final manifestData = const StandardMessageCodec().encodeMessage(manifestMap)!;

    // Mock Google Fonts asset loading to prevent "allowRuntimeFetching is false but font not found" crash
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message != null) {
        try {
          final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
          if (key == 'AssetManifest.bin') {
            return manifestData;
          }
          if (key == 'AssetManifest.json') {
            return ByteData.sublistView(utf8.encode(json.encode(manifestMap)));
          }
          if (key.contains('google_fonts/')) {
            // Return 1 dummy byte so it loads successfully without throwing asset missing exception
            return ByteData.sublistView(Uint8List.fromList([0]));
          }
        } catch (_) {}
      }
      return null;
    });

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

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DreamEngineApp());

    // Wait 2 seconds for the logo screen timer to complete.
    await tester.pump(const Duration(seconds: 2));

    // Wait for the video initialization error to be caught and skip to boot sequence.
    await tester.pump();
    await tester.pump();

    // Settle the AnimatedSwitcher transition so the old screen is removed.
    await tester.pump(const Duration(seconds: 1));

    // Verify that the splash screen loads with our app title.
    expect(find.text('DREAMENGINE AI'), findsOneWidget);
  });
}
