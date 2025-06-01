import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/features/clinics/data/clinic_end_points.dart';
import 'package:medizen_app/features/clinics/data/models/clinic_model.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';

abstract class ClinicRemoteDataSource {
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics({
    String? searchQuery,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<ClinicModel>> getSpecificClinic({required String id});
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final NetworkClient networkClient;

  ClinicRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics({
    String? searchQuery,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = {
      'page': page,
      'pagination_count': perPage,
      if (searchQuery != null && searchQuery.isNotEmpty)
        'search_query': searchQuery,
    };

    final response = await networkClient.invoke(
      ClinicEndPoints.getAllClinics,
      RequestType.get,
      queryParameters: queryParams,
    );

    return ResponseHandler<PaginatedResponse<ClinicModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<ClinicModel>.fromJson(json, 'clinics', (
            dataJson,
          ) {
            return ClinicModel.fromJson(dataJson);
          }),
    );
  }

  @override
  Future<Resource<ClinicModel>> getSpecificClinic({required String id}) async {
    final response = await networkClient.invoke(
      ClinicEndPoints.getSpecificClinics(id: id),
      RequestType.get,
    );
    return ResponseHandler<ClinicModel>(
      response,
    ).processResponse(fromJson: (json) => ClinicModel.fromJson(json['clinic']));
  }
}
