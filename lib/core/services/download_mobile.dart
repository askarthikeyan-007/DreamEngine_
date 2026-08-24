import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

void downloadBytes({required String fileName, required Uint8List bytes}) async {
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      try {
        if (await directory.exists()) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(bytes);
          return; // Successful write to Downloads folder
        }
      } catch (_) {
        // Fall through to external storage if writing to public Downloads folder fails
      }
      
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);
        return;
      }
    }

    // Default fallback (iOS, desktop, or fallback android)
    directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
  } catch (_) {
    // Fail silently
  }
}
