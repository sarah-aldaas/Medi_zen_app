import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/appointment/pages/widgets/cancel_appointment_dialog.dart';
import 'package:medizen_app/features/appointment/pages/widgets/update_appointment_page.dart';

import '../../../base/theme/app_color.dart';
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
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
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
          const SizedBox(height: 50),

          if (appointment.status!.code == 'booked_appointment')
            _buildActionButtons(context, appointment),
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
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 40,
          backgroundImage: AssetImage(AppAssetImages.photoDoctor1 ?? ''),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment.doctor!.prefix} ${appointment.doctor!.fName} ${appointment.doctor!.lName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: context.width / 1.5,
              child: Text(appointment.doctor!.text ?? 'General Practitioner'),
            ),
            Text(appointment.doctor!.address),
          ],
        ),
      ],
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
        Text(
          "${"appointmentDetails.labels.fullName".tr(context)}: ${appointment.patient!.fName} ${appointment.patient!.lName}",
        ),
        const SizedBox(height: 5),
        Text(
          "${"appointmentDetails.labels.age".tr(context)}: ${_calculateAge(appointment.patient!.dateOfBirth!)}",
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
        Text("Reason: ${appointment.reason}"),
        const SizedBox(height: 5),
        Text("Description: ${appointment.description}"),
        const SizedBox(height: 5),
        Text("Notes: ${appointment.note ?? "No thing"}"),
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
      await context.read<AppointmentCubit>().cancelAppointment(context: context,
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
          id: widget.appointmentId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment updated successfully")),
        );
      }
    });
  }
}
