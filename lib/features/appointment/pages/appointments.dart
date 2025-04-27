import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../base/constant/app_images.dart';


class MyAppointmentPage extends StatefulWidget {
  const MyAppointmentPage({super.key});

  @override
  _MyAppointmentPageState createState() => _MyAppointmentPageState();
}

class _MyAppointmentPageState extends State<MyAppointmentPage> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Completed, 2 for Cancelled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('My Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_buildTabButton('Upcoming', 0), _buildTabButton('Completed', 1), _buildTabButton('Cancelled', 2)],
          ),
        ),
      ),
      body: _buildAppointmentList(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: _selectedTab == index ? Theme.of(context).primaryColor : Colors.transparent, width: 2.0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTab == index ? Theme.of(context).primaryColor : Colors.grey,
            fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    // Replace with your actual appointment data
    List<Appointment> appointments = [
      Appointment(
        imageUrl: AppAssetImages.photoDoctor1,
        // Replace with your image URL
        name: 'Dr. Drake Boeson',
        communication: 'Messaging',
        status: 'Upcoming',
        time: 'Today | 16:00 PM',
      ),
      Appointment(
        imageUrl: AppAssetImages.photoDoctor2,
        // Replace with your image URL
        name: 'Dr. Jenny Watson',
        communication: 'Voice Call',
        status: 'Upcoming',
        time: 'Today | 14:00 PM',
      ),
      Appointment(
        imageUrl: AppAssetImages.photoDoctor3,
        // Replace with your image URL
        name: 'Dr. Maria Foose',
        communication: 'Video Call',
        status: 'Upcoming',
        time: 'Today | 10:00 AM',
      ),
    ];

    // Filter appointments based on selected tab
    List<Appointment> filteredAppointments =
        appointments.where((appointment) {
          if (_selectedTab == 0) {
            return appointment.status == 'Upcoming';
          } else if (_selectedTab == 1) {
            return appointment.status == 'Completed';
          } else {
            return appointment.status == 'Cancelled';
          }
        }).toList();

    return ListView.builder(
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentItem(filteredAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Row(
                spacing: 5,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset(appointment.imageUrl, height: 100, width: 100, fit: BoxFit.fill)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.name, style: TextStyle(fontWeight: FontWeight.bold)),

                      Row(
                        children: [
                          Text(appointment.communication),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10.0)),
                            child: Text(appointment.status, style: TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      ),
                      Text(appointment.time),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle cancel appointment
                    },
                    child: Text('Cancel Appointment'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),

                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle reschedule
                    },
                    child: Text('Reschedule'),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            Gap(5),
          ],
        ),
      ),
    );
  }
}

class Appointment {
  final String imageUrl;
  final String name;
  final String communication;
  final String status;
  final String time;

  Appointment({required this.imageUrl, required this.name, required this.communication, required this.status, required this.time});
}

class CompletedAppointmentsPage extends StatefulWidget {
  const CompletedAppointmentsPage({super.key});

  @override
  _CompletedAppointmentsPageState createState() => _CompletedAppointmentsPageState();
}

class _CompletedAppointmentsPageState extends State<CompletedAppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointment'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_buildTabButton('Upcoming', 0), _buildTabButton('Completed', 1), _buildTabButton('Cancelled', 2)],
          ),
        ),
      ),
      body: _buildAppointmentList(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to the corresponding tab
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: index == 1 ? Theme.of(context).primaryColor : Colors.transparent, // Highlight Completed tab
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: index == 1 ? Theme.of(context).primaryColor : Colors.grey, // Highlight Completed tab
            fontWeight: index == 1 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    // Replace with your actual completed appointment data
    List<Appointment> completedAppointments = [
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_1',
        // Replace with your image URL
        name: 'Dr. Aidan Allende',
        communication: 'Video Call',
        time: 'Dec 14, 2022 | 15:00 PM',
        status: '',
      ),
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_2',
        // Replace with your image URL
        name: 'Dr. Iker Holl',
        communication: 'Messaging',
        time: 'Nov 22, 2022 | 09:00 AM',
        status: '',
      ),
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_3',
        // Replace with your image URL
        name: 'Dr. Jada Srnsky',
        communication: 'Voice Call',
        time: 'Nov 06, 2022 | 18:00 PM',
        status: '',
      ),
    ];

    return ListView.builder(
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentItem(completedAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(appointment.imageUrl)),
          title: Text(appointment.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(appointment.communication),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10.0)),
                    child: Text('Completed', style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              Text(appointment.time),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle book again
                },
                child: Text('Book Again'),
                style: ElevatedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor, backgroundColor: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle leave a review
                },
                child: Text('Leave a Review'),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.grey[300], backgroundColor: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Divider(),
      ],
    );
  }
}

class CancelledAppointmentsPage extends StatefulWidget {
  const CancelledAppointmentsPage({super.key});

  @override
  _CancelledAppointmentsPageState createState() => _CancelledAppointmentsPageState();
}

class _CancelledAppointmentsPageState extends State<CancelledAppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointment'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_buildTabButton('Upcoming', 0), _buildTabButton('Completed', 1), _buildTabButton('Cancelled', 2)],
          ),
        ),
      ),
      body: _buildAppointmentList(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () {
        // Handle tab navigation
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: index == 2 ? Theme.of(context).primaryColor : Colors.transparent, // Highlight Cancelled tab
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: index == 2 ? Theme.of(context).primaryColor : Colors.grey, // Highlight Cancelled tab
            fontWeight: index == 2 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    // Replace with your actual cancelled appointment data
    List<Appointment> cancelledAppointments = [
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_1',
        // Replace with your image URL
        name: 'Dr. Raul Zirkind',
        communication: 'Voice Call',
        time: 'Dec 12, 2022 | 16:00 PM',
        status: '',
      ),
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_2',
        // Replace with your image URL
        name: 'Dr. Keegan Dach',
        communication: 'Messaging',
        time: 'Nov 20, 2022 | 10:00 AM',
        status: '',
      ),
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_3',
        // Replace with your image URL
        name: 'Dr. Drake Boeson',
        communication: 'Video Call',
        time: 'Nov 08, 2022 | 13:00 PM',
        status: '',
      ),
      Appointment(
        imageUrl: 'YOUR_IMAGE_URL_4',
        // Replace with your image URL
        name: 'Dr. Quinn Slatter',
        communication: 'Voice Call',
        time: 'Oct 16, 2022 | 09:00 AM',
        status: '',
      ),
    ];

    return ListView.builder(
      itemCount: cancelledAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentItem(cancelledAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(appointment.imageUrl)),
          title: Text(appointment.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(appointment.communication),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10.0)),
                    child: Text('Cancelled', style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
              Text(appointment.time),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
