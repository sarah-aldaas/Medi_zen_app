import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/appointment/data/models/slots_model.dart';
import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/appointment_end_points.dart';
import '../models/appointment_create_model.dart';
import '../models/appointment_update_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<Resource<List<SlotModel>>> getAllSlots({required String practitionerId, required String date});

  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointment();

  Future<Resource<PublicResponseModel>> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel});

  Future<Resource<AppointmentModel>> getDetailsAppointment({required String id});

  Future<Resource<PublicResponseModel>> cancelAppointment({required String id, required String cancellationReason});

  Future<Resource<PublicResponseModel>> createAppointment({required AppointmentCreateModel appointmentModel});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final NetworkClient networkClient;

  AppointmentRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<List<SlotModel>>> getAllSlots({required String practitionerId, required String date}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getSlots(practitionerId: practitionerId, date: date), RequestType.get);

    return ResponseHandler<List<SlotModel>>(
      response,
    ).processResponse(fromJson: (json) => (json['slots'] as List).map((slotJson) => SlotModel.fromJson(slotJson as Map<String, dynamic>)).toList());
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
      RequestType.delete,
      body: {"cancellation_reason": cancellationReason},
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointment() async {
    final response = await networkClient.invoke(AppointmentEndPoints.getMyAppointment(), RequestType.get);

    return ResponseHandler<PaginatedResponse<AppointmentModel>>(response).processResponse(
      fromJson:
          (json) => PaginatedResponse<AppointmentModel>.fromJson(json, 'appointments', (dataJson) {
            return AppointmentModel.fromJson(dataJson);
          }),
    );
  }

  @override
  Future<Resource<AppointmentModel>> getDetailsAppointment({required String id}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.getDetailsAppointment(id: id), RequestType.get);
    return ResponseHandler<AppointmentModel>(response).processResponse(fromJson: (json) => AppointmentModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel}) async {
    final response = await networkClient.invoke(AppointmentEndPoints.updateAppointment(id: id), RequestType.post, body: appointmentModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
