import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class SearchField extends StatelessWidget {
  SearchField({super.key});

  final TextEditingController _searchController = TextEditingController();
  final double _opacityLevel = 0.6;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ThemeSwitcher.withTheme(
        builder: (_, switcher, theme) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  theme.brightness == Brightness.dark
                      ? Colors.black12
                      : Colors.grey.shade50,
              hintText: 'searchField.title'.tr(context),
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: _opacityLevel),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.withValues(alpha: _opacityLevel),
              ),
            ),
          );
        },
      ),
    );
  }
}
