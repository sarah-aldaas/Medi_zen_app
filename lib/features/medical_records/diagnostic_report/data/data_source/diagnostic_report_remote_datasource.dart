import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/end_points/diagnostic_report_end_points.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/response_handler.dart';

abstract class DiagnosticReportRemoteDataSource {
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReport({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String conditionId,
  });

  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({
    required String diagnosticReportId,
  });

  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getDiagnosticReportOfCondition({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String conditionId
  });
}

class DiagnosticReportRemoteDataSourceImpl
    implements DiagnosticReportRemoteDataSource {
  final NetworkClient networkClient;

  DiagnosticReportRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReport({
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
      DiagnosticReportEndPoints.getAllDiagnosticReport(),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(
            json,
            'diagnostic_reports',
            (dataJson) => DiagnosticReportModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>>
  getAllDiagnosticReportOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
    required String conditionId,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getAllDiagnosticReportOfAppointment(
        appointmentId: appointmentId, conditionId: conditionId,
      ),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(
            json,
            'diagnostic_reports',
            (dataJson) => DiagnosticReportModel.fromJson(dataJson),
          ),
    );
  }

  @override
  Future<Resource<DiagnosticReportModel>> getDetailsDiagnosticReport({
    required String diagnosticReportId,
  }) async {
    final response = await networkClient.invoke(
      DiagnosticReportEndPoints.getDetailsDiagnosticReport(
        diagnosticReportId: diagnosticReportId,
      ),
      RequestType.get,
    );
    return ResponseHandler<DiagnosticReportModel>(response).processResponse(
      fromJson:
          (json) => DiagnosticReportModel.fromJson(json['diagnostic_report']),
    );
  }

  @override
  Future<Resource<PaginatedResponse<DiagnosticReportModel>>> getDiagnosticReportOfCondition({
    required String conditionId,
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
      DiagnosticReportEndPoints.getAllDiagnosticReportOfCondition(conditionId: conditionId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<DiagnosticReportModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<DiagnosticReportModel>.fromJson(
        json,
        'diagnostic_reports',
            (dataJson) => DiagnosticReportModel.fromJson(dataJson),
      ),
    );
  }
}
