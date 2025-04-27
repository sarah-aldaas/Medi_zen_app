import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_mobile/base/extensions/media_query_extension.dart';

import '../../../base/constant/app_images.dart';
import '../../../base/theme/app_style.dart';
import '../../Complaint/view/complaint_submission_screen.dart';
import '../doctor.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key, required Doctor doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  List<DateTime> _generateDays() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  // Sample list of booked times for a specific date (you'll likely fetch this dynamically)
  final List<String> _bookedTimes = ["10:00 AM", "03:00 PM"];

  List<String> _availableTimes = [
    "08:00 AM",
    "10:00 AM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "07:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    final days = _generateDays();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Dr. Jenny Watson'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.grey),
            // You might want to use filled heart if already favorited
            onPressed: () {
              // Handle favorite toggle
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(
                  AppAssetImages.photoDoctor1,
                ), // Replace with your image URL
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dr. Jenny Watson',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Immunologists'),
                  Text('Christ Hospital in London, UK'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(Icons.people, '5.000+', 'patients', context),
              _buildInfoColumn(
                Icons.calendar_today,
                '10+',
                'years exper.',
                context,
              ),
              _buildInfoColumn(Icons.star, '4.8', 'rating', context),
              _buildInfoColumn(
                Icons.rate_review,
                '4.942',
                'reviews',
                context,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'About me',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dr. Jenny Watson is the top most Immunologists specialist in Christ Hospital at London. She achieved several awards for her wonderful contribution in medical field. She is available for private consultation. view more',
          ),
          const SizedBox(height: 20),
          const Text(
            'Working Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Monday - Friday, 08.00 AM - 20.00 PM'),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isSelected = day.day == _selectedDate.day &&
                        day.month == _selectedDate.month &&
                        day.year == _selectedDate.year;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = day;
                          _selectedTime = null; // Reset time when date changes
                        });
                      },
                      child: Container(
                        width: 45,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00CBA9)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(day).substring(0, 3),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(day),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: context.width,
                child: Wrap(
                  spacing: 8.0,
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8.0,
                  children: _availableTimes.map((timeStr) {
                    final parsedTime = DateFormat(
                      "hh:mm a",
                    ).parse(timeStr);
                    final timeOfDay = TimeOfDay.fromDateTime(parsedTime);
                    final isSelected = _selectedTime == timeOfDay;
                    final isBooked = _bookedTimes.contains(timeStr);

                    return InkWell(
                      onTap: isBooked
                          ? null // Disable onTap if the time is booked
                          : () {
                              setState(() {
                                _selectedTime = timeOfDay;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00CBA9)
                              : isBooked
                                  ? Colors.grey[300] // Booked color
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected || isBooked
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedDate != null && _selectedTime != null)
                Text(
                  'Selected: ${DateFormat('EEE, MMM d').format(_selectedDate)} at ${_selectedTime!.format(context)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 30),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter reason for visit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            onChanged: (value) {
              // context.read<AppointmentCubit>().setNotes(value);
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _selectedTime == null
                  ? null // Disable button if no time is selected
                  : () {
                      // Handle book appointment with _selectedDate and _selectedTime
                      print(
                        'Booking appointment on ${_selectedDate} at ${_selectedTime!.format(context)}',
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintSubmissionScreen(),
                  ),
                );
              },
              child: Text('Submit a Complaint ?',
                  style: AppStyles.complaintTextStyle),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Handle see all reviews
                },
                child: Text(
                  'See All',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          const ListTile(
            title: Text('Charolette Hanlin'),
            subtitle: Text(
              'Dr. Jenny is very professional in her work and responsive. I have consulted and my problem is solved. 👍👍',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.star, color: Colors.amber), Text('5')],
            ),
          ),
          const Gap(30),
        ]),
      ),
    );
  }

  Widget _buildInfoColumn(
    IconData icon,
    String value,
    String label,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
