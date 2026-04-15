import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart';

import '../../service/device_service.dart';
import '../../service/common/json_request.dart';
import '../../service/common/json_response.dart';
import '../../service/transport_service.dart';
import '../../service/wallet_service.dart';
import '../common/transport_error.dart';
import 'http_client_factory.dart';

class AppTransportService extends TransportService {
  final String _baseApiUrl;
  final String _apiKey;
  final DeviceService _deviceService;
  final WalletService _walletService;

  late final Client _client;
  late final String _appVersion;
  String? _walletPubkey;

  AppTransportService({
    required DeviceService deviceService,
    required WalletService walletService,
    required String baseApiUrl,
    required String apiKey,
  }) : _deviceService = deviceService,
       _walletService = walletService,
       _baseApiUrl = baseApiUrl,
       _apiKey = apiKey,
       _client = createPlatformClient();

  Future<void> init() async {
    _appVersion = await _deviceService.getAppVersion();
    _walletPubkey = await _walletService.getWalletPubkey();
  }

  @override
  void setWalletPubkey(String? pubkey) {
    _walletPubkey = pubkey;
  }

  @override
  Future<T?> get<T extends dynamic>(
    String path, [
    JsonResponse<T>? deserializer,
  ]) async {
    final response = await _sendAuthorized('GET', path);
    return _parseResponse(response, deserializer);
  }

  @override
  Future<T?> post<T extends dynamic>(
    String path,
    JsonRequest request, [
    JsonResponse<T>? deserializer,
  ]) async {
    final response = await _sendAuthorized(
      'POST',
      path,
      null,
      jsonEncode(request.toJson()),
    );
    return _parseResponse<T>(response, deserializer);
  }

  T? _parseResponse<T extends dynamic>(
    Response response,
    JsonResponse<T>? deserializer,
  ) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(response.body) as dynamic;
      // // check if API error
      // final error = json['error'];
      // if (error != null) {
      //   // process error response
      // }
      if (deserializer != null) {
        return deserializer.fromJson(json);
      }

      return null;
    } catch (e) {
      throw TransportError(e);
    }
  }

  Uri _getUri(String path) {
    final rawUri = '$_baseApiUrl$path';
    final uri = Uri.tryParse(rawUri);

    if (uri == null) {
      throw BadDataFormatError('Wrong url "$rawUri"');
    }

    return uri;
  }

  BaseRequest _addHeaders(BaseRequest request) {
    request.headers['x-api-key'] = _apiKey;
    request.headers['x-app-version'] = _appVersion;
    if (_walletPubkey != null) {
      request.headers['x-wallet-pubkey'] = _walletPubkey!;
    }
    return request;
  }

  Future<Response> _sendAuthorizedRequest(
    BaseRequest Function() requestBuilder,
  ) async {
    try {
      return await _sendRequest(_addHeaders(requestBuilder()));
    } catch (_) {
      rethrow;
    }
  }

  BaseRequest _buildRequest(
    String method,
    String path, [
    Map<String, String>? headers,
    Object? body,
  ]) {
    final uri = _getUri(path);
    final request = Request(method, uri);
    // request.headers['Content-Type'] = 'application/json; chartset=UTF-8';

    if (headers != null) request.headers.addAll(headers);
    if (body == null) return request;

    if (body is String) {
      request.body = body;
    } else if (body is List) {
      request.bodyBytes = body.cast<int>();
    } else if (body is Map) {
      request.bodyFields = body.cast<String, String>();
    } else {
      throw BadDataFormatError('Invalid request body', uri);
    }

    return request;
  }

  Future<bool> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  Future<Response> _sendRequest(BaseRequest request) async {
    if (!await _checkInternetConnection()) {
      throw NoConnectionError(
        'Internet connection not detected. Please check your settings and try again.',
      );
    }

    late final Response response;
    try {
      response = await Response.fromStream(
        await _client.send(request),
      ).timeout(const Duration(seconds: 60));
    } catch (e) {
      throw BadRequestError(e, request.url);
    }

    if (response.statusCode == HttpStatus.ok) {
      return response;
    }

    if (response.statusCode == HttpStatus.badRequest) {
      throw BadRequestError(response.body);
    }

    if (response.statusCode == HttpStatus.forbidden) {
      throw ForbiddenError(response.body);
    }

    if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedRequestError();
    }

    if (response.statusCode == HttpStatus.internalServerError) {
      throw InternalServerError(response.body);
    }

    if (response.statusCode == HttpStatus.notFound) {
      throw NotFoundError(response.body);
    }

    if (response.statusCode == HttpStatus.unsupportedMediaType) {
      throw UnsupportedMediaTypeError(response.body);
    }

    if (response.statusCode == 402) {
      double requiredRoex = 0.0;
      double priceUsd = 0.0;
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final error = json['error'] as Map<String, dynamic>?;
        requiredRoex = (error?['required_roex'] as num?)?.toDouble() ?? 0.0;
        priceUsd = (error?['price_usd'] as num?)?.toDouble() ?? 0.0;
      } catch (_) {}
      throw PaymentRequiredError(
        requiredRoex: requiredRoex,
        priceUsd: priceUsd,
        uri: request.url,
      );
    }

    throw TransportError('Unknown error: ${response.body}');
  }

  //  Future<Response> _send(
  //    String method,
  //    String path,
  //    Map<String, String>? headers, [
  //    Object? body,
  //  ]) => _sendRequest(_buildRequest(method, path, headers, body));

  Future<Response> _sendAuthorized(
    String method,
    String path, [
    Map<String, String>? headers,
    Object? body,
  ]) =>
      _sendAuthorizedRequest(() => _buildRequest(method, path, headers, body));
}
