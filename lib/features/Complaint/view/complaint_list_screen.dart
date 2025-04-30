// screen/complaint_list_screen.dart
import 'package:flutter/material.dart';
import 'package:medizen_app/features/Complaint/view/widget/complaint_item.dart';

import '../../../base/theme/app_color.dart';

class ComplaintListScreen extends StatelessWidget {
  final List<Map<String, String>> complaints = [
    {'doctorName': 'اسم الدكتور 1 - العيادة القلبية'},
    {'doctorName': 'اسم الدكتور 2 - عيادة الأعصاب'},
    {'doctorName': 'اسم الدكتور 3 - عيادة الأطفال'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints submitted',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.blackColor)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  return ComplaintItem(complaint: complaints[index]);
                },
              ),
            ),
            SizedBox(height: 20.0),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: Text(
            //     'submit complaint',
            //     style: AppStyles.primaryButtonStyle,
            //   ),
            //   style: AppStyles.primaryButtonStyle,
            // ),
          ],
        ),
      ),
    );
  }
}
