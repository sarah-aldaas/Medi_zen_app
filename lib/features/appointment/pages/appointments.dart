import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

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
        title: Text("myAppointments.title".tr(context),
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            children: [
              _buildTabButton("myAppointments.tabs.upcoming".tr(context), 0),
              _buildTabButton("myAppointments.tabs.completed".tr(context), 1),
              _buildTabButton("myAppointments.tabs.cancelled".tr(context), 2),
            ],
          ),
        ),
      ),
      body: _buildAppointmentList(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: _selectedTab == index
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2.0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTab == index
                ? Theme.of(context).primaryColor
                : Colors.grey,
            fontWeight: _selectedTab == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    List<Appointment> appointments = [
      Appointment(
        imageUrl: AppAssetImages.photoDoctor1,
        name: 'Dr. Drake Boeson',
        communication: "myAppointments.communicationTypes.messaging".tr(context),
        status: "myAppointments.status.upcoming".tr(context),
        time: 'Today | 16:00 PM',
      ),
      Appointment(
        imageUrl: AppAssetImages.photoDoctor2,
        name: 'Dr. Jenny Watson',
        communication: "myAppointments.communicationTypes.voiceCall".tr(context),
        status: "myAppointments.status.upcoming".tr(context),
        time: 'Today | 14:00 PM',
      ),
      Appointment(
        imageUrl: AppAssetImages.photoDoctor3,
        name: 'Dr. Maria Foose',
        communication: "myAppointments.communicationTypes.videoCall".tr(context),
        status: "myAppointments.status.upcoming".tr(context),
        time: 'Today | 10:00 AM',
      ),
    ];

    List<Appointment> filteredAppointments = appointments.where((appointment) {
      if (_selectedTab == 0) {
        return appointment.status == "myAppointments.status.upcoming".tr(context);
      } else if (_selectedTab == 1) {
        return appointment.status == "myAppointments.status.completed".tr(context);
      } else {
        return appointment.status == "myAppointments.status.cancelled".tr(context);
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
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                          appointment.imageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill
                      )
                  ),
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
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Text(
                                appointment.status,
                                style: TextStyle(color: Theme.of(context).primaryColor)),
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
                    onPressed: () {},
                    child: Text("myAppointments.buttons.cancelAppointment".tr(context)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("myAppointments.buttons.reschedule".tr(context)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
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

  Appointment({
    required this.imageUrl,
    required this.name,
    required this.communication,
    required this.status,
    required this.time,
  });
}