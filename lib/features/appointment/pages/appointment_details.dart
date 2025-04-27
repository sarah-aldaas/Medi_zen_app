import 'package:flutter/material.dart';

class AppointmentDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  backgroundImage: NetworkImage('YOUR_DOCTOR_IMAGE_URL'), // Replace with your image URL
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Drake Boeson',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Immunologists'),
                    Text('The Valley Hospital in California, US'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Scheduled Appointment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Today, December 22, 2022'),
            Text('16:00 - 16:30 PM (30 minutes)'),
            SizedBox(height: 20),
            Text(
              'Patient Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Full Name: Andrew Ainsley'),
            Text('Gender: Male'),
            Text('Age: 27'),
            Text('Problem: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor. view more'),
            SizedBox(height: 20),
            Text(
              'Your Package',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messaging'),
              subtitle: Text('Chat messages with doctor'),
              trailing: Text('\$20 (paid)'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Handle message start logic
              },
              icon: Icon(Icons.message),
              label: Text('Message (Start at 16:00 PM)'),
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