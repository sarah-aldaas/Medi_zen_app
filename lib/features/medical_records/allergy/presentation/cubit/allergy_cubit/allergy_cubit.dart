import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/medical_records/allergy/data/data_source/allergy_remote_datasource.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_model.dart';
import 'package:meta/meta.dart';

import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';

part 'allergy_state.dart';

class AllergyCubit extends Cubit<AllergyState> {
  final AllergyRemoteDataSource remoteDataSource;

  AllergyCubit({required this.remoteDataSource}) : super(AllergyInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<AllergyModel> _allAllergies = [];

  Future<void> getAllMyAllergies({Map<String, dynamic>? filters, bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAllergies = [];
      emit(AllergyLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllMyAllergies(filters: _currentFilters, page: _currentPage, perPage: 5);

    if (result is Success<PaginatedResponse<AllergyModel>>) {
      try {
        _allAllergies.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          AllergiesSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<AllergyModel>(
              paginatedData: PaginatedData<AllergyModel>(items: _allAllergies),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(AllergyError(error: result.data.msg ?? 'Failed to fetch allergies'));
      }
    } else if (result is ResponseError<PaginatedResponse<AllergyModel>>) {
      emit(AllergyError(error: result.message ?? 'Failed to fetch allergies'));
    }
  }

  int _currentPageOfAppointment = 1;
  bool _hasMoreOfAppointment = true;
  Map<String, dynamic> _currentFiltersOfAppointment = {};
  List<AllergyModel> _allAllergiesOfAppointment = [];

  Future<void> getAllMyAllergiesOfAppointment({Map<String, dynamic>? filters, bool loadMore = false, required String appointmentId}) async {
    if (!loadMore) {
      _currentPageOfAppointment = 1;
      _hasMoreOfAppointment = true;
      _allAllergiesOfAppointment = [];
      emit(AllergyLoading());
    } else if (!_hasMoreOfAppointment) {
      return;
    }

    if (filters != null) {
      _currentFiltersOfAppointment = filters;
    }

    final result = await remoteDataSource.getAllMyAllergiesOfAppointment(
      filters: _currentFiltersOfAppointment,
      page: _currentPageOfAppointment,
      perPage: 5,
      appointmentId: appointmentId,
    );

    if (result is Success<PaginatedResponse<AllergyModel>>) {
      try {
        _allAllergiesOfAppointment.addAll(result.data.paginatedData!.items);
        _hasMoreOfAppointment = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPageOfAppointment++;

        emit(
          AllergiesOfAppointmentSuccess(
            hasMore: _hasMoreOfAppointment,
            paginatedResponse: PaginatedResponse<AllergyModel>(
              paginatedData: PaginatedData<AllergyModel>(items: _allAllergiesOfAppointment),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(AllergyError(error: result.data.msg ?? 'Failed to fetch allergies'));
      }
    } else if (result is ResponseError<PaginatedResponse<AllergyModel>>) {
      emit(AllergyError(error: result.message ?? 'Failed to fetch allergies'));
    }
  }

  Future<void> getSpecificAllergy({required String allergyId}) async {
    emit(AllergyLoading(isLoadMore: false));
    final result = await remoteDataSource.getSpecificAllergy(allergyId: allergyId);
    if (result is Success<AllergyModel>) {
      emit(AllergyDetailsSuccess(allergyModel: result.data));
    } else if (result is ResponseError<AllergyModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch allergy details');
      emit(AllergyError(error: result.message ?? 'Failed to fetch allergy details'));
    }
  }
}
