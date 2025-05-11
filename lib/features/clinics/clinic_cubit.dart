import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../clinic_model.dart';

class ClinicsCubit extends Cubit<List<Clinic>> {
  final Dio dio;

  ClinicsCubit(this.dio) : super([]);

  Future<void> fetchClinics() async {
    try {
      final response = await dio.get(
        'https://medizen.online/api/clinics?page=1',
      );
      if (response.data['status']) {
        List<Clinic> clinics =
            (response.data['clinics']['data'] as List)
                .map((clinic) => Clinic.fromJson(clinic))
                .toList();
        emit(clinics);
      } else {
        emit([]);
      }
    } catch (e) {
      emit([]);
    }
  }
}
