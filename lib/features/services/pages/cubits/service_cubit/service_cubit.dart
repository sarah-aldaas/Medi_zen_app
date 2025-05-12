import 'package:bloc/bloc.dart';
import 'package:medizen_app/features/services/data/datasources/services_remote_datasoources.dart';
import 'package:medizen_app/features/services/data/model/health_care_service_eligibility_codes_model.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServicesRemoteDataSource remoteDataSource;

  ServiceCubit({required this.remoteDataSource}) : super(ServiceInitial());

  Future<void> getAllServiceHealthCare() async {
    emit(ServiceHealthCareLoading());
    final result = await remoteDataSource.getAllHealthCareServices();
    if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
      emit(ServiceHealthCareSuccess(paginatedResponse: result.data));
    } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
      emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service'));
    }
  }

  Future<void> getAllServiceHealthCareEligibility() async {
    emit(ServiceHealthCareEligibilityLoading());
    final result = await remoteDataSource.getAllHealthCareServiceEligibilityCodes();
    if (result is Success<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
      emit(ServiceHealthCareEligibilitySuccess(paginatedResponse: result.data));
    } else if (result is ResponseError<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
      emit(ServiceHealthCareEligibilityError(error: result.message ?? 'Failed to fetch health care service eligibility codes'));
    }
  }

  Future<HealthCareServiceModel?> getSpecificServiceHealthCare({required String id}) async {
    emit(ServiceHealthCareLoading());
    final result = await remoteDataSource.getSpecificHealthCareServices(id: id);
    if (result is Success<HealthCareServiceModel>) {
      return result.data;
    } else if (result is ResponseError<HealthCareServiceModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service details');
      emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service details'));
      return null;
    } else {
      return null;
    }
  }

  Future<HealthCareServiceEligibilityCodesModel?> getSpecificServiceHealthCareEligibilityCodes({required String id}) async {
    emit(ServiceHealthCareEligibilityLoading());
    final result = await remoteDataSource.getSpecificHealthCareServiceEligibilityCodes(id: id);
    if (result is Success<HealthCareServiceEligibilityCodesModel>) {
      return result.data;
    } else if (result is ResponseError<HealthCareServiceEligibilityCodesModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service eligibility codes details');
      emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service eligibility codes details'));
      return null;
    } else {
      return null;
    }
  }

}
