import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_filter_model.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/pages/all_allergies_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/widgets/allergy_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_filter_model.dart';
import 'package:medizen_app/features/medical_records/conditions/presentation/widgets/condition_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/all_encounters_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/medication_request/data/models/medication_request_filter.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_filter.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/pages/service_requests_of_appointment_page.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/widgets/service_request_filter_dialog.dart';

import '../../base/theme/app_color.dart';
import 'conditions/presentation/pages/conditions_list_of_appointment.dart';
import 'medication/data/models/medication_filter_model.dart';
import 'medication/presentation/pages/my_medications_of_appointment_page.dart';
import 'medication/presentation/widgets/medication_filter_dialog.dart';
import 'medication_request/presentation/pages/my_medication_requests_of_appointment_page.dart';
import 'medication_request/presentation/widgets/medication_request_filter_dialog.dart';

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
    final result = await showDialog<MedicationFilterModel>(
      context: context,
      builder: (context) => MedicationFilterDialog(currentFilter: _medicationFilter),
    );

    if (result != null) {
      setState(() => _medicationFilter = result);
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
      'medicalRecordPage.tabs.chronicDiseases'.tr(context),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('medicalRecordPage.title'.tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryColor)),
        centerTitle: true,
        actions: [
          if (_tabController.index == 1)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showAllergyFilterDialog, tooltip: 'medicalRecordPage.filterAllergyTooltip'.tr(context)),
          if (_tabController.index == 2)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showServiceRequestFilterDialog,
              tooltip: 'medicalRecordPage.filterServiceRequest'.tr(context),
            ),
          if (_tabController.index == 3) IconButton(icon: const Icon(Icons.filter_list), onPressed: _showConditionFilterDialog, tooltip: 'Condition filter'),
          if (_tabController.index == 4)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showMedicationRequestFilterDialog, tooltip: 'Medication request filter'),
         if (_tabController.index == 5)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showMedicationFilterDialog, tooltip: 'Medication filter'),
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
            AllEncountersOfAppointmentPage(appointmentId: widget.appointmentId),
            AllAllergiesOfAppointmentPage(appointmentId: widget.appointmentId, filter: _allergyFilter),
            ServiceRequestsOfAppointmentPage(appointmentId: widget.appointmentId, filter: _serviceRequestFilter),
            ConditionsListOfAppointment(appointmentId: widget.appointmentId, filter: _conditionFilter),
            MyMedicationRequestsOfAppointmentPage(appointmentId: widget.appointmentId, filter: _medicationRequestFilter),
            MyMedicationsOfAppointmentPage(appointmentId: widget.appointmentId,filter: _medicationFilter,),
            _buildAllergiesList(),
            _buildChronicDiseasesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsList() {
    return ListView(padding: EdgeInsets.all(16), children: [_buildObservationTile(observationName: 'الملاحظات', value: '120/80 mmHg', date: '2023-11-20')]);
  }

  Widget _buildDiagnosticReportsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildDiagnosticReportTile(reportName: 'التقارير التشخيصية', reportDate: '2023-11-15', result: 'نتائج طبيعية.')],
    );
  }

  Widget _buildMedicationRequestsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildMedicationRequestTile(medicationName: 'ميتفورمين', startDate: '2020-05-15', dosage: '1000 ملغ يوميًا')],
    );
  }

  Widget _buildAllergiesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildAllergyTile(allergyName: 'البنسلين', reaction: 'طفح جلدي', notes: 'تجنب الأدوية المحتوية على البنسلين.')],
    );
  }

  Widget _buildChronicDiseasesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildChronicDiseaseTile(diseaseName: 'ربو', diagnosisDate: '2015-03-10', notes: 'يتم التحكم به باستخدام أجهزة الاستنشاق.')],
    );
  }

  Widget _buildObservationTile({required String observationName, required String value, required String date}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(observationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Value: $value', style: TextStyle(fontSize: 16)),
          Text('Date: $date', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({required String reportName, required String reportDate, required String result}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reportName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Report Date: $reportDate', style: TextStyle(fontSize: 16)),
          Text('Result: $result', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({required String medicationName, required String startDate, required String dosage}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medicationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Start Date: $startDate', style: TextStyle(fontSize: 16)),
          Text('Dosage: $dosage', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({required String allergyName, required String reaction, required String notes}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(allergyName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Reaction: $reaction', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({required String diseaseName, required String diagnosisDate, required String notes}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diseaseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Diagnosis Date: $diagnosisDate', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
