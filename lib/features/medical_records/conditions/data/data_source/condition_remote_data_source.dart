import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/conditions_end_points.dart';
import '../models/conditions_model.dart';

abstract class ConditionRemoteDataSource {
  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditions({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PaginatedResponse<ConditionsModel>>>
  getAllConditionForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  });

  Future<Resource<ConditionsModel>> getDetailsConditions({
    required String conditionId,
  });
}

class ConditionRemoteDataSourceImpl implements ConditionRemoteDataSource {
  final NetworkClient networkClient;

  ConditionRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ConditionsModel>>> getAllConditions({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      ConditionsEndPoints.getAllConditions(),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ConditionsModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<ConditionsModel>.fromJson(
            json,
            'conditions',
            (dataJson) => ConditionsModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<PaginatedResponse<ConditionsModel>>>
  getAllConditionForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      ConditionsEndPoints.getAllConditionsForAppointment(
        appointmentId: appointmentId,
      ),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ConditionsModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<ConditionsModel>.fromJson(
            json,
            'conditions',
            (dataJson) => ConditionsModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<ConditionsModel>> getDetailsConditions({
    required String conditionId,
  }) async {
    final response = await networkClient.invoke(
      ConditionsEndPoints.getDetailsCondition(conditionId: conditionId),
      RequestType.get,
    );
    return ResponseHandler<ConditionsModel>(response).processResponse(
      fromJson: (json) => ConditionsModel.fromJson(json['condition']),
    );
  }
}
