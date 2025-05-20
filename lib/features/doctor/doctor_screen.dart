// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medizen_app/features/doctor/pages/details_doctor.dart';
//
// import '../../base/constant/app_images.dart';
// import '../../base/theme/app_color.dart';
// import '../../base/theme/app_style.dart';
// import 'doctor.dart';
// import 'doctor_card.dart';
// import 'doctor_cubit.dart';
// import 'doctor_state.dart';
//
// class Doctorscreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DoctorCubit()..loadDoctors(),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(
//               Icons.arrow_back_ios_new,
//               color: AppColors.primaryColor,
//             ),
//           ),
//           title: Text(
//             'All Doctors',
//             style: TextStyle(
//               fontSize: 22,
//               color: AppColors.primaryColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: AppColors.backgroundColor,
//           foregroundColor: AppColors.secondaryColor,
//           elevation: 0,
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(AppAssetImages.clinic1),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Text('011 611 22 33', style: AppStyles.bodyText),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: BlocBuilder<DoctorCubit, DoctorState>(
//                 builder: (context, state) {
//                   if (state is DoctorLoading) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (state is DoctorLoaded) {
//                     return _buildDoctorList(context, state.doctors);
//                   } else if (state is DoctorError) {
//                     return Center(child: Text('Error: ${state.errorMessage}'));
//                   } else {
//                     return Container();
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDoctorList(BuildContext context, List<Doctor> doctors) {
//     return ListView.builder(
//       itemCount: doctors.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (context) => DoctorDetailsPage(
//                       // doctor: doctors[index],
//                     ),
//               ),
//             );
//           },
//           child: DoctorCard(
//             doctorName: doctors[index].name,
//             specialization: doctors[index].specialization,
//             imagePath: doctors[index].imagePath,
//           ),
//         );
//       },
//     );
//   }
// }
