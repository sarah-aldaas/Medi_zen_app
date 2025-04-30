import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/medical_record/pages/services_mixin.dart';

class SomeServices extends StatelessWidget with ServicesMixin {
  SomeServices({super.key});

  final Map<String, List<String>> servicesMap = {
    "Diagnostic Services": [
      "X-ray Imaging",
      "Magnetic Resonance Imaging (MRI)",
      "Blood Tests",
    ],
    "Therapeutic Services": [
      "Physical Therapy",
      "Speech Therapy",
      "Psychotherapy",
    ],
    "Emergency Services": ["Emergency Care", "First Aid Services", "Burn Care"],
    "Preventive Services": [
      "Child Vaccinations",
      "Adult Vaccinations",
      "Preventive Screenings",
    ],
    "Chronic Care Services": [
      "Diabetes Management",
      "Hypertension Care",
      "Heart Disease Care",
    ],
    "Community Services": [
      "Rehabilitation Therapy",
      "Nutritional Counseling",
      "Support Groups",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "servicesPage.title".tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: servicesMap.keys.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final serviceTitle = servicesMap.keys.elementAt(index);
            return GestureDetector(
              onTap: () {
                _showSubServicesDialog(context, serviceTitle);
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/default_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          serviceTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSubServicesDialog(BuildContext context, String serviceTitle) {
    final subServices = servicesMap[serviceTitle] ?? [];
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      serviceTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            subServices.map((service) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.panorama_fish_eye,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(child: Text(service)),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("close"),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
