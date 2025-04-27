import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../base/go_router/go_router.dart';

class RowIcons extends StatelessWidget {
  const RowIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.doctors.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const Center(child: Icon(Icons.ac_unit)))),
                  const Text("Doctors"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.articles.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const Center(child: Icon(Icons.article_outlined)))),
                  const Text("Articles"),
                ],
              ),
            ),
             Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                    child: Container(
                        padding: EdgeInsets.all(15),
                        child: Center(child: Icon(Icons.home_repair_service)))),
                Text("Services"),
              ],
            ),
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.helpCenter.name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child:
                          const Center(child: Icon(Icons.help_center_outlined)))),
                  const Text("Help center"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0), // Add some vertical spacing
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //      Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Card(
        //             child: Container(
        //                 padding: EdgeInsets.all(15),
        //                 child: Center(child: Icon(Icons.more_vert)))),
        //         Text("See more"),
        //       ],
        //     ),
        //     GestureDetector(
        //       onTap: () {
        //         context.pushNamed(AppRouter.helpCenter.name);
        //       },
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Card(
        //               child: Container(
        //                   padding: const EdgeInsets.all(15),
        //                   child:
        //                   const Center(child: Icon(Icons.help_center_outlined)))),
        //           const Text("Help center"),
        //         ],
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: () {
        //         context.pushNamed(AppRouter.helpCenter.name);
        //       },
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Card(
        //               child: Container(
        //                   padding: const EdgeInsets.all(15),
        //                   child:
        //                   const Center(child: Icon(Icons.help_center_outlined)))),
        //           const Text("Help center"),
        //         ],
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: () {
        //         context.pushNamed(AppRouter.helpCenter.name);
        //       },
        //       child: Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Card(
        //               child: Container(
        //                   padding: const EdgeInsets.all(15),
        //                   child:
        //                   const Center(child: Icon(Icons.help_center_outlined)))),
        //           const Text("Help center"),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}