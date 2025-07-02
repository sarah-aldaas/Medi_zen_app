import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/medical_records/service_request/data/end_points/service_request_end_points.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';

import '../../../../../base/data/models/pagination_model.dart';

abstract class ServiceRequestRemoteDataSource {
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequest({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  });

  Future<Resource<ServiceRequestModel>> getDetailsServiceRequest({required String serviceId});
}

class ServiceRequestRemoteDataSourceImpl implements ServiceRequestRemoteDataSource {
  final NetworkClient networkClient;

  ServiceRequestRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequest({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ServiceRequestEndPoints.getAllServiceRequest(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PaginatedResponse<ServiceRequestModel>>> getAllServiceRequestForAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ServiceRequestEndPoints.getAllServiceRequestForAppointment(appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ServiceRequestModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ServiceRequestModel>.fromJson(json, 'service_requests', (dataJson) => ServiceRequestModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<ServiceRequestModel>> getDetailsServiceRequest({required String serviceId}) async {
    final response = await networkClient.invoke(ServiceRequestEndPoints.getDetailsService(serviceId: serviceId), RequestType.get);
    return ResponseHandler<ServiceRequestModel>(response).processResponse(fromJson: (json) => ServiceRequestModel.fromJson(json['service_request']));
  }
}
