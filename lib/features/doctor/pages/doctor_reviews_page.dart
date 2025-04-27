import 'package:flutter/material.dart';

class DoctorReviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('4.8 (4,942 reviews)'),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', true),
                  _buildFilterButton('★ 5', false),
                  _buildFilterButton('★ 4', false),
                  _buildFilterButton('★ 3', false),
                  _buildFilterButton('★ 2', false),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_1', // Replace with your image URL
              name: 'Charolette Hanlin',
              rating: 5,
              review: 'Dr. Jenny is very professional in her work and responsive. I have consulted and my problem is solved. 👍👍',
              daysAgo: '6 days ago',
              likes: 938,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_2', // Replace with your image URL
              name: 'Darron Kulikowski',
              rating: 4,
              review: 'The doctor is very beautiful and the service is excellent! I like it and want to consult again. 🥰🥰',
              daysAgo: '6 days ago',
              likes: 863,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_3', // Replace with your image URL
              name: 'Lauralee Quintero',
              rating: 4,
              review: 'Doctors who are very skilled and fast in service. I highly recommend Dr. Jenny for all who want to consult. 🙏🙏',
              daysAgo: '6 days ago',
              likes: 629,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_4', // Replace with your image URL
              name: 'Aileen Fullbright',
              rating: 5,
              review: 'Doctors who are very skilled and fast in service. My illness is cured, thank you very much! 😇',
              daysAgo: '6 days ago',
              likes: 553,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_5', // Replace with your image URL
              name: 'Rodolfo Goode',
              rating: 4,
              review: 'Dr. Jenny is very professional in her work and responsive. I have consulted and my problem is solved. 🙏🙏',
              daysAgo: '6 days ago',
              likes: 487,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildReviewTile({
    required String imageUrl,
    required String name,
    required int rating,
    required String review,
    required String daysAgo,
    required int likes,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Row(
        children: [
          Text(name),
          SizedBox(width: 8),
          Row(
            children: List.generate(
              rating,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 16),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review),
          Row(
            children: [
              Text('$likes'),
              SizedBox(width: 4),
              Text(daysAgo),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.more_horiz),
    );
  }
}