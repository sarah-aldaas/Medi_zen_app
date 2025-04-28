import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class AppointmentDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("appointmentDetails.title".tr(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('YOUR_DOCTOR_IMAGE_URL'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Drake Boeson', // Doctor name typically doesn't need translation
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Immunologists'), // Specialty typically doesn't need translation
                    Text('The Valley Hospital in California, US'), // Location typically doesn't need translation
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "appointmentDetails.scheduledAppointment".tr(context),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Today, December 22, 2022'), // Date would be formatted dynamically in real app
            Text('16:00 - 16:30 PM (30 minutes)'), // Time would be formatted dynamically
            SizedBox(height: 20),
            Text(
              "appointmentDetails.patientInformation".tr(context),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("${"appointmentDetails.labels.fullName".tr(context)}: Andrew Ainsley"),
            Text("${"appointmentDetails.labels.gender".tr(context)}: Male"),
            Text("${"appointmentDetails.labels.age".tr(context)}: 27"),
            Text("${"appointmentDetails.labels.problem".tr(context)}: Lorem ipsum dolor sit amet... ${"appointmentDetails.viewMore".tr(context)}"),
            SizedBox(height: 20),
            Text(
              "appointmentDetails.yourPackage".tr(context),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messaging'), // Service name might not need translation
              subtitle: Text('Chat messages with doctor'), // Description might not need translation
              trailing: Text('\$20 (${"appointmentDetails.paid".tr(context)})'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Handle message start logic
              },
              icon: Icon(Icons.message),
              label: Text('Message (${"appointmentDetails.startAt".tr(context)} 16:00 PM)'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}