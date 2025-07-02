import 'package:flutter/material.dart';

import '../../../../base/theme/app_color.dart';

class ComplaintTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;

  ComplaintTextField({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(8.0),
      child: TextField(
        maxLines: 5,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
