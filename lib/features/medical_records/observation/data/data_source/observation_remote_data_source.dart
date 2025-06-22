import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import '../end_points/observation_end_points.dart';
import '../models/observation_model.dart';

abstract class ObservationRemoteDataSource {
  Future<Resource<ObservationModel>> getDetailsObservation({required String serviceId,required String observationId});
}

class ObservationRemoteDataSourceImpl implements ObservationRemoteDataSource {
  final NetworkClient networkClient;

  ObservationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<ObservationModel>> getDetailsObservation({required String serviceId,required String observationId}) async {
    final response = await networkClient.invoke(ObservationEndPoints.getDetailsObservation(serviceId: serviceId,observationId: observationId), RequestType.get);
    return ResponseHandler<ObservationModel>(response).processResponse(fromJson: (json) => ObservationModel.fromJson(json['observation']));
  }
}
