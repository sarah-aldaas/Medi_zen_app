import 'package:flutter/material.dart';

class MyFavoriteDoctorPage extends StatefulWidget {
  @override
  _MyFavoriteDoctorPageState createState() => _MyFavoriteDoctorPageState();
}

class _MyFavoriteDoctorPageState extends State<MyFavoriteDoctorPage> {
  int _selectedFilter = 0; // 0 for All, 1 for General, etc.

  List<Doctor> _doctors = [
    Doctor(
      imageUrl: 'YOUR_IMAGE_URL_1', // Replace with your image URL
      name: 'Dr. Travis Westaby',
      specialty: 'Cardiologists',
      hospital: 'Alka Hospital',
      rating: 4.3,
      reviews: 5376,
    ),
    Doctor(
      imageUrl: 'YOUR_IMAGE_URL_2', // Replace with your image URL
      name: 'Dr. Nathaniel Valle',
      specialty: 'Cardiologists',
      hospital: 'B & B Hospital',
      rating: 4.6,
      reviews: 3837,
    ),
    // Add more doctors here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorite Doctor'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('All', 0),
                _buildFilterButton('General', 1),
                _buildFilterButton('Dentist', 2),
                _buildFilterButton('Nutritionist', 3),
                // Add more filters as needed...
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredDoctors().length,
        itemBuilder: (context, index) {
          return _buildDoctorItem(_filteredDoctors()[index]);
        },
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedFilter == index ? Colors.blue : Colors.grey[300],
          foregroundColor: _selectedFilter == index ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        )
      ),
    );
  }

  Widget _buildDoctorItem(Doctor doctor) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(doctor.imageUrl),
          ),
          title: Text(
            doctor.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${doctor.specialty} | ${doctor.hospital}'),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.blue),
                  Text('${doctor.rating} (${doctor.reviews} reviews)'),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              _showRemoveDialog(context, doctor);
            },
          ),
          onTap: () {
            // Navigate to doctor details
          },
        ),
        Divider(),
      ],
    );
  }

  List<Doctor> _filteredDoctors() {
    if (_selectedFilter == 0) {
      return _doctors; // Show all doctors
    } else {
      // Filter based on selected filter (you'll need to implement this logic)
      return _doctors
          .where((doctor) =>
      doctor.specialty.toLowerCase() ==
          _getFilterText(_selectedFilter).toLowerCase())
          .toList();
    }
  }

  String _getFilterText(int index) {
    switch (index) {
      case 1:
        return 'General';
      case 2:
        return 'Dentist';
      case 3:
        return 'Nutritionist';
      default:
        return '';
    }
  }

  void _showRemoveDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove from Favorites?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                title: Text(
                  doctor.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${doctor.specialty} | ${doctor.hospital}'),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.blue),
                        Text('${doctor.rating} (${doctor.reviews} reviews)'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _doctors.remove(doctor); // Remove from list
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes, Remove'),
            ),
          ],
        );
      },
    );
  }
}

class Doctor {
  final String imageUrl;
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviews;

  Doctor({
    required this.imageUrl,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
  });
}