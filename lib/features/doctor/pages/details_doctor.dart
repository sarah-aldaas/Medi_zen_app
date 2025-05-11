import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';

import '../../../base/theme/app_style.dart';
import '../../Complaint/view/complaint_submission_screen.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key});

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
        title: Text('doctorDetails.doctorName'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
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
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(AppAssetImages.photoDoctor1),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'doctorDetails.doctorName'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('doctorDetails.specialty'.tr(context)),
                    Text('doctorDetails.hospital'.tr(context)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  Icons.people,
                  '5.000+',
                  'doctorDetails.patients',
                  context,
                ),
                _buildInfoColumn(
                  Icons.calendar_today,
                  '10+',
                  'doctorDetails.yearsExperience',
                  context,
                ),
                _buildInfoColumn(
                  Icons.star,
                  '4.8',
                  'doctorDetails.rating',
                  context,
                ),
                _buildInfoColumn(
                  Icons.rate_review,
                  '4.942',
                  'doctorDetails.reviews',
                  context,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'doctorDetails.aboutMe'.tr(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('doctorDetails.aboutMeDescription'.tr(context)),
            const SizedBox(height: 20),
            Text(
              'doctorDetails.workingTime'.tr(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('doctorDetails.workingHours'.tr(context)),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isSelected =
                          day.day == _selectedDate.day &&
                          day.month == _selectedDate.month &&
                          day.year == _selectedDate.year;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = day;
                            _selectedTime = null;
                          });
                        },
                        child: Container(
                          width: 45,
                          decoration: BoxDecoration(
                            color:
                                isSelected
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
                                  color:
                                      isSelected
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
                                  color:
                                      isSelected ? Colors.white : Colors.black,
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
                    children:
                        _availableTimes.map((timeStr) {
                          final parsedTime = DateFormat(
                            "hh:mm a",
                          ).parse(timeStr);
                          final timeOfDay = TimeOfDay.fromDateTime(parsedTime);
                          final isSelected = _selectedTime == timeOfDay;
                          final isBooked = _bookedTimes.contains(timeStr);

                          return InkWell(
                            onTap:
                                isBooked
                                    ? null
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
                                color:
                                    isSelected
                                        ? const Color(0xFF00CBA9)
                                        : isBooked
                                        ? Colors.grey[300]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isSelected || isBooked
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
                    '${'doctorDetails.selected'.tr(context)}: ${DateFormat('EEE, MMM d').format(_selectedDate)} at ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed:
                    _selectedTime == null
                        ? null
                        : () {
                          print(
                            'Booking appointment on $_selectedDate at ${_selectedTime!.format(context)}',
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
                child: Text(
                  'doctorDetails.bookAppointment'.tr(context),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
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
                child: Text(
                  'doctorDetails.SubmitaComplaint'.tr(context),
                  style: AppStyles.complaintTextStyle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'doctorDetails.reviewsTitle'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'doctorDetails.seeAll'.tr(context),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text('doctorDetails.reviewAuthor'.tr(context)),
              subtitle: Text('doctorDetails.reviewText'.tr(context)),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.star, color: Colors.amber), Text('5')],
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    IconData icon,
    String value,
    String labelKey,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(labelKey.tr(context)),
      ],
    );
  }
}
