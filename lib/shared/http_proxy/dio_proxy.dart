import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'debug_proxy_config.dart';

void applyProxyToDio(Dio dio, DebugProxyConfig cfg) {
  if (!cfg.enabled) {
    dio.httpClientAdapter = IOHttpClientAdapter();
    return;
  }

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (uri) => 'PROXY ${cfg.host}:${cfg.port}';
      if (kDebugMode && Platform.isAndroid) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      }
      return client;
    },
  );
}


