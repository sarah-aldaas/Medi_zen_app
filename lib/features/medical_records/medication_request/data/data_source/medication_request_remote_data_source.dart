import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/medication_request_end_points.dart';
import '../models/medication_request_model.dart';

abstract class MedicationRequestRemoteDataSource {
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequest({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  });

  Future<Resource<MedicationRequestModel>> getDetailsMedicationRequest({required String medicationRequestId});

  Future<Resource<MedicationRequestModel>> getAllMedicationRequestForCondition({required String conditionId});
}

class MedicationRequestRemoteDataSourceImpl implements MedicationRequestRemoteDataSource {
  final NetworkClient networkClient;

  MedicationRequestRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequest({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(MedicationRequestEndPoints.getAllMedicationRequest(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<MedicationRequestModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<MedicationRequestModel>.fromJson(json, 'medication_requests', (dataJson) => MedicationRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<MedicationRequestModel>>> getAllMedicationRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getAllMedicationRequestForAppointment(appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationRequestModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<MedicationRequestModel>.fromJson(json, 'medication_requests', (dataJson) => MedicationRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<MedicationRequestModel>> getDetailsMedicationRequest({required String medicationRequestId}) async {
    final response = await networkClient.invoke(
      MedicationRequestEndPoints.getDetailsMedicationRequest(medicationRequestId: medicationRequestId),
      RequestType.get,
    );
    return ResponseHandler<MedicationRequestModel>(response).processResponse(fromJson: (json) => MedicationRequestModel.fromJson(json['medication_request']));
  }

  @override
  Future<Resource<MedicationRequestModel>> getAllMedicationRequestForCondition({required String conditionId}) async {
    final response = await networkClient.invoke(MedicationRequestEndPoints.getAllMedicationRequestForCondition(conditionId: conditionId), RequestType.get);
    return ResponseHandler<MedicationRequestModel>(response).processResponse(fromJson: (json) => MedicationRequestModel.fromJson(json['medication_request']));
  }
}
