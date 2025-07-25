import 'package:dio/dio.dart';
import 'package:medizen_app/base/services/network/resource.dart';

class ResponseHandler<T> {
  final Response<dynamic> response;

  ResponseHandler(this.response);

  Resource<List<T>> processListResponse({
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    int statusCode = response.statusCode!;
    switch (statusCode) {
      case 200 || 202 || 201 || 203:
        return Success(
          data: List<T>.from(response.data.map((json) => fromJson(json))),
        );
      default:
        return _processResponseError(response, statusCode);
    }
  }

  Resource<T> processResponse({
    required T Function(Map<String, dynamic> json) fromJson,
    returnErrorInSamDataModel = false,
  }) {
    int statusCode = response.statusCode!;
    if (statusCode >= 200 && statusCode < 300) {
      var responseData = response.data['data'];

      if (responseData is! Map<String, dynamic>) {
        responseData = response.data;
      }

      return Success<T>(data: fromJson(responseData));
    } else {
      return _processResponseError<T>(
        response,
        statusCode,
        fromJson: returnErrorInSamDataModel ? fromJson : null,
      );
    }
  }

  _processResponseError<R>(response, int statusCode, {fromJson}) {
    final message = response.data['message'] ?? 'Unknown error occurred';

    String extractErrors(Map<String, dynamic> errors) {
      List<String> errorMessages = [];
      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          errorMessages.add(value);
        }
      });
      return errorMessages.join(" ");
    }

    String errorMessages = "";
    if (response.data.containsKey('errors')) {
      errorMessages = extractErrors(response.data['errors']);
    }

    if (statusCode == 426) {
      return ResponseError<R>(
        data: fromJson != null ? fromJson(response.data) : null,
        code: response.data['status_code'],
        message: "$message $errorMessages",
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      return ResponseError<R>(data: null, message: "$message $errorMessages");
    } else if (statusCode >= 500 && statusCode <= 599) {
      return ResponseError<R>(
        data: null,
        message: "Server error: $message $errorMessages",
      );
    } else {
      return ResponseError<R>(message: "$message $errorMessages");
    }
  }
}
