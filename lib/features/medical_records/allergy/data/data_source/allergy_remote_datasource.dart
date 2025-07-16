import 'package:medizen_app/features/medical_records/allergy/data/end_points/allergy_end_points.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';

abstract class AllergyRemoteDataSource {
  Future<Resource<PaginatedResponse<AllergyModel>>> getAllMyAllergies({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<AllergyModel>>> getAllMyAllergiesOfAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<AllergyModel>> getSpecificAllergy({required String allergyId});
}

class AllergyRemoteDataSourceImpl implements AllergyRemoteDataSource {
  final NetworkClient networkClient;

  AllergyRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<AllergyModel>>> getAllMyAllergies({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(AllergyEndPoints.getAllMyAllergies, RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<AllergyModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<AllergyModel>.fromJson(json, 'allergies', (dataJson) => AllergyModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<AllergyModel>>> getAllMyAllergiesOfAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      AllergyEndPoints.getAllMyAllergiesOfAppointment(appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<AllergyModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<AllergyModel>.fromJson(json, 'allergies', (dataJson) => AllergyModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<AllergyModel>> getSpecificAllergy({required String allergyId}) async {
    final response = await networkClient.invoke(AllergyEndPoints.getSpecificAllergy(allergyId: allergyId), RequestType.get);
    return ResponseHandler<AllergyModel>(response).processResponse(fromJson: (json) => AllergyModel.fromJson(json ['allergy']));
  }
}
