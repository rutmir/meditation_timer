import 'json_response.dart';

class BaseResponse<T> {
  T? data;
  String? error;

  BaseResponse(this.data, this.error);

  BaseResponse.fromJson(
    Map<String, dynamic> json,
    JsonResponse<T>? deserializer,
  ) {
    error = json['error'];

    if (deserializer != null) {}
  }
}
