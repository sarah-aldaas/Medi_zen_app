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
