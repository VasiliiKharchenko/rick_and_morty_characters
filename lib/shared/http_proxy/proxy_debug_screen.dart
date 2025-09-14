import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'debug_proxy_config.dart';
import 'dio_proxy.dart';
import 'run_with_proxy.dart';

class ProxyDebugScreen extends StatefulWidget {
  final Dio dio;
  final DebugProxyConfig initialConfig;
  const ProxyDebugScreen({super.key, required this.dio, required this.initialConfig});

  @override
  State<ProxyDebugScreen> createState() => _ProxyDebugScreenState();
}

class _ProxyDebugScreenState extends State<ProxyDebugScreen> {
  late bool _enabled;
  late TextEditingController _host;
  late TextEditingController _port;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialConfig.enabled;
    _host = TextEditingController(text: widget.initialConfig.host);
    _port = TextEditingController(text: widget.initialConfig.port == 0 ? '' : widget.initialConfig.port.toString());
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (!kDebugMode) return;
    final port = int.tryParse(_port.text) ?? 0;
    final cfg = DebugProxyConfig(enabled: _enabled, host: _host.text, port: port);
    // Apply globally for dart:io
    setGlobalProxy(cfg);
    // Apply to Dio
    applyProxyToDio(widget.dio, cfg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proxy settings applied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP Proxy Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Proxy (debug only)'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            TextField(
              controller: _host,
              decoration: const InputDecoration(labelText: 'Host (e.g. 192.168.0.2)'),
            ),
            TextField(
              controller: _port,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Port (e.g. 8888)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _apply, child: const Text('Применить')),
          ],
        ),
      ),
    );
  }
}


