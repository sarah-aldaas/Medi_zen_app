part of 'organization_cubit.dart';

sealed class OrganizationState {
  const OrganizationState();
}

final class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationDetailsSuccess extends OrganizationState {
  final OrganizationModel organization;

  const OrganizationDetailsSuccess({required this.organization});
}

class OrganizationError extends OrganizationState {
  final String error;

  const OrganizationError({required this.error});
}



class QualificationOrganizationLoading extends OrganizationState {
  final bool isLoadMore;

  QualificationOrganizationLoading({this.isLoadMore = false});
}

class QualificationOrganizationSuccess extends OrganizationState {
  final bool hasMore;
  final PaginatedResponse<QualificationsOrganizationModel> paginatedResponse;

  QualificationOrganizationSuccess({required this.paginatedResponse, required this.hasMore});

}


class QualificationOrganizationError extends OrganizationState {
  final String error;

  const QualificationOrganizationError({required this.error});
}
