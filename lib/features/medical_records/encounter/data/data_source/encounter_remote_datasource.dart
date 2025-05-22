import 'package:medizen_app/features/medical_records/encounter/data/end_points/encounter_end_points.dart';
import 'package:medizen_app/features/medical_records/encounter/data/models/encounter_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';

abstract class EncounterRemoteDataSource {
  Future<Resource<PaginatedResponse<EncounterModel>>> getAllMyEncounter({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<EncounterModel>> getAllMyEncounterOfAppointment({required String appointmentId});

  Future<Resource<EncounterModel>> getSpecificEncounter({required String encounterId});
}

class EncounterRemoteDataSourceImpl implements EncounterRemoteDataSource {
  final NetworkClient networkClient;

  EncounterRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<EncounterModel>>> getAllMyEncounter({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(EncounterEndPoints.getAllMyEncounter, RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<EncounterModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<EncounterModel>.fromJson(json, 'encounters', (dataJson) => EncounterModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<EncounterModel>> getAllMyEncounterOfAppointment({required String appointmentId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.getAllMyEncounterOfAppointment(appointmentId: appointmentId), RequestType.get);
    return ResponseHandler<EncounterModel>(response).processResponse(fromJson: (json) => EncounterModel.fromJson(json['encounter']));
  }

  @override
  Future<Resource<EncounterModel>> getSpecificEncounter({required String encounterId}) async {
    final response = await networkClient.invoke(EncounterEndPoints.getSpecificEncounter(encounterId: encounterId), RequestType.get);
    return ResponseHandler<EncounterModel>(response).processResponse(fromJson: (json) => EncounterModel.fromJson(json['encounter']));
  }
}
