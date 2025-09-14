import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'debug_proxy_config.dart';

class _ProxyHttpOverrides extends HttpOverrides {
  final DebugProxyConfig config;
  _ProxyHttpOverrides(this.config);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    if (config.enabled && config.host.isNotEmpty && config.port > 0) {
      client.findProxy = (uri) => 'PROXY ${config.host}:${config.port}';
      if (kDebugMode && Platform.isAndroid) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      }
    }
    return client;
  }
}

Future<void> runWithProxy(Future<void> Function() body, DebugProxyConfig cfg) async {
  await body();
}

void setGlobalProxy(DebugProxyConfig cfg) {
  if (cfg.enabled && cfg.host.isNotEmpty && cfg.port > 0) {
    HttpOverrides.global = _ProxyHttpOverrides(cfg);
  } else {
    HttpOverrides.global = null;
  }
}


