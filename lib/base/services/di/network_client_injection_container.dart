
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../configuration/app_config.dart';
import '../network/network_client.dart';
import 'injection_container_common.dart';

class NetworkClientDependencyInjection {
  static Future<void> initDi() async {
    final Dio dio = Dio();
    BaseOptions baseOptions = BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 5),
        headers: {
          "Access-Control-Allow-Origin": '*',
          "Access-Control-Allow-Credentials": true,
          "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
          "Access-Control-Allow-Methods": "*"
        },
        baseUrl: AppConfig.baseUrl,
        contentType: Headers.jsonContentType,
        maxRedirects: 2);

    dio.options = baseOptions;
    dio.options.contentType = Headers.formUrlEncodedContentType;

    dio.interceptors.clear();

    dio.interceptors.add(PrettyDioLogger(
        requestBody: true, error: true, request: true, compact: true, maxWidth: 90, requestHeader: true, responseBody: true, responseHeader: false));


    dio.interceptors.add(InterceptorsWrapper(onError: (DioException error, handler) {
      return handler.next(error);
    }, onRequest: (RequestOptions requestOptions, handler) async {
      var accessToken = "";
      if (accessToken != "") {
        var authHeader = {'Authorization': 'Bearer $accessToken'};
        requestOptions.headers.addAll(authHeader);
      }
      return handler.next(requestOptions);
    }, onResponse: (response, handler) async {
      return handler.next(response);
    }));

    serviceLocator.registerLazySingleton(() => dio);

    serviceLocator.registerLazySingleton(() => NetworkClient(dio: serviceLocator(), logger: serviceLocator(), storageService: serviceLocator()));
  }
}
