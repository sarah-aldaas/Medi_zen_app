import 'package:bloc/bloc.dart';

import 'doctor.dart';
import 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  DoctorCubit() : super(DoctorInitial());

  void loadDoctors() async {
    emit(DoctorLoading());
    try {
      List<Doctor> doctors = [
        Doctor(
          name: 'Dr. Ahmed Ali',
          specialization: 'Orthodontics',
          imagePath: 'assets/images/clinic/photo_doctor3.png',
        ),
        Doctor(
          name: 'Dr. Fatima Mohamed',
          specialization: 'Maxillofacial Surgery',
          imagePath: 'assets/images/clinic/photo_doctor3.png',
        ),
        Doctor(
          name: 'Dr. Omar Said',
          specialization: 'Pediatric Dentistry',
          imagePath: 'assets/images/clinic/photo_doctor3.png',
        ),
      ];

      emit(DoctorLoaded(doctors));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }
}
