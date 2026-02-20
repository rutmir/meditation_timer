import '../platform_method_channel.dart';

class PlatformMethodChannelNotSupported implements PlatformMethodChannel {
  final String channel;

  PlatformMethodChannelNotSupported({required this.channel});

  @override
  bool get isSupported => false;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return Future.error('platform not supportedd');
  }
}

PlatformMethodChannel getPlatformMethodChannel({required String channel}) =>
    PlatformMethodChannelNotSupported(channel: channel);
