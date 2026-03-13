import 'dart:io';
import 'dart:convert';

void main() {
  const b64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
  final dir = Directory('assets/images');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('assets/images/placeholder_fallback.png').writeAsBytesSync(base64Decode(b64));
  print('placeholder_fallback.png created');
}
