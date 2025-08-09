import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_update_model.dart';
import 'package:medizen_app/features/appointment/data/models/days_work_doctor_model.dart';
import 'package:medizen_app/features/appointment/data/models/slots_model.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/datasource/appointment_remote_datasource.dart';
import '../../../data/models/appointment_create_model.dart';
import '../../../data/models/appointment_model.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentCubit({required this.remoteDataSource}) : super(AppointmentInitial());

  Future<void> getSlotsAppointment({required String practitionerId, required String date, required BuildContext context}) async {
    emit(SlotsAppointmentLoading());
    try {
      final result = await remoteDataSource.getAllSlots(practitionerId: practitionerId, date: date);
      if (result is Success<AllSlotModel>) {
        emit(SlotsAppointmentSuccess(listSlots: result.data.listSlots!));
      } else if (result is ResponseError<AllSlotModel>) {
        emit(AppointmentError(error: result.message ?? 'Failed to fetch slots'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  Future<void> getDaysWorkDoctor({required String doctorId, required BuildContext context}) async {
    emit(DaysWorkDoctorLoading());
    try {
      final result = await remoteDataSource.getDaysWorkDoctor(doctorId: doctorId);
      if (result is Success<DaysWorkDoctorModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        emit(DaysWorkDoctorSuccess(days: result.data));
      } else if (result is ResponseError<DaysWorkDoctorModel>) {
        emit(AppointmentError(error: result.message ?? 'Failed to fetch days'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<AppointmentModel> _allAppointments = [];

  Future<void> getMyAppointment({Map<String, dynamic>? filters, bool loadMore = false, required BuildContext context}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAppointments = [];
      emit(AppointmentLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    try {
      final result = await remoteDataSource.getMyAppointment(filters: _currentFilters, page: _currentPage, perPage: 5);

      if (result is Success<PaginatedResponse<AppointmentModel>>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        try {
          if (result.data.status!) {
            _allAppointments.addAll(result.data.paginatedData!.items);
            _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
            _currentPage++;
            emit(
              AppointmentSuccess(
                hasMore: _hasMore,
                paginatedResponse: PaginatedResponse<AppointmentModel>(
                  paginatedData: PaginatedData<AppointmentModel>(items: _allAppointments),
                  meta: result.data.meta,
                  links: result.data.links,
                ),
              ),
            );
          } else {
            emit(AppointmentError(error: result.data.msg ?? 'Failed to fetch Appointments'));
          }
        } catch (e) {
          emit(AppointmentError(error: result.data.msg ?? 'Failed to fetch Appointments'));
        }
      } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
        emit(AppointmentError(error: result.message ?? 'Failed to fetch Appointments'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  Future<void> createAppointment({required AppointmentCreateModel appointmentModel, required BuildContext context}) async {
    emit(AppointmentLoading(isLoadMore: false));
    try {
      final result = await remoteDataSource.createAppointment(appointmentModel: appointmentModel);
      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          emit(CreateAppointmentSuccess());
        } else {
          emit(AppointmentError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to create appointment');
        emit(AppointmentError(error: result.message ?? 'Failed to create appointment'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  Future<void> updateAppointment({required String id, required AppointmentUpdateModel appointmentModel, required BuildContext context}) async {
    emit(AppointmentLoading(isLoadMore: false));
    try {
      final result = await remoteDataSource.updateAppointment(id: id, appointmentModel: appointmentModel);
      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          emit(UpdateAppointmentSuccess());
          await getMyAppointment(context: context);
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(AppointmentError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to update appointment');
        emit(AppointmentError(error: result.message ?? 'Failed to update appointment'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  Future<void> cancelAppointment({required String id, required String cancellationReason, required BuildContext context}) async {
    emit(AppointmentLoading(isLoadMore: false));
    try {
      final result = await remoteDataSource.cancelAppointment(id: id, cancellationReason: cancellationReason);
      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.welcomeScreen.name);
        }
        if (result.data.status) {
          await getMyAppointment(context: context);
        } else {
          ShowToast.showToastError(message: result.data.msg);
          emit(AppointmentError(error: result.data.msg));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to cancel appointment');
        emit(AppointmentError(error: result.message ?? 'Failed to cancel appointment'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }

  Future<void> getDetailsAppointment({required String id, required BuildContext context}) async {
    emit(AppointmentLoading(isLoadMore: false));
    try {
      final result = await remoteDataSource.getDetailsAppointment(id: id);
      if (result is Success<AppointmentResponseModel>) {
        if (result.data.status) {
          emit(AppointmentDetailsSuccess(appointmentModel: result.data.appointment!));
        } else {
          emit(AppointmentError(error: result.data.msg));
        }
      } else if (result is ResponseError<AppointmentResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to fetch appointment details');
        emit(AppointmentError(error: result.message ?? 'Failed to fetch appointment details'));
      }
    } catch (e) {
      emit(AppointmentError(error: "Please check your internet!."));
    }
  }
}
