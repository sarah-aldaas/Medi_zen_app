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

  int _currentPagePaid = 1;
  int _currentPageUnpaid = 1;
  bool _hasMorePaid = true;
  bool _hasMoreUnpaid = true;
  Map<String, dynamic> _currentFiltersPaid = {};
  Map<String, dynamic> _currentFiltersUnpaid = {};
  List<AppointmentModel> _paidAppointments = [];
  List<AppointmentModel> _unpaidAppointments = [];

  Future<void> getFinishedAppointments({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    required bool isPaid,
  }) async {
    if (!loadMore) {
      if (isPaid) {
        _currentPagePaid = 1;
        _hasMorePaid = true;
        _paidAppointments = [];
      } else {
        _currentPageUnpaid = 1;
        _hasMoreUnpaid = true;
        _unpaidAppointments = [];
      }
      emit(InvoiceLoading());
    } else if ((isPaid && !_hasMorePaid) || (!isPaid && !_hasMoreUnpaid)) {
      return;
    }

    if (filters != null) {
      if (isPaid) {
        _currentFiltersPaid = filters;
      } else {
        _currentFiltersUnpaid = filters;
      }
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(InvoiceError(error: 'No internet connection'));
    //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
    //   return;
    // }

    final currentFilters = isPaid ? _currentFiltersPaid : _currentFiltersUnpaid;
    final currentPage = isPaid ? _currentPagePaid : _currentPageUnpaid;

    final result = await remoteDataSource.getMyAppointmentFinished(
      filters: currentFilters,
      page: currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<AppointmentModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        if (isPaid) {
          _paidAppointments.addAll(result.data.paginatedData!.items);
          _hasMorePaid = result.data.paginatedData!.items.isNotEmpty &&
              result.data.meta!.currentPage < result.data.meta!.lastPage;
          _currentPagePaid++;
        } else {
          _unpaidAppointments.addAll(result.data.paginatedData!.items);
          _hasMoreUnpaid = result.data.paginatedData!.items.isNotEmpty &&
              result.data.meta!.currentPage < result.data.meta!.lastPage;
          _currentPageUnpaid++;
        }

        emit(InvoiceAppointmentsSuccess(
          paidAppointments: _paidAppointments,
          unpaidAppointments: _unpaidAppointments,
          hasMorePaid: _hasMorePaid,
          hasMoreUnpaid: _hasMoreUnpaid,
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