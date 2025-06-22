import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';

import '../end_points/imaging_study_end_points.dart';
import '../models/imaging_study_model.dart';

abstract class ImagingStudyRemoteDataSource {
  Future<Resource<ImagingStudyModel>> getDetailsImagingStudy({required String serviceId, required String imagingStudyId});
}

class ImagingStudyRemoteDataSourceImpl implements ImagingStudyRemoteDataSource {
  final NetworkClient networkClient;

  ImagingStudyRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<ImagingStudyModel>> getDetailsImagingStudy({required String serviceId, required String imagingStudyId}) async {
    final response = await networkClient.invoke(
      ImagingStudyEndPoints.getDetailsImagingStudy(serviceId: serviceId, imagingStudyId: imagingStudyId),
      RequestType.get,
    );
    return ResponseHandler<ImagingStudyModel>(response).processResponse(fromJson: (json) => ImagingStudyModel.fromJson(json['imaging_study']));
  }
}
