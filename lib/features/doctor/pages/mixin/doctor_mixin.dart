import '../../../../base/constant/app_images.dart';
import '../../model/docotr_model.dart';

mixin DoctorMixin {
  final List<DoctorModel> allDoctors = [
    DoctorModel(
      imageUrl: AppAssetImages.photoDoctor1,
      // Replace with your image URL
      name: 'Dr. Randy Wigham',
      specialization: 'Cardiologists',
      hospital: 'The Valley Hospital',
      rating: 4.8,
      reviews: 4279,
    ),
    DoctorModel(
      imageUrl: AppAssetImages.photoDoctor2,
      // Replace with your image URL
      name: 'Dr. Jenny Watson',
      specialization: 'Immunologists',
      hospital: 'Christ Hospital',
      rating: 4.4,
      reviews: 4942,
    ),
    DoctorModel(
      imageUrl: AppAssetImages.photoDoctor3,
      // Replace with your image URL
      name: 'Dr. Raul Zirkind',
      specialization: 'Neurologists',
      hospital: 'Franklin Hospital',
      rating: 4.8,
      reviews: 6362,
    ),
    DoctorModel(
      imageUrl: AppAssetImages.photoDoctor4,
      // Replace with your image URL
      name: 'Dr. Elijah Baranick',
      specialization: 'Allergists',
      hospital: 'JFK Medical Center',
      rating: 4.6,
      reviews: 3837,
    ),
    DoctorModel(
      imageUrl: AppAssetImages.photoDoctor5,
      // Replace with your image URL
      name: 'Dr. Stephen Shute',
      specialization: 'Dermatologists',
      hospital: 'St. Mary\'s Hospital',
      rating: 4.2,
      reviews: 2890,
    ),
  ];

  final List<DoctorModel> topDoctors = [
    DoctorModel(imageUrl: AppAssetImages.photoDoctor1, name: 'Dr. Ayham Alrefay', specialization: 'Cardiologist', rating: 4.7, location: 'Damascus'),
    DoctorModel(imageUrl: AppAssetImages.photoDoctor2, name: 'Dr. Ayham Alrefay', specialization: 'Cardiologist', rating: 4.7, location: 'Damascus'),
    DoctorModel(imageUrl: AppAssetImages.photoDoctor3, name: 'Dr. Ayham Alrefay', specialization: 'Cardiologist', rating: 4.7, location: 'Damascus'),
    DoctorModel(imageUrl: AppAssetImages.photoDoctor1, name: 'Dr. Ayham Alrefay', specialization: 'Cardiologist', rating: 4.7, location: 'Damascus'),
  ];
}
