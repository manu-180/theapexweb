// Archivo: lib/core/providers/inspector_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspector_provider.g.dart';

// Este provider guarda el estado: true (prendido) o false (apagado)
@Riverpod(keepAlive: true)
class InspectorMode extends _$InspectorMode {
  @override
  bool build() => false; // Empieza apagado por defecto

  void toggle() => state = !state;
}