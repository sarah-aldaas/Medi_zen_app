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
import 'package:medizen_app/features/medical_records/allergy/presentation/pages/appointment_allergies_page.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/encounter_details_page.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/appointment_reactions_page.dart';

import '../../medical_records/encounter/data/models/encounter_model.dart';
import '../../medical_records/encounter/presentation/cubit/encounter_cubit/encounter_cubit.dart';
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
    // Fetch appointment details and encounter when the page loads
    context.read<AppointmentCubit>().getDetailsAppointment(id: widget.appointmentId);
    context.read<EncounterCubit>().getAllMyEncounterOfAppointment(appointmentId: widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Appointment details", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.grey), onPressed: () => context.pop()),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AppointmentCubit, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
          BlocListener<EncounterCubit, EncounterState>(
            listener: (context, state) {
              if (state is EncounterError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
          ),
        ],
        child: BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, appointmentState) {
            if (appointmentState is AppointmentDetailsSuccess) {
              return BlocBuilder<EncounterCubit, EncounterState>(
                builder: (context, encounterState) {
                  if (encounterState is EncounterLoading) {
                    return Center(child: LoadingButton());
                  }
                  return _buildAppointmentDetails(
                    appointmentState.appointmentModel,
                    encounterState is EncounterOfAppointmentSuccess ? encounterState.encounterModel : null,
                  );
                },
              );
            } else if (appointmentState is AppointmentLoading) {
              return const Center(child: LoadingPage());
            } else {
              return const Center(child: Text('Failed to load appointment details'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(AppointmentModel appointment, EncounterModel? encounter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorInfo(appointment),
          const SizedBox(height: 20),
          _buildAppointmentInfo(appointment),
          const SizedBox(height: 20),
          _buildPatientInfo(appointment),
          const SizedBox(height: 20),
          _buildAppointmentInformation(appointment),
          if (encounter != null) ...[const SizedBox(height: 20), _buildAppointmentEncounter(encounter)],
          const SizedBox(height: 20),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Allergies"),
              trailing: Icon(Icons.arrow_circle_right,color: Colors.blue,),
            onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AppointmentAllergiesPage(appointmentId: appointment.id!)));
            },
            ),
          ),
          Divider(),
          const SizedBox(height: 20),
          _buildPackageInfo(appointment),
          if (appointment.status!.code == 'booked_appointment') _buildActionButtons(context, appointment),
          if (appointment.status!.code == 'finished_appointment' && encounter != null) _buildAppointmentEncounter(encounter),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("appointmentDetails.scheduledAppointment".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(DateFormat('EEEE, MMMM d, y').format(DateTime.parse(appointment.startDate!))),
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
        CircleAvatar(backgroundColor: Colors.transparent, radius: 40, backgroundImage: AssetImage(AppAssetImages.photoDoctor1 ?? '')),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment.doctor!.prefix} ${appointment.doctor!.fName} ${appointment.doctor!.lName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: context.width / 1.5, child: Text(appointment.doctor!.text ?? 'General Practitioner')),
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
        Text("appointmentDetails.patientInformation".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("${"appointmentDetails.labels.fullName".tr(context)}: ${appointment.patient!.fName} ${appointment.patient!.lName}"),
        Text("${"appointmentDetails.labels.age".tr(context)}: ${_calculateAge(appointment.patient!.dateOfBirth!)}"),
      ],
    );
  }

  Widget _buildAppointmentInformation(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointment information", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Reason: ${appointment.reason}"),
        Text("Description: ${appointment.description}"),
        Text("Notes: ${appointment.note ?? "No thing"}"),
      ],
    );
  }

  Widget _buildAppointmentEncounter(EncounterModel encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Encounter Details", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EncounterDetailsPage(encounterId: encounter.id!)));
              },
              icon: Icon(Icons.arrow_circle_right, color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (encounter.actualStartDate != null && encounter.actualEndDate != null)
          Text(
            '${DateFormat('HH:mm').format(DateTime.parse(encounter.actualStartDate!))} - '
            '${DateFormat('HH:mm').format(DateTime.parse(encounter.actualEndDate!))}',
          ),
        if (encounter.reason != null) Text("Reason: ${encounter.reason}"),
        if (encounter.specialArrangement != null) Text("Special Arrangement: ${encounter.specialArrangement}"),
      ],
    );
  }

  Widget _buildPackageInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("appointmentDetails.type".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.density_medium_rounded), title: Text(appointment.type!.display), subtitle: Text(appointment.description!)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppointmentModel appointment) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => _cancelAppointment(context, appointment),
          child: Text("appointmentDetails.cancel".tr(context)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
          onPressed: () => _editAppointment(context, appointment),
          child: Text("Update appointment"),
        ),
      ],
    );
  }

  int _calculateAge(String birthDate) {
    final birthday = DateTime.parse(birthDate);
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month || (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  // Update the _cancelAppointment method:
  Future<void> _cancelAppointment(BuildContext context, AppointmentModel appointment) async {
    final reason = await showDialog<String>(context: context, builder: (context) => CancelAppointmentDialog(appointmentId: appointment.id.toString()));

    if (reason != null && reason.isNotEmpty) {
      await context.read<AppointmentCubit>().cancelAppointment(id: appointment.id.toString(), cancellationReason: reason);
      if (mounted) {
        context.pop(true); // Return true to indicate success
      }
    }
  }

  void _rescheduleAppointment(BuildContext context) {
    // Navigate to rescheduling page
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("appointmentDetails.confirmDelete".tr(context)),
            content: Text("appointmentDetails.deleteMessage".tr(context)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text("appointmentDetails.no".tr(context))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text("appointmentDetails.yes".tr(context))),
            ],
          ),
    );

    if (confirmed == true) {
      // Implement delete functionality
    }
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
        // Refresh the details if update was successful
        context.read<AppointmentCubit>().getDetailsAppointment(id: widget.appointmentId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment updated successfully")));
      }
    });
  }
}
