import 'platform_method_channel_implementation/platform_method_channel_not_supported.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'platform_method_channel_implementation/platform_method_channel_android.dart';

abstract class PlatformMethodChannel {
  bool get isSupported;
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]);

  /// factory constructor to return the correct implementation.
  factory PlatformMethodChannel({required String channel}) =>
      getPlatformMethodChannel(channel: channel);
}
