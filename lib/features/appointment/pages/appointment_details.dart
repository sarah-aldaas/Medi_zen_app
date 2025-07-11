import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/appointment/pages/widgets/cancel_appointment_dialog.dart';
import 'package:medizen_app/features/appointment/pages/widgets/update_appointment_page.dart';
import 'package:medizen_app/features/complains/presentation/widgets/create_complain_page.dart';
import 'package:medizen_app/features/doctor/pages/details_doctor.dart';
import 'package:medizen_app/features/medical_records/medical_record_of_appointment_page.dart';

import '../../../base/theme/app_color.dart';
import '../../../base/widgets/flexible_image.dart';
import '../data/models/appointment_model.dart';
import 'cubit/appointment_cubit/appointment_cubit.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsPage({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  @override
  void initState() {
    super.initState();

    context.read<AppointmentCubit>().getDetailsAppointment(
      context: context,
      id: widget.appointmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Text(
          "appointmentDetails.title".tr(context),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AppointmentDetailsSuccess) {
            return _buildAppointmentDetails(state.appointmentModel);
          } else if (state is AppointmentLoading) {
            return const Center(child: LoadingPage());
          } else {
            return const Center(
              child: Text('Failed to load appointment details'),
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(AppointmentModel appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorInfo(appointment),
          const SizedBox(height: 25),
          _buildAppointmentInfo(appointment),
          const SizedBox(height: 30),
          _buildPatientInfo(appointment),
          const SizedBox(height: 30),
          _buildAppointmentInformation(appointment),
          const SizedBox(height: 30),
          _buildPackageInfo(appointment),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MedicalRecordOfAppointmentPage(
                        appointmentId: appointment.id!,
                      ),
                ),
              );
            },
            child: Card(
              child: Container(
                width: context.width,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'appointmentDetails.medicalRecord'.tr(context),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CreateComplainPage(appointmentId: appointment.id!),
                ),
              );
            },
            child: Card(
              child: Container(
                width: context.width,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'appointmentDetails.submitComplaint'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (appointment.status!.code == 'booked_appointment')
            _buildActionButtons(context, appointment),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.scheduledAppointment".tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat(
            'EEEE, MMMM d, y',
          ).format(DateTime.parse(appointment.startDate!)),
        ),
        const SizedBox(height: 5),
        Text(
          '${DateFormat('HH:mm').format(DateTime.parse(appointment.startDate!))} - '
          '${DateFormat('HH:mm').format(DateTime.parse(appointment.endDate!))} '
          '(${appointment.minutesDuration} minutes)',
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(AppointmentModel appointment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DoctorDetailsPage(doctorModel: appointment.doctor!),
          ),
        ).then((value) {
          context.read<AppointmentCubit>().getDetailsAppointment(
            context: context,
            id: widget.appointmentId,
          );
        });
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40,
            child: FlexibleImage(
              imageUrl: appointment.doctor!.avatar,
              assetPath: AppAssetImages.photoDoctor1,
            ),
          ),

          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${appointment.doctor!.prefix} ${appointment.doctor!.fName} ${appointment.doctor!.lName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: context.width / 1.5,
                child: Text(appointment.doctor!.text ?? 'General Practitioner'),
              ),
              Text(appointment.doctor!.address),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.patientInformation".tr(context),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              "${"appointmentDetails.labels.fullName".tr(context)}: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRouter.profileDetails.name);
              },
              child: Text(
                "${appointment.patient!.fName} ${appointment.patient!.lName}",
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "${"appointmentDetails.labels.age".tr(context)}: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${_calculateAge(appointment.patient!.dateOfBirth!)}"),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentInformation(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.appointment_information".tr(context),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Reason: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "${appointment.reason}"),
            ],
          ),
        ),
        const SizedBox(height: 5),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Description: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "${appointment.description}"),
            ],
          ),
        ),
        const SizedBox(height: 5),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Notes: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "${appointment.note}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.type".tr(context),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.density_medium_rounded),
          title: Text(appointment.type!.display),
          subtitle: Text(appointment.description!),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => _cancelAppointment(context, appointment),
          child: Text("appointmentDetails.cancel".tr(context)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _editAppointment(context, appointment),
          child: Text("appointmentDetails.reschedule".tr(context)),
        ),
      ],
    );
  }

  int _calculateAge(String birthDate) {
    final birthday = DateTime.parse(birthDate);
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _cancelAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) =>
              CancelAppointmentDialog(appointmentId: appointment.id.toString()),
    );

    if (reason != null && reason.isNotEmpty) {
      await context.read<AppointmentCubit>().cancelAppointment(
        context: context,
        id: appointment.id.toString(),
        cancellationReason: reason,
      );
      if (mounted) {
        context.pop(true);
      }
    }
  }

  void _rescheduleAppointment(BuildContext context) {}

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("appointmentDetails.confirmDelete".tr(context)),
            content: Text("appointmentDetails.deleteMessage".tr(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("appointmentDetails.no".tr(context)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("appointmentDetails.yes".tr(context)),
              ),
            ],
          ),
    );

    if (confirmed == true) {}
  }

  void _editAppointment(BuildContext context, AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UpdateAppointmentPage(
              appointmentId: appointment.id.toString(),
              initialReason: appointment.reason ?? '',
              initialDescription: appointment.description ?? '',
              initialNote: appointment.note,
            ),
      ),
    ).then((success) {
      if (success == true) {
        context.read<AppointmentCubit>().getDetailsAppointment(
          context: context,
          id: widget.appointmentId,
        );
        ShowToast.showToastSuccess(
          message: 'appointmentDetails.updateSuccess'.tr(context),
        );
      }
    });
  }
}
