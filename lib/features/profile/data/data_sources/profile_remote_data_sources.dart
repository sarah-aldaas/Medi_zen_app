import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/profile/data/end_points_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<Resource<PatientModel>> getMyProfile();
  Future<Resource<PatientModel>> updateMyProfile({
    required PatientModel patientModel,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final NetworkClient networkClient;

  ProfileRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PatientModel>> getMyProfile() async {
    final response = await networkClient.invoke(
      EndPointsProfile.showMyProfile,
      RequestType.get,
    );
    return ResponseHandler<PatientModel>(response).processResponse(
      fromJson: (json) => PatientModel.fromJson(json["profile"]),
    );
  }

  @override
  Future<Resource<PatientModel>> updateMyProfile({
    required PatientModel patientModel,
  }) async {
    final response = await networkClient.invoke(
      EndPointsProfile.editMyProfile,
      RequestType.post,
      body: patientModel.toJson(),
    );
    return ResponseHandler<PatientModel>(
      response,
    ).processResponse(fromJson: (json) => PatientModel.fromJson(json));
  }
}
