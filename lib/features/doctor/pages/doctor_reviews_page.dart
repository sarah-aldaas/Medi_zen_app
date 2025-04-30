import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart'; // <== Added!

class DoctorReviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('doctorReviewsPage.title'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
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
                  _buildFilterButton('doctorReviewsPage.filters.all'.tr(context), true),
                  _buildFilterButton('doctorReviewsPage.filters.fiveStars'.tr(context), false),
                  _buildFilterButton('doctorReviewsPage.filters.fourStars'.tr(context), false),
                  _buildFilterButton('doctorReviewsPage.filters.threeStars'.tr(context), false),
                  _buildFilterButton('doctorReviewsPage.filters.twoStars'.tr(context), false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_1',
              name: 'Charolette Hanlin',
              rating: 5,
              review: 'doctorReviewsPage.reviews.review1'.tr(context),
              daysAgo: 'doctorReviewsPage.reviews.daysAgo'.tr(context),
              likes: 938,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_2',
              name: 'Darron Kulikowski',
              rating: 4,
              review: 'doctorReviewsPage.reviews.review2'.tr(context),
              daysAgo: 'doctorReviewsPage.reviews.daysAgo'.tr(context),
              likes: 863,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_3',
              name: 'Lauralee Quintero',
              rating: 4,
              review: 'doctorReviewsPage.reviews.review3'.tr(context),
              daysAgo: 'doctorReviewsPage.reviews.daysAgo'.tr(context),
              likes: 629,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_4',
              name: 'Aileen Fullbright',
              rating: 5,
              review: 'doctorReviewsPage.reviews.review4'.tr(context),
              daysAgo: 'doctorReviewsPage.reviews.daysAgo'.tr(context),
              likes: 553,
            ),
            _buildReviewTile(
              imageUrl: 'YOUR_IMAGE_URL_5',
              name: 'Rodolfo Goode',
              rating: 4,
              review: 'doctorReviewsPage.reviews.review5'.tr(context),
              daysAgo: 'doctorReviewsPage.reviews.daysAgo'.tr(context),
              likes: 487,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(width: 8),
          Row(
            children: List.generate(
              rating,
                  (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
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
              const SizedBox(width: 4),
              Text(daysAgo),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.more_horiz),
    );
  }
}
