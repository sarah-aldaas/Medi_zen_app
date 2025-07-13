import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/appointment/pages/appointment_details.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_filter_model.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/pages/all_allergies_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/widgets/allergy_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_filter_model.dart';
import 'package:medizen_app/features/medical_records/conditions/presentation/widgets/condition_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_filter_model.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/all_encounters_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/medication_request/data/models/medication_request_filter.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_filter.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/pages/service_requests_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/widgets/service_request_filter_dialog.dart';

import '../../base/theme/app_color.dart';
import 'conditions/presentation/pages/conditions_list_of_appointment.dart';
import 'medication/data/models/medication_filter_model.dart';

class MedicalRecordOfAppointmentPage extends StatefulWidget {
  final String appointmentId;

  const MedicalRecordOfAppointmentPage({super.key, required this.appointmentId});

  @override
  _MedicalRecordOfAppointmentPageState createState() => _MedicalRecordOfAppointmentPageState();
}

class _MedicalRecordOfAppointmentPageState extends State<MedicalRecordOfAppointmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // EncounterFilterModel _encounterFilter = EncounterFilterModel();
  AllergyFilterModel _allergyFilter = AllergyFilterModel();
  ServiceRequestFilter _serviceRequestFilter = ServiceRequestFilter();
  ConditionsFilterModel _conditionFilter = ConditionsFilterModel();
  MedicationRequestFilterModel _medicationRequestFilter = MedicationRequestFilterModel();
  MedicationFilterModel _medicationFilter = MedicationFilterModel();
  DiagnosticReportFilterModel _diagnosticReportFilter = DiagnosticReportFilterModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _showAllergyFilterDialog() async {
    final result = await showDialog<AllergyFilterModel>(context: context, builder: (context) => AllergyFilterDialog(currentFilter: _allergyFilter));

    if (result != null) {
      setState(() => _allergyFilter = result);
    }
  }

  Future<void> _showServiceRequestFilterDialog() async {
    final result = await showDialog<ServiceRequestFilter>(
      context: context,
      builder: (context) => ServiceRequestFilterDialog(currentFilter: _serviceRequestFilter),
    );

    if (result != null) {
      setState(() => _serviceRequestFilter = result);
    }
  }

  Future<void> _showConditionFilterDialog() async {
    final result = await showDialog<ConditionsFilterModel>(context: context, builder: (context) => ConditionsFilterDialog(currentFilter: _conditionFilter));

    if (result != null) {
      setState(() => _conditionFilter = result);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _tabs = [
      'medicalRecordPage.tabs.appointmentDetails'.tr(context),
      'medicalRecordPage.tabs.encounters'.tr(context),
      'medicalRecordPage.tabs.allergies'.tr(context),
      'medicalRecordPage.tabs.serviceRequest'.tr(context),
      'medicalRecordPage.tabs.conditions'.tr(context),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('medicalRecordPage.title'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryColor)),
        centerTitle: true,
        actions: [
          if (_tabController.index == 2)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showAllergyFilterDialog, tooltip: 'medicalRecordPage.filterAllergyTooltip'.tr(context)),
          if (_tabController.index == 3)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showServiceRequestFilterDialog,
              tooltip: 'medicalRecordPage.filterServiceRequest'.tr(context),
            ),
          if (_tabController.index == 4) IconButton(icon: const Icon(Icons.filter_list), onPressed: _showConditionFilterDialog, tooltip: 'Condition filter'),
         ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primaryColor,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              indicatorColor: AppColors.primaryColor,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
            controller: _tabController,
            children: [
              AppointmentDetailsPage(appointmentId: widget.appointmentId),
              AllEncountersOfAppointmentPage(appointmentId: widget.appointmentId),
              AllAllergiesOfAppointmentPage(appointmentId: widget.appointmentId, filter: _allergyFilter),
              ServiceRequestsOfAppointmentPage(appointmentId: widget.appointmentId, filter: _serviceRequestFilter),
              ConditionsListOfAppointment(appointmentId: widget.appointmentId, filter: _conditionFilter),
               ],
          ),
      ),

    );
  }
}
