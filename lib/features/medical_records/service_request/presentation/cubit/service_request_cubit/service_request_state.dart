part of 'service_request_cubit.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();
}

class ServiceRequestInitial extends ServiceRequestState {
  @override
  List<Object> get props => [];
}

class ServiceRequestLoading extends ServiceRequestState {
  final bool isLoadMore;
  final bool isDetailsLoading;

  const ServiceRequestLoading({
    this.isLoadMore = false,
    this.isDetailsLoading = false,
  });

  @override
  List<Object> get props => [isLoadMore, isDetailsLoading];
}

class ServiceRequestLoaded extends ServiceRequestState {
  final PaginatedResponse<ServiceRequestModel>? paginatedResponse;
  final ServiceRequestModel? serviceRequestDetails;
  final bool hasMore;

  const ServiceRequestLoaded({
    this.paginatedResponse,
    this.serviceRequestDetails,
    required this.hasMore,
  });

  @override
  List<Object> get props => [
    paginatedResponse ?? Object(),
    serviceRequestDetails ?? Object(),
    hasMore,
  ];
}

class ServiceRequestError extends ServiceRequestState {
  final String message;

  const ServiceRequestError(this.message);

  @override
  List<Object> get props => [message];
}