import 'package:flutter/material.dart';

class RescheduleAppointmentPage extends StatefulWidget {
  @override
  _RescheduleAppointmentPageState createState() => _RescheduleAppointmentPageState();
}

class _RescheduleAppointmentPageState extends State<RescheduleAppointmentPage> {
  int _selectedValue = 0; // Default selected is "I'm having a schedule clash"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reschedule Appointment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for Schedule Change',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildRadioButton('I\'m having a schedule clash', 0),
            _buildRadioButton('I\'m not available on schedule', 1),
            _buildRadioButton('I have a activity that can\'t be left behind', 2),
            _buildRadioButton('I don\'t want to tell', 3),
            _buildRadioButton('Others', 4),
            SizedBox(height: 20),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.',
              style: TextStyle(fontSize: 14),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle next button press
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(String text, int value) {
    return RadioListTile(
      title: Text(text),
      value: value,
      groupValue: _selectedValue,
      onChanged: (int? newValue) {
        setState(() {
          _selectedValue = newValue!;
        });
      },
    );
  }
}