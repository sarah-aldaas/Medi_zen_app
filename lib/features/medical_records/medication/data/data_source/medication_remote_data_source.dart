import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/medication_end_points.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedication({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String medicationRequestId,
    required String conditionId,
  });

  Future<Resource<MedicationModel>> getDetailsMedication({required String medicationId});

  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForMedicationRequest({required String medicationRequestId, required String conditionId,    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,});
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final NetworkClient networkClient;

  MedicationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedication({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(MedicationEndPoints.getAllMedication(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<MedicationModel>.fromJson(json, 'medications', (dataJson) => MedicationModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String medicationRequestId,
    required String conditionId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      MedicationEndPoints.getAllMedicationForAppointment(appointmentId: appointmentId, medicationRequestId: medicationRequestId, conditionId: conditionId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<MedicationModel>.fromJson(json, 'medications', (dataJson) => MedicationModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<MedicationModel>> getDetailsMedication({required String medicationId}) async {
    final response = await networkClient.invoke(MedicationEndPoints.getDetailsMedication(medicationId: medicationId), RequestType.get);
    return ResponseHandler<MedicationModel>(response).processResponse(fromJson: (json) => MedicationModel.fromJson(json['medication']));
  }

  @override
  Future<Resource<PaginatedResponse<MedicationModel>>> getAllMedicationForMedicationRequest({required String medicationRequestId, required String conditionId  ,  Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(MedicationEndPoints.getAllMedicationForMedicationRequest(medicationRequestId: medicationRequestId, conditionId: conditionId), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<MedicationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<MedicationModel>.fromJson(json, 'medications', (dataJson) => MedicationModel.fromJson(dataJson)));
  }
}
