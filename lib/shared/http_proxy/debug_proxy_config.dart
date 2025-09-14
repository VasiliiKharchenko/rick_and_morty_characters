import 'package:flutter/foundation.dart';

class DebugProxyConfig {
  final bool enabled;
  final String host;
  final int port;

  const DebugProxyConfig({required this.enabled, required this.host, required this.port});

  factory DebugProxyConfig.fromEnv() {
    const enabled = bool.fromEnvironment('PROXY_ENABLED', defaultValue: false);
    const host = String.fromEnvironment('PROXY_HOST');
    const portStr = String.fromEnvironment('PROXY_PORT');
    final port = int.tryParse(portStr) ?? 0;
    if (!enabled || host.isEmpty || port == 0) {
      return const DebugProxyConfig(enabled: false, host: '', port: 0);
    }
    return DebugProxyConfig(enabled: enabled, host: host, port: port);
  }

  factory DebugProxyConfig.disabled() => const DebugProxyConfig(enabled: false, host: '', port: 0);

  DebugProxyConfig copyWith({bool? enabled, String? host, int? port}) {
    return DebugProxyConfig(
      enabled: enabled ?? this.enabled,
      host: host ?? this.host,
      port: port ?? this.port,
    );
  }

  @override
  String toString() => 'DebugProxyConfig(enabled: $enabled, host: $host, port: $port)';

  static bool get isDebugMode => kDebugMode;
}


