part of 'service_cubit.dart';

@immutable
sealed class ServiceState {}

final class ServiceInitial extends ServiceState {}


class ServiceHealthCareLoading extends ServiceState {}

class ServiceHealthCareSuccess extends ServiceState {
  final PaginatedResponse<HealthCareServiceModel> paginatedResponse;


  ServiceHealthCareSuccess({
    required this.paginatedResponse,
  });
}
class ServiceHealthCareError extends ServiceState {
  final String error;

  ServiceHealthCareError({required this.error});
}



class ServiceHealthCareEligibilityLoading extends ServiceState {}

class ServiceHealthCareEligibilitySuccess extends ServiceState {
  final PaginatedResponse<HealthCareServiceEligibilityCodesModel> paginatedResponse;


  ServiceHealthCareEligibilitySuccess({
    required this.paginatedResponse,
  });
}
class ServiceHealthCareEligibilityError extends ServiceState {
  final String error;

  ServiceHealthCareEligibilityError({required this.error});
}