import 'package:dio/dio.dart';
import 'package:medizen_app/base/data/models/public_response_model.dart';
import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/profile/data/models/update_profile_request_Model.dart';

import '../end_points/profile_end_points.dart';

abstract class ProfileRemoteDataSource {
  Future<Resource<PatientModel>> getMyProfile();
  Future<Resource<PublicResponseModel>> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final NetworkClient networkClient;

  ProfileRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PatientModel>> getMyProfile() async {
    final response = await networkClient.invoke(
      ProfileEndPoints.showMyProfile,
      RequestType.get,
    );
    return ResponseHandler<PatientModel>(response).processResponse(
      fromJson: (json) => PatientModel.fromJson(json["profile"]),
    );
  }

  // @override
  // Future<Resource<PublicResponseModel>> updateMyProfile({
  //   required UpdateProfileRequestModel updateProfileRequestModel,
  // }) async {
  //   final response = await networkClient.invoke(
  //     ProfileEndPoints.editMyProfile,
  //     RequestType.post,
  //     body: updateProfileRequestModel.toJson(),
  //   );
  //   return ResponseHandler<PublicResponseModel>(
  //     response,
  //   ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  // }

  @override
  Future<Resource<PublicResponseModel>> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
  }) async {
    final formData = FormData.fromMap(updateProfileRequestModel.toJson());

    if (updateProfileRequestModel.avatar != null) {
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            updateProfileRequestModel.avatar!.path,
            filename: updateProfileRequestModel.avatar!.path.split('/').last,
          ),
        ),
      );
    }

    final response = await networkClient.invokeMultipart(
      ProfileEndPoints.editMyProfile,
      RequestType.post,
      formData: formData,
    );
    return ResponseHandler<PublicResponseModel>(
      response,
    ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
