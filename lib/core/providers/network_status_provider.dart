import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_status_provider.g.dart';

enum NetworkStatus {
  online,
  offline,
}

@Riverpod(keepAlive: true)
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;

  @override
  NetworkStatus build() {
    // Limpieza al destruir (aunque al ser keepAlive vivirá toda la app)
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _internetSubscription?.cancel();
    });

    _init();

    // Estado inicial optimista para no bloquear UI innecesariamente al arrancar
    return NetworkStatus.online;
  }

  Future<void> _init() async {
    // 1. Escuchar cambios en el hardware (Wifi/Datos/Nada)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      // Si el hardware dice que no hay nada, es offline seguro.
      if (results.contains(ConnectivityResult.none)) {
        state = NetworkStatus.offline;
      } else {
        // Si hay hardware, verificamos si hay internet real
        _checkInternetAccess();
      }
    });

    // 2. Escuchar cambios de acceso a internet real (Ping / Web Events)
    // InternetConnection maneja la lógica compleja de Pings (Móvil) o navigator.onLine (Web)
    _internetSubscription = InternetConnection().onStatusChange.listen((status) {
      switch (status) {
        case InternetStatus.connected:
          state = NetworkStatus.online;
          break;
        case InternetStatus.disconnected:
          state = NetworkStatus.offline;
          break;
      }
    });
  }

  Future<void> _checkInternetAccess() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    state = hasInternet ? NetworkStatus.online : NetworkStatus.offline;
  }
}