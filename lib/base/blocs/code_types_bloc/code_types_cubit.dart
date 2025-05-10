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
    _initializeData();
  }

  // Initialize by fetching code types and specific codes
  Future<void> _initializeData() async {
    final cachedCodeTypes = await getCachedCodeTypes();
    if (cachedCodeTypes == null || cachedCodeTypes.isEmpty) {
      await fetchCodeTypes();
    } else {
      emit(CodeTypesSuccess(codeTypes: cachedCodeTypes, codes: []));
       await _fetchInitialCodes();
    }
  }

  // Fetch all code types and save to storage
  Future<void> fetchCodeTypes() async {
    emit(CodeTypesLoading());
    try {
      final result = await remoteDataSource.getCodeTypes();
      if (result is Success<CodeTypesResponseModel>) {
        final codeTypes = result.data.codeTypes;
        final codeTypesJson = jsonEncode(codeTypes.map((e) => e.toJson()).toList());
        serviceLocator<StorageService>().saveToDisk(StorageKey.codeTypesKey, codeTypesJson);
        emit(CodeTypesSuccess(codeTypes: codeTypes, codes: []));
        await _fetchInitialCodes();
      } else if (result is ResponseError<CodeTypesResponseModel>) {
        emit(CodeTypesError(error: result.message ?? 'Failed to fetch code types'));
      }
    } on ServerException catch (e) {
      emit(CodeTypesError(error: e.message));
    } catch (e) {
      emit(CodeTypesError(error: 'Unexpected error: ${e.toString()}'));
    }
  }

  // Fetch initial codes for gender and marital_status
  Future<void> _fetchInitialCodes() async {
    await getGenderCodes(); // Fetch gender codes initially
    await getMaritalStatusCodes(); // Fetch marital status codes initially
  }

  // Fetch and return gender codes
  Future<List<CodeModel>> getGenderCodes() async {
    final codeTypes = state is CodeTypesSuccess ? (state as CodeTypesSuccess).codeTypes : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(); // Ensure code types are fetched if not available
      return getGenderCodes(); // Recursive call after fetching
    }

    final genderCodeType = codeTypes.firstWhere((ct) => ct.name == 'gender', orElse: () => throw Exception('Gender code type not found'));
    final currentCodes = (state is CodeTypesSuccess ? (state as CodeTypesSuccess).codes : null) ?? [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == genderCodeType.id)) {
      await fetchCodes(codeTypeId: genderCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes?.where((code) => code.codeTypeModel!.id == genderCodeType.id).toList() ?? [];
    }
    return [];
  }

  // Fetch and return telecom type codes
  Future<List<CodeModel>> getTelecomTypeCodes() async {
    final codeTypes = state is CodeTypesSuccess ? (state as CodeTypesSuccess).codeTypes : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(); // Ensure code types are fetched if not available
      return getTelecomTypeCodes(); // Recursive call after fetching
    }

    final telecomTypeCodeType = codeTypes.firstWhere((ct) => ct.name == 'telecom_type', orElse: () => throw Exception('Telecom type code type not found'));
    final currentCodes = (state is CodeTypesSuccess ? (state as CodeTypesSuccess).codes : null) ?? [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == telecomTypeCodeType.id)) {
      await fetchCodes(codeTypeId: telecomTypeCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes?.where((code) => code.codeTypeModel!.id == telecomTypeCodeType.id).toList() ?? [];
    }
    return [];
  }


  // Fetch and return telecom use codes
  Future<List<CodeModel>> getTelecomUseCodes() async {
    final codeTypes = state is CodeTypesSuccess ? (state as CodeTypesSuccess).codeTypes : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(); // Ensure code types are fetched if not available
      return getTelecomUseCodes(); // Recursive call after fetching
    }

    final telecomUseCodeType = codeTypes.firstWhere((ct) => ct.name == 'telecom_use', orElse: () => throw Exception('Telecom use code type not found'));
    final currentCodes = (state is CodeTypesSuccess ? (state as CodeTypesSuccess).codes : null) ?? [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == telecomUseCodeType.id)) {
      await fetchCodes(codeTypeId: telecomUseCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes?.where((code) => code.codeTypeModel!.id == telecomUseCodeType.id).toList() ?? [];
    }
    return [];
  }


  // Fetch and return marital status codes
  Future<List<CodeModel>> getMaritalStatusCodes() async {
    final codeTypes = state is CodeTypesSuccess ? (state as CodeTypesSuccess).codeTypes : await getCachedCodeTypes();
    if (codeTypes == null) {
      await fetchCodeTypes(); // Ensure code types are fetched if not available
      return getMaritalStatusCodes(); // Recursive call after fetching
    }

    final maritalStatusCodeType = codeTypes.firstWhere(
          (ct) => ct.name == 'marital_status',
      orElse: () => throw Exception('Marital status code type not found'),
    );
    final currentCodes = (state is CodeTypesSuccess ? (state as CodeTypesSuccess).codes : null) ?? [];

    if (!currentCodes.any((code) => code.codeTypeModel!.id == maritalStatusCodeType.id)) {
      await fetchCodes(codeTypeId: maritalStatusCodeType.id, codeTypes: codeTypes);
    }

    final updatedState = state;
    if (updatedState is CodeTypesSuccess) {
      return updatedState.codes?.where((code) => code.codeTypeModel!.id == maritalStatusCodeType.id).toList() ?? [];
    }
    return [];
  }

  Future<void> fetchCodes({required int codeTypeId, required List<CodeTypeModel> codeTypes}) async {
    emit(CodesLoading());
    try {
      final result = await remoteDataSource.getCodes(codeTypeId: codeTypeId);
      if (result is Success<CodesResponseModel>) {
        final currentState = state;
        final existingCodes = (currentState is CodeTypesSuccess ? currentState.codes : null) ?? [];
        emit(CodeTypesSuccess(
          codeTypes: codeTypes,
          codes: [...existingCodes, ...result.data.codes],
        ));
      } else if (result is ResponseError<CodesResponseModel>) {
        emit(CodesError(error: result.message ?? 'Failed to fetch codes'));
      }
    } on ServerException catch (e) {
      emit(CodesError(error: e.message));
    } catch (e) {
      emit(CodesError(error: 'Unexpected error: ${e.toString()}'));
    }
  }

  // Retrieve code types from storage
  Future<List<CodeTypeModel>?> getCachedCodeTypes() async {
    try {
      final jsonString = serviceLocator<StorageService>().getFromDisk(StorageKey.codeTypesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => CodeTypeModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}