import 'package:bloc/bloc.dart';

import '../../base/constant/app_images.dart';
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
          imagePath: AppAssetImages.photoDoctor1,
        ),
        Doctor(
          name: 'Dr. Fatima Mohamed',
          specialization: 'Maxillofacial Surgery',
          imagePath: AppAssetImages.photoDoctor2,
        ),
        Doctor(
          name: 'Dr. Omar Said',
          specialization: 'Pediatric Dentistry',
          imagePath: AppAssetImages.photoDoctor3,
        ),
      ];

      emit(DoctorLoaded(doctors));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }
}
