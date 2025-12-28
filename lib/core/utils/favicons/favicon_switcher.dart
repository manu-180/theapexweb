// Exporta condicionalmente el archivo web si estamos en web, sino el stub.
export 'favicon_stub.dart'
    if (dart.library.html) 'favicon_web.dart';