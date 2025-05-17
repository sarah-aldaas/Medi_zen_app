// import 'package:flutter_bloc/flutter_bloc.dart';
//
//
// import 'clinic_state.dart';
//
// class ClinicsCubit extends Cubit<ClinicsState> {
//  // final ClinicsService _clinicsService;
//
//   ClinicsCubit(this._clinicsService) : super(ClinicsInitial());
//
//   Future<void> fetchClinics() async {
//     emit(ClinicsLoading());
//     try {
//       final clinicsResponse = await _clinicsService.getClinics();
//       emit(ClinicsLoaded(clinics: clinicsResponse.clinics));
//     } catch (error) {
//       emit(ClinicsError(error: error.toString()));
//     }
//   }
// }
