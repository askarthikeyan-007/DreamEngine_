import 'dart:html' as html;
import 'dart:typed_data';

void downloadBytes({required String fileName, required Uint8List bytes}) {
  final blob = html.Blob([bytes], 'application/vnd.android.package-archive');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
