import 'package:bloc/bloc.dart';

import 'complaint_state.dart';

class ComplaintCubit extends Cubit<ComplaintState> {
  ComplaintCubit() : super(ComplaintState());

  void selectClinic(String? clinic) {
    emit(state.copyWith(selectedClinic: clinic, clinicText: clinic));
  }

  void selectDoctor(String? doctor) {
    emit(state.copyWith(selectedDoctor: doctor, doctorText: doctor));
  }

  void updateComplaintContent(String content) {
    emit(state.copyWith(complaintContent: content));
  }

  void submitComplaint() {
    // print('العيادة: ${state.selectedClinic}');
    // print('الطبيب: ${state.selectedDoctor}');
    // print('محتوى الشكوى: ${state.complaintContent}');
  }
}
