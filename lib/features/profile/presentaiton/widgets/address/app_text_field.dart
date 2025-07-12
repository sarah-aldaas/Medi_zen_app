import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showClearIcon;
  final VoidCallback? onClear;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.validator,
    this.onChanged,
    this.showClearIcon = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: _buildSuffixIcon(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
  Widget? _buildSuffixIcon() {
    if (showClearIcon && controller.text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              onClear?.call();
            },
          ),
          if (suffixIcon != null)
            IconButton(
              icon: Icon(suffixIcon),
              onPressed: onTap,
            ),
        ],
      );
    }
    return suffixIcon != null
        ? IconButton(
      icon: Icon(suffixIcon),
      onPressed: onTap,
    )
        : null;
  }
}