import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/features/clinics/data/clinic_end_points.dart';
import 'package:medizen_app/features/clinics/data/models/clinic_model.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';

abstract class ClinicRemoteDataSource {
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics();
  Future<Resource<PaginatedResponse<DoctorModel>>> getDoctorsOfClinic({required String clinicId});

  Future<Resource<ClinicModel>> getSpecificClinic({required String id});
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final NetworkClient networkClient;

  ClinicRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics() async {
    final response = await networkClient.invoke(ClinicEndPoints.getAllClinics, RequestType.get);
    return ResponseHandler<PaginatedResponse<ClinicModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<ClinicModel>.fromJson(json, 'clinics', (dataJson) {
            return ClinicModel.fromJson(dataJson);
          }),
    );
  }


  @override
  Future<Resource<PaginatedResponse<DoctorModel>>> getDoctorsOfClinic({required String clinicId}) async {
    final response = await networkClient.invoke(ClinicEndPoints.getDoctorsOfClinic(clinicId: clinicId), RequestType.get);
    return ResponseHandler<PaginatedResponse<DoctorModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<DoctorModel>.fromJson(json, 'doctors', (dataJson) {
        return DoctorModel.fromJson(dataJson);
      }),
    );
  }

  @override
  Future<Resource<ClinicModel>> getSpecificClinic({required String id}) async {
    final response = await networkClient.invoke(ClinicEndPoints.getSpecificClinics(id: id), RequestType.get);
    return ResponseHandler<ClinicModel>(response).processResponse(fromJson: (json) => ClinicModel.fromJson(json));
  }
}
