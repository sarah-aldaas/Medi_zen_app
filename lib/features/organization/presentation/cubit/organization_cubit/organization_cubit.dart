import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/organization_remote_datasource.dart';
import '../../../data/models/organization_model.dart';

part 'organization_state.dart';

class OrganizationCubit extends Cubit<OrganizationState> {
  final OrganizationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrganizationCubit({required this.remoteDataSource, required this.networkInfo}) : super(OrganizationInitial());

  Future<void> getOrganizationDetails({required BuildContext context}) async {
    emit(OrganizationLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(OrganizationError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getDetailsOrganization();
    if (result is Success<OrganizationModel>) {
      emit(OrganizationDetailsSuccess(organization: result.data));
    } else if (result is ResponseError<OrganizationModel>) {
      emit(OrganizationError(error: result.message ?? 'Failed to fetch Organization details'));
    }
  }
}
