import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../../../../base/data/models/pagination_model.dart';
import '../end_points/organization_end_points.dart';
import '../models/organization_model.dart';
import '../models/qualification_organization_model.dart';

abstract class OrganizationRemoteDataSource {
  Future<Resource<OrganizationModel>> getDetailsOrganization();
  Future<Resource<PaginatedResponse<QualificationsOrganizationModel>>> getQualificationOrganization({ int page = 1, int perPage = 10});
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final NetworkClient networkClient;

  OrganizationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<OrganizationModel>> getDetailsOrganization() async {
    final response = await networkClient.invoke(OrganizationEndPoints.getOrganizationDetails(), RequestType.get);
    return ResponseHandler<OrganizationModel>(response).processResponse(fromJson: (json) => OrganizationModel.fromJson(json['organization']));
  }

  @override
  Future<Resource<PaginatedResponse<QualificationsOrganizationModel>>> getQualificationOrganization({ int page = 1, int perPage = 10}) async  {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString()};


    final response = await networkClient.invoke(OrganizationEndPoints.getOrganizationQualification(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<QualificationsOrganizationModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<QualificationsOrganizationModel>.fromJson(json, 'qualifications', (dataJson) => QualificationsOrganizationModel.fromJson(dataJson)));

  }



}
