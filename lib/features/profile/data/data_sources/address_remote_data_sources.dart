import 'package:medizen_app/base/data/models/pagination_model.dart';
import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/address_end_points.dart';

abstract class AddressRemoteDataSource {
  Future<Resource<PaginatedResponse<AddressModel>>> getListAllAddress({
    int page = 1,
    int perPage = 10,
    String? typeId,
    String? useId,
  });

  Future<Resource<PublicResponseModel>> updateAddress({required String id, required AddOrUpdateAddressModel addressModel});

  Future<Resource<AddressModel>> showAddress({required String id});

  Future<Resource<PublicResponseModel>> deleteAddress({required String id});

  Future<Resource<PublicResponseModel>> createAddress({required AddOrUpdateAddressModel addressModel});
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final NetworkClient networkClient;

  AddressRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PublicResponseModel>> createAddress({required AddOrUpdateAddressModel addressModel}) async {
    final response = await networkClient.invoke(AddressEndPoints.createAddress, RequestType.post, body: addressModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteAddress({required String id}) async {
    final response = await networkClient.invoke(AddressEndPoints.deleteAddress(id: id), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<AddressModel>>> getListAllAddress({
    int page = 1,
    int perPage = 10,
    String? typeId,
    String? useId,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (typeId != null) 'type_id': typeId,
      if (useId != null) 'use_id': useId,
    };

    final response = await networkClient.invoke(
      AddressEndPoints.listAllAddress(),
      RequestType.get,
      queryParameters: queryParams,
    );

    return ResponseHandler<PaginatedResponse<AddressModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<AddressModel>.fromJson(
        json,
        'addresses',
            (dataJson) => AddressModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<AddressModel>> showAddress({required String id}) async {
    final response = await networkClient.invoke(AddressEndPoints.showAddress(id: id), RequestType.get);
    return ResponseHandler<AddressModel>(response).processResponse(fromJson: (json) => AddressModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateAddress({required String id, required AddOrUpdateAddressModel addressModel}) async {
    final response = await networkClient.invoke(AddressEndPoints.updateAddress(id: id), RequestType.post, body: addressModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}