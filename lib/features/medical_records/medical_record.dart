import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_filter_model.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/pages/all_allergies_page.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/widgets/allergy_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_filter_model.dart';
import 'package:medizen_app/features/medical_records/conditions/presentation/widgets/condition_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/diagnostic_report/data/models/diagnostic_report_filter_model.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/all_encounters_page.dart';
import 'package:medizen_app/features/medical_records/medication/presentation/pages/my_medications_public_page.dart';
import 'package:medizen_app/features/medical_records/medication_request/data/models/medication_request_filter.dart';
import 'package:medizen_app/features/medical_records/medication_request/presentation/widgets/medication_request_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_filter.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/pages/service_requests_page.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/widgets/service_request_filter_dialog.dart';

import '../../base/theme/app_color.dart';
import 'conditions/presentation/pages/conditions_list_page.dart';
import 'diagnostic_report/presentation/pages/diagnostic_report_list_public_page.dart';
import 'diagnostic_report/presentation/widgets/diagnostic_report_filter_dialog.dart';
import 'encounter/data/models/encounter_filter_model.dart';
import 'encounter/presentation/widgets/encounter_filter_dialog.dart';
import 'medication/data/models/medication_filter_model.dart';
import 'medication/presentation/widgets/medication_filter_dialog.dart';
import 'medication_request/presentation/pages/my_medication_requests_public_page.dart';

class MedicalRecordPage extends StatefulWidget {
  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EncounterFilterModel _encounterFilter = EncounterFilterModel();
  AllergyFilterModel _allergyFilter = AllergyFilterModel();
  ServiceRequestFilter _serviceRequestFilter = ServiceRequestFilter();
  ConditionsFilterModel _conditionFilter = ConditionsFilterModel();
  MedicationRequestFilterModel _medicationRequestFilter = MedicationRequestFilterModel();
  MedicationFilterModel _medicationFilter = MedicationFilterModel();
  DiagnosticReportFilterModel _diagnosticReportFilter = DiagnosticReportFilterModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _showEncounterFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(context: context, builder: (context) => EncounterFilterDialog(currentFilter: _encounterFilter));

    if (result != null) {
      setState(() => _encounterFilter = result);
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

  Future<void> _showMedicationRequestFilterDialog() async {
    final result = await showDialog<MedicationRequestFilterModel>(
      context: context,
      builder: (context) => MedicationRequestFilterDialog(currentFilter: _medicationRequestFilter),
    );

    if (result != null) {
      setState(() => _medicationRequestFilter = result);
    }
  }

  Future<void> _showMedicationFilterDialog() async {
    final result = await showDialog<MedicationFilterModel>(context: context, builder: (context) => MedicationFilterDialog(currentFilter: _medicationFilter));

    if (result != null) {
      setState(() => _medicationFilter = result);
    }
  }

  Future<void> _showDiagnosticReportFilterDialog() async {
    final result = await showDialog<DiagnosticReportFilterModel>(
      context: context,
      builder: (context) => DiagnosticReportFilterDialog(currentFilter: _diagnosticReportFilter),
    );

    if (result != null) {
      setState(() => _diagnosticReportFilter = result);
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
      'medicalRecordPage.tabs.encounters'.tr(context),
      'medicalRecordPage.tabs.allergies'.tr(context),
      'medicalRecordPage.tabs.serviceRequest'.tr(context),
      'medicalRecordPage.tabs.conditions'.tr(context),
      'medicalRecordPage.tabs.medicationRequests'.tr(context),
      'medicalRecordPage.tabs.medication'.tr(context),
      'medicalRecordPage.tabs.diagnosticReports'.tr(context),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('medicalRecordPage.title'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryColor)),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showEncounterFilterDialog,
              tooltip: 'medicalRecordPage.filterEncountersTooltip'.tr(context),
            ),
          if (_tabController.index == 1)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showAllergyFilterDialog, tooltip: 'medicalRecordPage.filterAllergyTooltip'.tr(context)),
          if (_tabController.index == 2)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showServiceRequestFilterDialog, tooltip: "Filter service request"),
          if (_tabController.index == 3) IconButton(icon: const Icon(Icons.filter_list), onPressed: _showConditionFilterDialog, tooltip: "Filter condition"),
          if (_tabController.index == 4)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showMedicationRequestFilterDialog, tooltip: "Filter mediation request"),
          if (_tabController.index == 5) IconButton(icon: const Icon(Icons.filter_list), onPressed: _showMedicationFilterDialog, tooltip: "Filter mediation"),
          if (_tabController.index == 6)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showDiagnosticReportFilterDialog, tooltip: "Filter mediation"),
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
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            AllEncountersPage(filter: _encounterFilter),
            AllAllergiesPage(filter: _allergyFilter),
            ServiceRequestsPage(filter: _serviceRequestFilter),
            ConditionsListPage(filter: _conditionFilter),
            MyMedicationRequestsPublicPage(filter: _medicationRequestFilter),
            MyMedicationsPublicPage(filter: _medicationFilter),
            DiagnosticReportListPublicPage(filter: _diagnosticReportFilter),
          ],
        ),
      ),
    );
  }
}
