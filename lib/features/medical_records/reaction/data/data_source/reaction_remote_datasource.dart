import 'package:medizen_app/features/medical_records/reaction/data/end_points/reaction_end_points.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_model.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';

abstract class ReactionRemoteDataSource {
  Future<Resource<PaginatedResponse<ReactionModel>>> getAllReactionOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String allergyId,
    required String appointmentId,
  });

  Future<Resource<ReactionModel>> getSpecificReaction({required String allergyId, required String reactionId});
}

class ReactionRemoteDataSourceImpl implements ReactionRemoteDataSource {
  final NetworkClient networkClient;

  ReactionRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ReactionModel>>> getAllReactionOfAppointment({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String allergyId,
    required String appointmentId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ReactionEndPoints.getAllReactionOfAppointment(allergyId: allergyId, appointmentId: appointmentId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ReactionModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ReactionModel>.fromJson(json, 'reactions', (dataJson) => ReactionModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ReactionModel>> getSpecificReaction({required String allergyId, required String reactionId}) async {
    final response = await networkClient.invoke(ReactionEndPoints.getSpecificReaction(allergyId: allergyId, reactionId: reactionId), RequestType.get);
    return ResponseHandler<ReactionModel>(response).processResponse(fromJson: (json) => ReactionModel.fromJson(json['reaction']));
  }
}
