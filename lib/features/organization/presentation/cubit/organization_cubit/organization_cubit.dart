import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import 'package:medizen_app/features/organization/data/models/qualification_organization_model.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/data_source/organization_remote_datasource.dart';
import '../../../data/models/organization_model.dart';

part 'organization_state.dart';

class OrganizationCubit extends Cubit<OrganizationState> {
  final OrganizationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrganizationCubit({required this.remoteDataSource, required this.networkInfo}) : super(OrganizationInitial());

  Future<void> getOrganizationDetails({required BuildContext context}) async {
    emit(OrganizationLoading());

    final result = await remoteDataSource.getDetailsOrganization();
    if (result is Success<OrganizationModel>) {
      emit(OrganizationDetailsSuccess(organization: result.data));
    } else if (result is ResponseError<OrganizationModel>) {
      emit(OrganizationError(error: result.message ?? 'Failed to fetch Organization details'));
    }
  }

  int _currentPage = 1;
  bool _hasMore = true;
  List<QualificationsOrganizationModel> _allQualification = [];

  Future<void> getAllQualification({
    bool loadMore = false,
    required BuildContext context,
  }) async {

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allQualification = [];
      emit(QualificationOrganizationLoading());
    } else if (!_hasMore) {
      return;
    }


    final result = await remoteDataSource.getQualificationOrganization(
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<QualificationsOrganizationModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
         context.pushReplacementNamed(AppRouter.welcomeScreen.name);
      }
      try {
        _allQualification.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          QualificationOrganizationSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<QualificationsOrganizationModel>(
              paginatedData: PaginatedData<QualificationsOrganizationModel>(items: _allQualification),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(QualificationOrganizationError(error: result.data.msg ?? 'Failed to fetch qualification'));
      }
    } else if (result is ResponseError<PaginatedResponse<QualificationsOrganizationModel>>) {
      emit(QualificationOrganizationError(error: result.message ?? 'Failed to fetch qualification'));
    }
  }
}
