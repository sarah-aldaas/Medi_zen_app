import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../../appointment/data/models/appointment_model.dart';
import '../../../data/data_source/invoice_remote_data_sources.dart';
import '../../../data/models/invoice_model.dart';
part 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  InvoiceCubit({
    required this.remoteDataSource,
    required this.networkInfo,
  }) : super(InvoiceInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<AppointmentModel> _allAppointments = [];

  Future<void> getFinishedAppointments({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAppointments = [];
      emit(InvoiceLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(InvoiceError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getMyAppointmentFinished(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<AppointmentModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allAppointments.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(InvoiceAppointmentsSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<AppointmentModel>(
            paginatedData: PaginatedData<AppointmentModel>(items: _allAppointments),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(InvoiceError(error: result.data.msg ?? 'Failed to fetch appointments'));
      }
    } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
      emit(InvoiceError(error: result.message ?? 'Failed to fetch appointments'));
    }
  }

  Future<void> getInvoiceDetails({
    required String appointmentId,
    required String invoiceId,
    required BuildContext context,
  }) async {
    emit(InvoiceLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(InvoiceError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getDetailsInvoice(
      appointmentId: appointmentId,
      invoiceId: invoiceId,
    );

    if (result is Success<InvoiceModel>) {
      if (result.data.note == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      emit(InvoiceDetailsSuccess(invoice: result.data));
    } else if (result is ResponseError<InvoiceModel>) {
      emit(InvoiceError(error: result.message ?? 'Failed to fetch invoice details'));
    }
  }
}