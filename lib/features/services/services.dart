import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/features/medical_record/pages/services_mixin.dart';

class SomeServices extends StatelessWidget with ServicesMixin {
  SomeServices({super.key});

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
        // ListView.separated(
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   itemCount: services.length,
        //   separatorBuilder: (context, index) => SizedBox(height: 8),
        //   itemBuilder: (context, index) {
        //     // final article = services[index];
        //     return GestureDetector(
        //       onTap: () {
        //         // Navigator.push(
        //         //   context,
        //         //   MaterialPageRoute(
        //         //     builder: (context) => ArticleDetailsPage(
        //         //       article: article,
        //         //     ),
        //         //   ),
        //         // );
        //       },
        //       child: Container(
        //         width: context.width,
        //         padding: EdgeInsets.only(
        //           top: 5,
        //           bottom: 5,
        //           left: 15,
        //           right: 15,
        //         ),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //         child: Row(
        //           children: [
        //             SizedBox(
        //               width: 100,
        //               height: 100,
        //               child: ClipRRect(
        //                 borderRadius: BorderRadius.circular(10),
        //                 child: Image.asset(article.imageUrl, fit: BoxFit.fill),
        //               ),
        //             ),
        //             SizedBox(width: 10),
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     article.title,
        //                     maxLines: 3,
        //                     overflow: TextOverflow.ellipsis,
        //                     style: TextStyle(fontWeight: FontWeight.bold),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
