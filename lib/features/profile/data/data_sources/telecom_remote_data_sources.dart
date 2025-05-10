import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/profile/data/end_points_profile.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';
import 'package:medizen_app/features/profile/data/models/telecom_update_respons.dart';

abstract class TelecomRemoteDataSource {
  Future<Resource<TelecomsDataModel>> getListAllTelecom({required String rank, required String paginationCount});

  Future<Resource<TelecomResponseModel>> updateTelecom({required String id, required TelecomModel telecomModel});

  Future<Resource<TelecomModel>> showTelecom({required String id});

  Future<Resource<TelecomResponseModel>> deleteTelecom({required String id});

  Future<Resource<TelecomResponseModel>> createTelecom({required TelecomModel telecomModel});
}

class TelecomRemoteDataSourceImpl implements TelecomRemoteDataSource {
  final NetworkClient networkClient;

  TelecomRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<TelecomResponseModel>> createTelecom({required TelecomModel telecomModel}) async {
    final response = await networkClient.invoke(EndPointsTelecom.createTelecom, RequestType.post, body: telecomModel.toJson());
    return ResponseHandler<TelecomResponseModel>(response).processResponse(fromJson: (json) => TelecomResponseModel.fromJson(json));
  }

  @override
  Future<Resource<TelecomResponseModel>> deleteTelecom({required String id}) async {
    final response = await networkClient.invoke(EndPointsTelecom.deleteTelecom(id: id), RequestType.delete);
    return ResponseHandler<TelecomResponseModel>(response).processResponse(fromJson: (json) => TelecomResponseModel.fromJson(json));
  }

  @override
  Future<Resource<TelecomsDataModel>> getListAllTelecom({required String rank, required String paginationCount}) async {
    final response = await networkClient.invoke(EndPointsTelecom.listAllTelecom(rank: rank, paginationCount: paginationCount), RequestType.get);
    return ResponseHandler<TelecomsDataModel>(response).processResponse(fromJson: (json) => TelecomsDataModel.fromJson(json));
  }

  @override
  Future<Resource<TelecomModel>> showTelecom({required String id}) async {
    final response = await networkClient.invoke(EndPointsTelecom.showTelecom(id: id), RequestType.get);
    return ResponseHandler<TelecomModel>(response).processResponse(fromJson: (json) => TelecomModel.fromJson(json));
  }

  @override
  Future<Resource<TelecomResponseModel>> updateTelecom({required String id, required TelecomModel telecomModel}) async {
    final response = await networkClient.invoke(EndPointsTelecom.updateTelecom(id: id), RequestType.post, body: telecomModel.toJson());
    return ResponseHandler<TelecomResponseModel>(response).processResponse(fromJson: (json) => TelecomResponseModel.fromJson(json));
  }
}
