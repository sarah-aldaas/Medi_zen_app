import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../services/di/injection_container_common.dart';
import '../services/network/network_info.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  final networkInfo = serviceLocator<NetworkInfo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: context.width,
        height: context.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/no_internet.png",
              fit: BoxFit.contain,
              height: context.height * 0.4,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your network and try again.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final isConnected = await networkInfo.isConnected;
                if (isConnected) {
                   context.pop(); // Navigate back to previous screen
                } else {
                  ShowToast.showToastError(message: 'Still no internet connection');
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}