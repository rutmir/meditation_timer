import 'dart:io' show Platform;

import 'package:cronet_http/cronet_http.dart' as cronet;
import 'package:cupertino_http/cupertino_http.dart' as cupertino;
import 'package:http/http.dart' as http;

/// Creates a platform-native HTTP client with HTTP/3 support.
///
/// - Android: Uses Cronet (Chrome's network stack) with QUIC/HTTP/3 enabled.
///   Cronet upgrades to HTTP/3 automatically after receiving an Alt-Svc header.
/// - iOS/macOS: Uses NSURLSession which negotiates HTTP/3 automatically via
///   the Alt-Svc header returned by the server (iOS 15+, macOS 12+).
/// - Other platforms: Falls back to the standard dart:io HTTP client.
http.Client createPlatformClient() {
  if (Platform.isAndroid) {
    final engine = cronet.CronetEngine.build(
      cacheMode: cronet.CacheMode.memory,
      cacheMaxSize: 2 * 1024 * 1024,
      enableHttp2: true,
      enableBrotli: true,
      enableQuic: true,
    );
    return cronet.CronetClient.fromCronetEngine(engine, closeEngine: true);
  }

  if (Platform.isIOS || Platform.isMacOS) {
    final config =
        cupertino.URLSessionConfiguration.defaultSessionConfiguration();
    return cupertino.CupertinoClient.fromSessionConfiguration(config);
  }

  return http.Client();
}
