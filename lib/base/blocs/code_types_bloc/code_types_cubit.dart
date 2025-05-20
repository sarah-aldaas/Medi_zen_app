import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:medizen_app/base/constant/storage_key.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/storage/storage_service.dart';
import 'package:meta/meta.dart';

import '../../../../../base/error/exception.dart';
import '../../../../../base/services/network/resource.dart';
import '../../data/data_sources/remote_data_sources.dart';
import '../../data/models/code_type_model.dart';
import '../../data/models/respons_model.dart';

part 'code_types_state.dart';

class CodeTypesCubit extends Cubit<CodeTypesState> {
  final RemoteDataSourcePublic remoteDataSource;

  CodeTypesCubit({required this.remoteDataSource}) : super(CodeTypesInitial()) {
    // _initializeData();
  }

  Future<void> _initializeData() async {
    final cachedCodeTypes = await getCachedCodeTypes();
    if (cachedCodeTypes == null || cachedCodeTypes.isEmpty) {
      await fetchCodeTypes();
    } else {
      if (!isClosed) {
        emit(CodeTypesSuccess(codeTypes: cachedCodeTypes, codes: []));
      }
      await _fetchInitialCodes();
    }
  }

  Future<void> fetchCodeTypes() async {
    if (isClosed) return;
    emit(CodeTypesLoading());
    try {
      final result = await remoteDataSource.getCodeTypes();
      if (result is Success<CodeTypesResponseModel>) {
        final codeTypes = result.data.codeTypes;
     final codeTypesJson = jsonEncode(
          codeTypes.map((e) => e.toJson()).toList(),
        );
        serviceLocator<StorageService>().saveToDisk(
          StorageKey.codeTypesKey,
          codeTypesJson,
        );
        if (!isClosed) {
          emit(CodeTypesSuccess(codeTypes: codeTypes, codes: []));
        }
        await _fetchInitialCodes();
      } else if (result is ResponseError<CodeTypesResponseModel>) {
        if (!isClosed) {
          emit(
            CodeTypesError(
              error: result.message ?? 'Failed to fetch code types',
            ),
          );
        }
      }
    } on ServerException catch (e) {
      if (!isClosed) {
        emit(CodeTypesError(error: e.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CodeTypesError(error: 'Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<void> _fetchInitialCodes() async {
    await getGenderCodes();
    await getMaritalStatusCodes();
  }

  Future<List<CodeModel>> getGenderCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getGenderCodes();
    }

    final genderCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'gender',
      orElse: () => throw Exception('Gender code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == genderCodeType.id,
    )) {
      await fetchCodes(codeTypeId: genderCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == genderCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getTelecomTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getTelecomTypeCodes();
    }

    final telecomTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'telecom_type',
      orElse: () => throw Exception('Telecom type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == telecomTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: telecomTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == telecomTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getTelecomUseCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getTelecomUseCodes();
    }

    final telecomUseCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'telecom_use',
      orElse: () => throw Exception('Telecom use code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == telecomUseCodeType.id,
    )) {
      await fetchCodes(codeTypeId: telecomUseCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel!.id == telecomUseCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getMaritalStatusCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getMaritalStatusCodes();
    }

    final maritalStatusCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'marital_status',
      orElse: () => throw Exception('Marital status code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == maritalStatusCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: maritalStatusCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == maritalStatusCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAppointmentTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAppointmentTypeCodes();
    }

    final appointmentTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'type_appointment',
      orElse: () => throw Exception('Appointment type code type not found'),
    );
    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel!.id == appointmentTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: appointmentTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel!.id == appointmentTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<void> fetchCodes({
    required int codeTypeId,
    required List<CodeTypeModel> codeTypes,
  }) async {
    if (isClosed) return;
    emit(CodesLoading());
    try {
      final result = await remoteDataSource.getCodes(codeTypeId: codeTypeId);
      if (result is Success<CodesResponseModel>) {
        final currentState = state;
        final existingCodes =
            (currentState is CodeTypesSuccess ? currentState.codes : null) ??
            [];
        if (!isClosed) {
          emit(
            CodeTypesSuccess(
              codeTypes: codeTypes,
              codes: [...existingCodes, ...result.data.codes],
            ),
          );
        }
      } else if (result is ResponseError<CodesResponseModel>) {
        if (!isClosed) {
          emit(CodesError(error: result.message ?? 'Failed to fetch codes'));
        }
      }
    } on ServerException catch (e) {
      if (!isClosed) {
        emit(CodesError(error: e.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CodesError(error: 'Unexpected error: ${e.toString()}'));
      }
    }
  }

  Future<List<CodeTypeModel>?> getCachedCodeTypes() async {
    try {
      final jsonString = serviceLocator<StorageService>().getFromDisk(
        StorageKey.codeTypesKey,
      );
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => CodeTypeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Add these new methods to specifically fetch address types and uses
  Future<List<CodeModel>> getAddressTypeCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAddressTypeCodes();
    }

    final addressTypeCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'address_type',
      orElse: () => throw Exception('Address type code type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == addressTypeCodeType.id,
    )) {
      await fetchCodes(
        codeTypeId: addressTypeCodeType.id,
        codeTypes: codeTypes,
      );
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where(
                (code) => code.codeTypeModel?.id == addressTypeCodeType.id,
              )
              .toList() ??
          [];
    }
    return [];
  }

  Future<List<CodeModel>> getAddressUseCodes() async {
    final codeTypes =
        state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codeTypes
            : await getCachedCodeTypes();

    if (codeTypes == null) {
      await fetchCodeTypes();
      return getAddressUseCodes();
    }

    final addressUseCodeType = codeTypes.firstWhere(
      (ct) => ct.name == 'address_use',
      orElse: () => throw Exception('Address use code type not found'),
    );

    final currentCodes =
        (state is CodeTypesSuccess
            ? (state as CodeTypesSuccess).codes
            : null) ??
        [];

    if (!currentCodes.any(
      (code) => code.codeTypeModel?.id == addressUseCodeType.id,
    )) {
      await fetchCodes(codeTypeId: addressUseCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes
              ?.where((code) => code.codeTypeModel?.id == addressUseCodeType.id)
              .toList() ??
          [];
    }
    return [];
  }
}
