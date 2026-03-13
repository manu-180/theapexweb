import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  final String _sessionId = _generateSessionId();

  static String _generateSessionId() {
    final rng = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(999999)}';
  }

  String get _deviceType {
    if (kIsWeb) return 'web';
    return 'native';
  }

  void trackEvent(String name, [Map<String, dynamic>? params]) {
    final enrichedParams = <String, dynamic>{
      'session_id': _sessionId,
      'event_id': '${name}_${DateTime.now().millisecondsSinceEpoch}',
      'device_type': _deviceType,
      'timestamp': DateTime.now().toIso8601String(),
      ...?params,
    };

    if (kDebugMode) {
      debugPrint('[Analytics] $name: $enrichedParams');
    }

    _pushToDataLayer(name, enrichedParams);
  }

  void _pushToDataLayer(String name, Map<String, dynamic> params) {
    // GA4 dataLayer push via JS interop (web only).
    // In production, this would call window.dataLayer.push({event: name, ...params})
    // via dart:js_interop or dart:html. Kept as a stub for now since GA4
    // property needs to be configured first.
    if (kDebugMode) {
      debugPrint('[Analytics/DataLayer] Would push: $name');
    }
  }

  void trackPageView(String pagePath) {
    trackEvent('page_view', {'page_path': pagePath});
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return AnalyticsService();
}
