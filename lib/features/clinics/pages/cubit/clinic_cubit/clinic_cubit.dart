import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/datasources/clinic_remote_datasources.dart';
import '../../../data/models/clinic_model.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final ClinicRemoteDataSource remoteDataSource;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false; // Add loading state tracking
  String? currentSearchQuery;
  List<ClinicModel> allClinics = [];
  bool _isClosed = false;

  ClinicCubit({required this.remoteDataSource}) : super(ClinicInitial());

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  Future<void> fetchClinics({
    String? searchQuery,
    bool loadMore = false,
  }) async {
    // Prevent multiple simultaneous requests
    if (isLoading) return;
    isLoading = true;

    if (!loadMore) {
      currentPage = 1;
      hasMore = true;
      currentSearchQuery = searchQuery;
      allClinics.clear();
      emit(ClinicLoading(isInitialLoad: true));
    } else {
      if (!hasMore) {
        isLoading = false;
        return;
      }
      currentPage++;
    }

    try {
      final result = await remoteDataSource.getAllClinics(
        searchQuery: currentSearchQuery,
        page: currentPage,
        perPage: 15,
      );

      if (result is Success<PaginatedResponse<ClinicModel>>) {
        if (!result.data.status! || result.data.paginatedData == null) {
          hasMore = false;
          emit(
            allClinics.isEmpty
                ? ClinicEmpty(message: result.data.msg!)
                : ClinicSuccess(clinics: allClinics),
          );
          return;
        }

        final newClinics = result.data.paginatedData!.items;

        // Filter out any duplicates before adding
        final newUniqueClinics =
            newClinics
                .where(
                  (newClinic) =>
                      !allClinics.any(
                        (existingClinic) => existingClinic.id == newClinic.id,
                      ),
                )
                .toList();

        allClinics.addAll(newUniqueClinics);
        hasMore = newClinics.length >= 15;

        emit(ClinicSuccess(clinics: allClinics));
      } else if (result is ResponseError<PaginatedResponse<ClinicModel>>) {
        emit(ClinicError(error: result.message ?? 'Failed to fetch Clinics'));
        if (loadMore) currentPage--;
      }
    } finally {
      isLoading = false;
    }
  }


  Future<void> getSpecificClinic({required String id}) async {
    if (_isClosed) return;

    emit(ClinicLoading());
    try {
      final result = await remoteDataSource.getSpecificClinic(id: id);
      if (_isClosed) return;

      if (result is Success<ClinicModel>) {
        emit(ClinicLoadedSuccess(clinic: result.data));
      } else if (result is ResponseError<ClinicModel>) {
        ShowToast.showToastError(
          message: result.message ?? 'Failed to fetch clinic details',
        );
        emit(
          ClinicError(
            error: result.message ?? 'Failed to fetch clinic details',
          ),
        );
      }
    } catch (e) {
      if (!_isClosed) {
        emit(ClinicError(error: 'An unexpected error occurred'));
      }
    }
  }

}
