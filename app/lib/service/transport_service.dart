import './common/json_request.dart';
import './common/json_response.dart';

abstract class TransportService {
  Future<T?> get<T extends dynamic>(
    String path, [
    JsonResponse<T> deserializer,
  ]);
  Future<T?> post<T extends dynamic>(
    String path,
    JsonRequest request, [
    JsonResponse<T> deserializer,
  ]);
}
