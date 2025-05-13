import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/features/services/data/model/health_care_service_eligibility_codes_model.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:medizen_app/features/services/data/services_end_points.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';

abstract class ServicesRemoteDataSource {
  Future<Resource<PaginatedResponse<HealthCareServiceModel>>> getAllHealthCareServices();

  Future<Resource<HealthCareServiceModel>> getSpecificHealthCareServices({required String id});

  Future<Resource<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>> getAllHealthCareServiceEligibilityCodes();

  Future<Resource<HealthCareServiceEligibilityCodesModel>> getSpecificHealthCareServiceEligibilityCodes({required String id});
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final NetworkClient networkClient;

  ServicesRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<HealthCareServiceModel>>> getAllHealthCareServices() async {
    final response = await networkClient.invoke(ServicesEndPoints.getAllHealthCareServices, RequestType.get);
    return ResponseHandler<PaginatedResponse<HealthCareServiceModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<HealthCareServiceModel>.fromJson(json, 'healthCareServices', (dataJson) {
            return HealthCareServiceModel.fromJson(dataJson);
          }),
    );
  }

  @override
  Future<Resource<HealthCareServiceModel>> getSpecificHealthCareServices({required String id}) async {
    final response = await networkClient.invoke(ServicesEndPoints.getSpecificHealthCareServices(id: id), RequestType.get);
    return ResponseHandler<HealthCareServiceModel>(response).processResponse(fromJson: (json) => HealthCareServiceModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>> getAllHealthCareServiceEligibilityCodes() async {
    final response = await networkClient.invoke(ServicesEndPoints.getAllHealthCareServiceEligibilityCodes, RequestType.get);
    return ResponseHandler<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<HealthCareServiceEligibilityCodesModel>.fromJson(json, 'healthCareServiceEligibilityCodes', (dataJson) {
            return HealthCareServiceEligibilityCodesModel.fromJson(dataJson);
          }),
    );
  }

  @override
  Future<Resource<HealthCareServiceEligibilityCodesModel>> getSpecificHealthCareServiceEligibilityCodes({required String id}) async {
    final response = await networkClient.invoke(ServicesEndPoints.getSpecificHealthCareServiceEligibilityCodes(id: id), RequestType.get);
    return ResponseHandler<HealthCareServiceEligibilityCodesModel>(
      response,
    ).processResponse(fromJson: (json) => HealthCareServiceEligibilityCodesModel.fromJson(json));
  }
}
