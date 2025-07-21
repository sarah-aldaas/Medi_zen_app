import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/appointment/data/models/days_work_doctor_model.dart';
import 'package:medizen_app/features/appointment/data/models/slots_model.dart';
import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/appointment_end_points.dart';
import '../models/appointment_create_model.dart';
import '../models/appointment_update_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<Resource<AllSlotModel>> getAllSlots({required String practitionerId, required String date});
  Future<Resource<DaysWorkDoctorModel>> getDaysWorkDoctor({required String doctorId});
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });
  Future<Resource<PublicResponseModel>> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel});
  Future<Resource<AppointmentResponseModel>> getDetailsAppointment({required String id});
  Future<Resource<PublicResponseModel>> cancelAppointment({required String id, required String cancellationReason});
  Future<Resource<PublicResponseModel>> createAppointment({required AppointmentCreateModel appointmentModel});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final NetworkClient networkClient;

  AppointmentRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<AllSlotModel>> getAllSlots({required String practitionerId, required String date}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getSlots(practitionerId: practitionerId, date: date), RequestType.get);
    return ResponseHandler<AllSlotModel>(response).processResponse(fromJson: (json) => AllSlotModel.fromJson(json));
  }

  @override
  Future<Resource<DaysWorkDoctorModel>> getDaysWorkDoctor({required String doctorId}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getDaysWorkDoctor(doctorId: doctorId), RequestType.get);
    return ResponseHandler<DaysWorkDoctorModel>(response).processResponse(fromJson: (json) => DaysWorkDoctorModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> createAppointment({required AppointmentCreateModel appointmentModel}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.createAppointment(), RequestType.post, body: appointmentModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> cancelAppointment({required String id, required String cancellationReason}) async {
    final response = await networkClient.invoke(
      AppointmentEndPoints.cancelAppointment(id: id),
      RequestType.post,
      body: {"cancellation_reason": cancellationReason},
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      AppointmentEndPoints.getMyAppointment(),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<AppointmentModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<AppointmentModel>.fromJson(
        json,
        'appointments',
            (dataJson) => AppointmentModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<AppointmentResponseModel>> getDetailsAppointment({required String id}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getDetailsAppointment(id: id), RequestType.get);
    return ResponseHandler<AppointmentResponseModel>(response).processResponse(fromJson: (json) => AppointmentResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.updateAppointment(id: id), RequestType.post, body: appointmentModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}

