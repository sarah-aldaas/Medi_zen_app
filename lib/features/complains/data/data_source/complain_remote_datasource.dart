import 'dart:io';

import 'package:dio/dio.dart';
import 'package:medizen_app/base/data/models/public_response_model.dart';
import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/features/complains/data/end_points/complain_end_points.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/response_handler.dart';

abstract class ComplainRemoteDataSource {
  Future<Resource<PaginatedResponse<ComplainModel>>> getAllComplain({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<ComplainModel>>> getAllComplainOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  });

  Future<Resource<ComplainModel>> getDetailsComplain({required String complainId});

  Future<Resource<PublicResponseModel>> deleteComplain({required String complainId});

  Future<Resource<PublicResponseModel>> createComplain({required String appointmentId, required ComplainModel complain});

  Future<Resource<List<ComplainResponseModel>>> getResponseOfComplain({required String complainId});

  Future<Resource<PublicResponseModel>> responseOnComplain({required String complainId, required String responseText, List<File>? attachments});

  Future<Resource<PublicResponseModel>> closeComplain({required String complainId});
}

class ComplainRemoteDataSourceImpl implements ComplainRemoteDataSource {
  final NetworkClient networkClient;

  ComplainRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ComplainModel>>> getAllComplain({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ComplainEndPoints.getAllComplain(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ComplainModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ComplainModel>.fromJson(json, 'complaints', (dataJson) => ComplainModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<ComplainModel>>> getAllComplainOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String appointmentId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ComplainEndPoints.getAllComplainOfAppointment(appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ComplainModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ComplainModel>.fromJson(json, 'complaints', (dataJson) => ComplainModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ComplainModel>> getDetailsComplain({required String complainId}) async {
    final response = await networkClient.invoke(ComplainEndPoints.getDetailsComplain(complainId: complainId), RequestType.get);
    return ResponseHandler<ComplainModel>(response).processResponse(fromJson: (json) => ComplainModel.fromJson(json['complaint']));
  }

  @override
  Future<Resource<PublicResponseModel>> closeComplain({required String complainId}) async {
    final response = await networkClient.invoke(ComplainEndPoints.closeComplain(complainId: complainId), RequestType.post);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> createComplain({required String appointmentId, required ComplainModel complain}) async {
    final formData = FormData.fromMap({'title': complain.title, 'description': complain.description, 'type_id': complain.type?.id});

    // Add attachments if they exist
    if (complain.attachmentsFiles != null && complain.attachmentsFiles!.isNotEmpty) {
      formData.files.addAll(
        complain.attachmentsFiles!.map((file) => MapEntry('attachments[]', MultipartFile.fromFileSync(file.path, filename: file.path.split('/').last))),
      );
    }

    final response = await networkClient.invokeMultipart(ComplainEndPoints.createComplain(appointmentId: appointmentId), RequestType.post, formData: formData);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteComplain({required String complainId}) async {
    final response = await networkClient.invoke(ComplainEndPoints.deleteComplain(complainId: complainId), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<List<ComplainResponseModel>>> getResponseOfComplain({required String complainId}) async {
    final response = await networkClient.invoke(ComplainEndPoints.getResponseOfComplain(complainId: complainId), RequestType.get);
    return ResponseHandler<List<ComplainResponseModel>>(
      response,
    ).processResponse(fromJson: (json) => (json['responses'] as List).map((e) => ComplainResponseModel.fromJson(e)).toList());
  }

  @override
  Future<Resource<PublicResponseModel>> responseOnComplain({required String complainId, required String responseText, List<File>? attachments}) async {
    // Create FormData
    final formData = FormData.fromMap({'response': responseText});

    // Add attachments if they exist
    if (attachments != null && attachments.isNotEmpty) {
      formData.files.addAll(
        attachments.map(
          (file) => MapEntry(
            'attachments[]', // Note the [] for multiple files
            MultipartFile.fromFileSync(file.path, filename: file.path.split('/').last),
          ),
        ),
      );
    }

    final response = await networkClient.invokeMultipart(ComplainEndPoints.responseOnComplain(complainId: complainId), RequestType.post, formData: formData);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
