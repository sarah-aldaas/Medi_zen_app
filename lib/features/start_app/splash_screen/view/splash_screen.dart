
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/constant/storage_key.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/services/storage/storage_service.dart';
import 'package:medizen_app/base/theme/app_color.dart';

import '../../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  bool _isFirstLaunch = true;
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();


    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _heartbeatAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.25,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 45,
      ),
    ]).animate(_heartbeatController);
    _checkFirstLaunchAndPatient();


    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
        _heartbeatController.repeat(reverse: true);
      }
    });

    _navigationTimer = Timer(const Duration(seconds: 5), _navigate);
  }

  Future<void> _checkFirstLaunchAndPatient() async {
    final isFirst =
        serviceLocator<StorageService>().getFromDisk(StorageKey.firstInstall) ??
        true;

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirst;
      });
    }
  }

  void _navigate() {
    if (!mounted) return;

    if (_isFirstLaunch) {
      context.goNamed(AppRouter.onBoarding.name);
    } else {
      if (token != null) {
        context.goNamed(AppRouter.homePage.name);
      } else {
        context.goNamed(AppRouter.login.name);
      }
    }
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundLogo,
      body: Center(
        child: AnimatedBuilder(
          animation: _heartbeatAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _heartbeatAnimation.value,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        AppAssetImages.logoGreenPng,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // const SizedBox(height: 20),
                    //
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'M',
                    //     style: TextStyle(
                    //       color: Theme.of(context).primaryColor,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 20,
                    //       fontFamily: 'ChypreNorm',
                    //     ),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //         text: 'edi',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.normal,
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: 'Z',
                    //         style: TextStyle(
                    //           color: Theme.of(context).primaryColor,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: 'en',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.normal,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
