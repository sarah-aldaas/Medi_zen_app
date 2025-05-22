import 'package:flutter/material.dart';
import 'package:medizen_app/features/medical_records/allergy/data/models/allergy_filter_model.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/pages/all_allergies_page.dart';
import 'package:medizen_app/features/medical_records/allergy/presentation/widgets/allergy_filter_dialog.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/all_encounters_page.dart';
import '../../base/constant/app_images.dart';
import '../../base/theme/app_color.dart';
import 'encounter/data/models/encounter_filter_model.dart';
import 'encounter/presentation/widgets/encounter_filter_dialog.dart';


class MedicalRecordPage extends StatefulWidget {
  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EncounterFilterModel _encounterFilter = EncounterFilterModel(); // Add this
  AllergyFilterModel _allergyFilter = AllergyFilterModel(); // Add this

  final List<String> _tabs = [
    'Encounters',
    'Allergies',
    'Conditions',
    'Observations',
    'Diagnostic Reports',
    'Medication Requests',
    'Chronic Diseases',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection); // Add this
  }

// Add this method
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
      }); // Force rebuild when tab changes
    }
  }
  Future<void> _showEncounterFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(
      context: context,
      builder: (context) => EncounterFilterDialog(currentFilter: _encounterFilter),
    );

    if (result != null) {
      setState(() => _encounterFilter = result);
    }
  }


  Future<void> _showAllergyFilterDialog() async {
    final result = await showDialog<AllergyFilterModel>(
      context: context,
      builder: (context) => AllergyFilterDialog(currentFilter: _allergyFilter),
    );

    if (result != null) {
      setState(() => _allergyFilter = result);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Clean up

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Medical Record',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showEncounterFilterDialog,
              tooltip: 'Filter Encounters',
            ),
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showAllergyFilterDialog,
              tooltip: 'Filter Allergy',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
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
            AllEncountersPage(filter: _encounterFilter), // Pass filter down
            AllAllergiesPage(filter:_allergyFilter),
            _buildObservationsList(),
            _buildDiagnosticReportsList(),
            _buildMedicationRequestsList(),
            _buildAllergiesList(),
            _buildChronicDiseasesList(),
          ],
        ),
      ),
    );
  }



  Widget _buildObservationsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildObservationTile(
          observationName: 'Blood Pressure',
          value: '120/80 mmHg',
          date: '2023-11-20',
        ),
      ],
    );
  }

  Widget _buildDiagnosticReportsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildDiagnosticReportTile(
          reportName: 'X-Ray',
          reportDate: '2023-11-15',
          result: 'Normal findings.',
        ),
      ],
    );
  }

  Widget _buildMedicationRequestsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMedicationRequestTile(
          medicationName: 'Metformin',
          startDate: '2020-05-15',
          dosage: '1000mg daily',
        ),
      ],
    );
  }

  Widget _buildAllergiesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildAllergyTile(
          allergyName: 'Penicillin',
          reaction: 'Rash',
          notes: 'Avoid penicillin-based medications.',
        ),
      ],
    );
  }

  Widget _buildChronicDiseasesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildChronicDiseaseTile(
          diseaseName: 'Asthma',
          diagnosisDate: '2015-03-10',
          notes: 'Managed with inhalers.',
        ),
      ],
    );
  }

  Widget _buildEncounterTile({
    required String doctorName,
    required String clinicName,
    required String time,
    required String imageUrl,
    required String reason,
    required String diagnosis,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(clinicName, style: TextStyle(fontSize: 16)),
                    Text(time, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Reason: $reason',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Diagnosis: $diagnosis'),
          Text('Notes: $notes'),
        ],
      ),
    );
  }

  Widget _buildConditionTile({
    required String conditionName,
    required String diagnosisDate,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conditionName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Diagnosis Date: $diagnosisDate',
            style: TextStyle(fontSize: 16),
          ),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildObservationTile({
    required String observationName,
    required String value,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            observationName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Value: $value', style: TextStyle(fontSize: 16)),
          Text('Date: $date', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({
    required String reportName,
    required String reportDate,
    required String result,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reportName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Report Date: $reportDate', style: TextStyle(fontSize: 16)),
          Text('Result: $result', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({
    required String medicationName,
    required String startDate,
    required String dosage,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicationName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Start Date: $startDate', style: TextStyle(fontSize: 16)),
          Text('Dosage: $dosage', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({
    required String allergyName,
    required String reaction,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allergyName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Reaction: $reaction', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({
    required String diseaseName,
    required String diagnosisDate,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diseaseName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Diagnosis Date: $diagnosisDate',
            style: TextStyle(fontSize: 16),
          ),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
