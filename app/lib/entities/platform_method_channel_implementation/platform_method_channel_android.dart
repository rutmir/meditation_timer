import 'package:flutter/services.dart';
import '../platform_method_channel.dart';

class PlatformMethodChannelAndroid implements PlatformMethodChannel {
  final String channel;
  late MethodChannel platformMethodChannel;

  PlatformMethodChannelAndroid({required this.channel}) {
    platformMethodChannel = MethodChannel(channel);
  }

  @override
  bool get isSupported => true;

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return platformMethodChannel.invokeMethod(method, arguments);
  }
}

PlatformMethodChannel getPlatformMethodChannel({required String channel}) =>
    PlatformMethodChannelAndroid(channel: channel);
