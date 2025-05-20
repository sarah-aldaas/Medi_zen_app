import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/services/data/datasources/services_remote_datasoources.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServicesRemoteDataSource remoteDataSource;
  int currentServicePage = 1;

  // int currentEligibilityPage = 1;
  bool hasMoreServices = true;

  // bool hasMoreEligibility = true;
  bool isLoadingServices = false;

  // bool isLoadingEligibility = false;
  List<HealthCareServiceModel> allServices = [];

  // List<HealthCareServiceEligibilityCodesModel> allEligibilityCodes = [];

  ServiceCubit({required this.remoteDataSource}) : super(ServiceInitial());

  Future<void> getAllServiceHealthCare({bool loadMore = false}) async {
    if (isLoadingServices || (!loadMore && allServices.isNotEmpty)) return;
    isLoadingServices = true;

    if (!loadMore) {
      currentServicePage = 1;
      hasMoreServices = true;
      allServices.clear();
      emit(ServiceHealthCareLoading());
    }

    try {
      final result = await remoteDataSource.getAllHealthCareServices(
        page: currentServicePage,
        perPage: 10, // Set your desired page size
      );

      if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
        final newServices = result.data.paginatedData?.items ?? [];
        allServices.addAll(newServices);

        // Update pagination info
        final totalPages = result.data.meta?.lastPage ?? 1;
        hasMoreServices = currentServicePage < totalPages;

        // Only increment page if we're loading more
        if (loadMore) {
          currentServicePage++;
        } else {
          // For initial load, set to page 2 since we already loaded page 1
          currentServicePage = 2;
        }

        emit(ServiceHealthCareSuccess(paginatedResponse: result.data, allServices: allServices, hasMore: hasMoreServices));
      } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
        emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service'));
      }
    } finally {
      isLoadingServices = false;
    }
  }

  Future<void> getSpecificServiceHealthCare({required String id}) async {
    emit(ServiceHealthCareLoading());
    try {
      final result = await remoteDataSource.getSpecificHealthCareServices(id: id);
      if (result is Success<HealthCareServiceModel>) {
        emit(ServiceHealthCareModelSuccess(healthCareServiceModel: result.data));
      } else if (result is ResponseError<HealthCareServiceModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service details');
        emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ServiceHealthCareError(error: e.toString()));
    }
  }

// Future<void> getAllServiceHealthCareEligibility({bool loadMore = false}) async {
//   if (isLoadingEligibility || (!loadMore && allEligibilityCodes.isNotEmpty)) return;
//   isLoadingEligibility = true;
//
//   if (!loadMore) {
//     currentEligibilityPage = 1;
//     hasMoreEligibility = true;
//     allEligibilityCodes.clear();
//     emit(ServiceHealthCareEligibilityLoading());
//   }
//
//   try {
//     final result = await remoteDataSource.getAllHealthCareServiceEligibilityCodes(
//       page: currentEligibilityPage,
//       perPage: 10, // Set your desired page size
//     );
//
//     if (result is Success<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
//       final newEligibilityCodes = result.data.paginatedData?.items ?? [];
//       allEligibilityCodes.addAll(newEligibilityCodes);
//
//       // Update pagination info
//       final totalPages = result.data.meta?.lastPage ?? 1;
//       hasMoreEligibility = currentEligibilityPage < totalPages;
//
//       // Only increment page if we're loading more
//       if (loadMore) {
//         currentEligibilityPage++;
//       } else {
//         // For initial load, set to page 2 since we already loaded page 1
//         currentEligibilityPage = 2;
//       }
//
//       emit(ServiceHealthCareEligibilitySuccess(
//         paginatedResponse: result.data,
//         allEligibilityCodes: allEligibilityCodes,
//         hasMore: hasMoreEligibility,
//       ));
//     } else if (result is ResponseError<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
//       emit(ServiceHealthCareEligibilityError(error: result.message ?? 'Failed to fetch health care service eligibility codes'));
//     }
//   } finally {
//     isLoadingEligibility = false;
//   }
// }
  // Future<HealthCareServiceEligibilityCodesModel?> getSpecificServiceHealthCareEligibilityCodes({required String id}) async {
  //   emit(ServiceHealthCareEligibilityLoading());
  //   final result = await remoteDataSource.getSpecificHealthCareServiceEligibilityCodes(id: id);
  //   if (result is Success<HealthCareServiceEligibilityCodesModel>) {
  //     return result.data;
  //   } else if (result is ResponseError<HealthCareServiceEligibilityCodesModel>) {
  //     ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service eligibility codes details');
  //     emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service eligibility codes details'));
  //     return null;
  //   } else {
  //     return null;
  //   }
  // }
}
