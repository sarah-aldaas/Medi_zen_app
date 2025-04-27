import 'package:flutter/material.dart';

import '../../../../base/theme/app_color.dart';

class ComplaintSubmitButton extends StatelessWidget {
  final Function() onPressed;

  ComplaintSubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        'Submit',
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
    );
  }
}
