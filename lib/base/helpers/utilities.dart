import '../services/network/resource.dart';
import '../services/network/response_handler.dart';

class Utilities {
  static Future<Resource<T>> handleResponse<T>(response, {required T Function(Map<String, dynamic> json) fromJson}) async {
    final responseHandler = ResponseHandler<T>(response);
    return responseHandler.processResponse(fromJson: fromJson);
  }
}
