import 'package:flutter/material.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';

class ComplaintItem extends StatelessWidget {
  final Map<String, String> complaint;

  ComplaintItem({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.0),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  complaint['doctorName']!,
                  style: AppStyles.titleStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47BD93),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      'Cancel complaint',
                      style:
                          TextStyle(color: AppColors.whiteColor, fontSize: 15),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47BD93),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      'View details',
                      style:
                          TextStyle(color: AppColors.whiteColor, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
