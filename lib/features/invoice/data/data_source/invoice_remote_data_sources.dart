import 'package:medizen_app/base/helpers/enums.dart';
import 'package:medizen_app/base/services/network/network_client.dart';
import 'package:medizen_app/base/services/network/resource.dart';
import 'package:medizen_app/base/services/network/response_handler.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/invoice/data/end_points/invoice_end_points.dart';
import 'package:medizen_app/features/invoice/data/models/invoice_model.dart';
import '../../../../base/data/models/pagination_model.dart';


abstract class InvoiceRemoteDataSource {
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointmentFinished({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });
  Future<Resource<InvoiceModel>> getDetailsInvoice({required String appointmentId,required String invoiceId});
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final NetworkClient networkClient;

  InvoiceRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<AppointmentModel>>> getMyAppointmentFinished({
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
      InvoiceEndPoints.getFinishedAppointments(),
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
  Future<Resource<InvoiceModel>> getDetailsInvoice({required String appointmentId,required String invoiceId}) async {
    final response = await networkClient.invoke(InvoiceEndPoints.getDetailsInvoice(appointmentId: appointmentId,invoiceId: invoiceId), RequestType.get);
    return ResponseHandler<InvoiceModel>(response).processResponse(fromJson: (json) => InvoiceModel.fromJson(json['invoice']));
  }

}

