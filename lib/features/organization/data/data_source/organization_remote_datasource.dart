import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/organization_end_points.dart';
import '../models/organization_model.dart';

abstract class OrganizationRemoteDataSource {
  Future<Resource<OrganizationModel>> getDetailsOrganization();
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final NetworkClient networkClient;

  OrganizationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<OrganizationModel>> getDetailsOrganization() async {
    final response = await networkClient.invoke(OrganizationEndPoints.getOrganizationDetails(), RequestType.get);
    return ResponseHandler<OrganizationModel>(response).processResponse(fromJson: (json) => OrganizationModel.fromJson(json['organization']));
  }

}
