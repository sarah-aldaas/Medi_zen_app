import 'package:flutter/material.dart';

import '../../base/constant/app_images.dart';
import '../../base/theme/app_color.dart';

class MedicalRecordPage extends StatefulWidget {
  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  String _selectedTab = 'Encounters';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Medical Record',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.blackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem('Encounters'),
                  SizedBox(width: 15),
                  _buildTabItem('Conditions'),
                  SizedBox(width: 15),
                  _buildTabItem('Observations'),
                  SizedBox(width: 15),
                  _buildTabItem('Diagnostic Reports'),
                  SizedBox(width: 15),
                  _buildTabItem('Medication Requests'),
                  SizedBox(width: 15),
                  _buildTabItem('Allergies'),
                  SizedBox(width: 15),
                  _buildTabItem('Chronic Diseases'),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildAppointmentList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String tabName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Column(
        children: [
          Text(
            tabName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _selectedTab == tabName ? Colors.blue : Colors.black,
            ),
          ),
          if (_selectedTab == tabName)
            Container(
              height: 2,
              width: 50,
              color: Colors.blue,
              margin: EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    List<Widget> appointmentTiles = [];

    switch (_selectedTab) {
      case 'Encounters':
        appointmentTiles = _buildEncountersList();
        break;
      case 'Conditions':
        appointmentTiles = _buildConditionsList();
        break;
      case 'Observations':
        appointmentTiles = _buildObservationsList();
        break;
      case 'Diagnostic Reports':
        appointmentTiles = _buildDiagnosticReportsList();
        break;
      case 'Medication Requests':
        appointmentTiles = _buildMedicationRequestsList();
        break;
      case 'Allergies':
        appointmentTiles = _buildAllergiesList();
        break;
      case 'Chronic Diseases':
        appointmentTiles = _buildChronicDiseasesList();
        break;
      default:
        appointmentTiles = [
          _buildAppointmentTile(
            'Default Doctor',
            'Default Clinic',
            'Default Time',
            ' assets/images/clinic/photo_doctor8.png',
          ),
        ];
    }

    return ListView(key: ValueKey(_selectedTab), children: appointmentTiles);
  }

  Widget _buildAppointmentTile(
    String doctorName,
    String clinicName,
    String time,
    String imagePath,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imagePath,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(clinicName, style: TextStyle(fontSize: 16)),
                Text(time, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEncountersList() {
    return [
      _buildEncounterTile(
        doctorName: 'Dr. Raul Zirkind',
        clinicName: 'Inpatient Clinic',
        time: 'Dec 12. 2025 | 16:00 PM',
        imageUrl: AppAssetImages.photoDoctor1,
        reason: 'Follow-up visit',
        diagnosis: 'Hypertension',
        notes: 'Patient reported improved condition.',
      ),
    ];
  }

  List<Widget> _buildConditionsList() {
    return [
      _buildConditionTile(
        conditionName: 'Diabetes',
        diagnosisDate: '2020-05-15',
        notes: 'Type 2 diabetes, managed with medication.',
      ),
    ];
  }

  List<Widget> _buildObservationsList() {
    return [
      _buildObservationTile(
        observationName: 'Blood Pressure',
        value: '120/80 mmHg',
        date: '2023-11-20',
      ),
    ];
  }

  List<Widget> _buildDiagnosticReportsList() {
    return [
      _buildDiagnosticReportTile(
        reportName: 'X-Ray',
        reportDate: '2023-11-15',
        result: 'Normal findings.',
      ),
    ];
  }

  List<Widget> _buildMedicationRequestsList() {
    return [
      _buildMedicationRequestTile(
        medicationName: 'Metformin',
        startDate: '2020-05-15',
        dosage: '1000mg daily',
      ),
    ];
  }

  List<Widget> _buildAllergiesList() {
    return [
      _buildAllergyTile(
        allergyName: 'Penicillin',
        reaction: 'Rash',
        notes: 'Avoid penicillin-based medications.',
      ),
    ];
  }

  List<Widget> _buildChronicDiseasesList() {
    return [
      _buildChronicDiseaseTile(
        diseaseName: 'Asthma',
        diagnosisDate: '2015-03-10',
        notes: 'Managed with inhalers.',
      ),
    ];
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
