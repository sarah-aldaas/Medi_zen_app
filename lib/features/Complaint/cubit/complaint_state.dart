class ComplaintState {
  final String? selectedClinic;
  final String? selectedDoctor;
  final String? clinicText;
  final String? doctorText;
  final String complaintContent;

  ComplaintState({
    this.selectedClinic,
    this.selectedDoctor,
    this.clinicText,
    this.doctorText,
    this.complaintContent = '',
  });

  ComplaintState copyWith({
    String? selectedClinic,
    String? selectedDoctor,
    String? clinicText,
    String? doctorText,
    String? complaintContent,
  }) {
    return ComplaintState(
      selectedClinic: selectedClinic ?? this.selectedClinic,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      clinicText: clinicText ?? this.clinicText,
      doctorText: doctorText ?? this.doctorText,
      complaintContent: complaintContent ?? this.complaintContent,
    );
  }
}