
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../base/services/di/injection_container_common.dart';
import 'cubit/otp_cubit.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isOtpLocked = false;

  @override
  void initState() {
    super.initState();
    serviceLocator<OtpCubit>().startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<OtpCubit>(),
      child: WillPopScope(
        onWillPop: () async => !_isOtpLocked,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              "otp_verification_page.title".tr(context),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: BlocConsumer<OtpCubit, OtpState>(
              listener: (context, state) {
                if (state is OtpSuccess) {
                  context.goNamed(AppRouter.verified.name);
                } else if (state is OtpResendSuccess) {
                  ShowToast.showToastSuccess(message: state.message);
                } else if (state is OtpError) {
                  ShowToast.showToastError(message: state.error);
                  setState(() {
                    _isOtpLocked = false;
                  });
                }
              },
              builder: (context, state) {
                bool isLoadingVerify = state is OtpLoadingVerify;

                return GestureDetector(
                  onTap: () {
                    if (!_isOtpLocked) {
                      FocusScope.of(context).requestFocus(_otpFocusNode);
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: context.width,
                          height: context.height / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/locks/111.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "otp_verification_page.enter_otp".tr(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "otp_verification_page.sent_to".tr(context) + widget.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AbsorbPointer(
                          absorbing: _isOtpLocked,
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            keyboardType: _isOtpLocked ? TextInputType.none : TextInputType.number,
                            inputFormatters: _isOtpLocked
                                ? []
                                : [FilteringTextInputFormatter.digitsOnly],
                            autoDismissKeyboard: true,
                            autoFocus: false,
                            enabled: !_isOtpLocked,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(8),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: Theme.of(context).scaffoldBackgroundColor,
                              inactiveFillColor: Theme.of(context).scaffoldBackgroundColor,
                              selectedFillColor: Theme.of(context).scaffoldBackgroundColor,
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Colors.grey,
                              selectedColor: Theme.of(context).primaryColor,
                            ),
                            animationType: AnimationType.fade,
                            animationDuration: const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            onChanged: (value) {
                              if (!_isOtpLocked && value.length == 6) {
                                FocusScope.of(context).unfocus();
                                setState(() => _isOtpLocked = true);
                                context.read<OtpCubit>().verifyOtp(
                                  email: widget.email,
                                  otp: value,
                                  context: context,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoadingVerify
                              ? null
                              : () {
                            if (_otpController.text.length == 6) {
                              setState(() => _isOtpLocked = true);
                              context.read<OtpCubit>().verifyOtp(
                                email: widget.email,
                                otp: _otpController.text,
                                context: context,
                              );
                            } else {
                              ShowToast.showToastError(
                                message: "otp_verification_page.invalid_otp_error".tr(context),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.width / 3,
                              vertical: 12,
                            ),
                          ),
                          child: isLoadingVerify
                              ? LoadingButton(isWhite: true)
                              : Text(
                            "otp_verification_page.verify".tr(context),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        BlocSelector<OtpCubit, OtpState, (bool, int)>(
                          selector: (state) {
                            if (state is OtpTimerRunning) {
                              return (true, state.seconds);
                            }
                            return (false, 0);
                          },
                          builder: (context, timerState) {
                            final isTimerRunning = timerState.$1;
                            final secondsRemaining = timerState.$2;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isTimerRunning
                                      ? "otp_verification_page.resend_otp_in".tr(context) +
                                      ' ${_formatTime(secondsRemaining)}'
                                      : "otp_verification_page.didnt_receive_otp".tr(context),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (!isTimerRunning)
                                  TextButton(
                                    onPressed: () {
                                      context.read<OtpCubit>().resendOtp(
                                        email: widget.email,
                                        context: context,
                                      );
                                    },
                                    child: state is OtpLoadingResend
                                        ? LoadingAnimationWidget.hexagonDots(
                                      color: Theme.of(context).primaryColor,
                                      size: 25,
                                    )
                                        : Text(
                                      "otp_verification_page.resend_otp".tr(context),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
// import 'package:medizen_app/base/extensions/media_query_extension.dart';
// import 'package:medizen_app/base/go_router/go_router.dart';
// import 'package:medizen_app/base/widgets/loading_page.dart';
// import 'package:medizen_app/base/widgets/show_toast.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import '../../../../base/services/di/injection_container_common.dart';
// import 'cubit/otp_cubit.dart';
//
// class OtpVerificationScreen extends StatefulWidget {
//   final String email;
//
//   const OtpVerificationScreen({super.key, required this.email});
//
//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }
//
// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   final FocusNode _otpFocusNode = FocusNode();
//   bool _isOtpLocked = false;
//
//   @override
//   void initState() {
//     super.initState();
//     serviceLocator<OtpCubit>().startTimer();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => serviceLocator<OtpCubit>(),
//       child: WillPopScope(
//         onWillPop: () async => !_isOtpLocked,
//         child: Scaffold(
//           appBar: AppBar(
//             centerTitle: true,
//             backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//             title: Text(
//               "otp_verification_page.title".tr(context),
//               style: TextStyle(
//                 color: Theme.of(context).primaryColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
// // <<<<<<< HEAD
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: BlocConsumer<OtpCubit, OtpState>(
// //             listener: (context, state) {
// //               if (state is OtpSuccess) {
// //                 context.goNamed(AppRouter.verified.name);
// //               } else if (state is OtpResendSuccess) {
// //                 ShowToast.showToastSuccess(message: state.message);
// //               } else if (state is OtpError) {
// //                 ShowToast.showToastError(message: state.error);
// //               }
// //             },
// //             builder: (context, state) {
// //               bool isLoadingVerify = state is OtpLoadingVerify;
// //               return SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     SizedBox(
// //                       width: context.width,
// //                       height: context.height / 2,
// //                       child: Image.asset(
// //                         "assets/images/locks/111.png",
// //                         fit: BoxFit.fill,
// //                       ),
// //                     ),
// //                     Text(
// //                       "otp_verification_page.enter_otp".tr(context),
// //                       style: const TextStyle(fontSize: 16),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     Text(
// //                       "otp_verification_page.sent_to".tr(context) +
// //                           widget.email,
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Theme.of(context).primaryColor,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     PinCodeTextField(
// //                       appContext: context,
// //                       length: 6,
// //                       controller: _otpController,
// //                       enabled: !isLoadingVerify,
// //                       keyboardType: TextInputType.number,
// //                       pinTheme: PinTheme(
// //                         shape: PinCodeFieldShape.box,
// //                         borderRadius: BorderRadius.circular(8),
// //                         fieldHeight: 50,
// //                         fieldWidth: 40,
// //                         activeFillColor:
// //                             Theme.of(context).scaffoldBackgroundColor,
// //                         inactiveFillColor:
// //                             Theme.of(context).scaffoldBackgroundColor,
// //                         selectedFillColor:
// //                             Theme.of(context).scaffoldBackgroundColor,
// //                         activeColor: Theme.of(context).primaryColor,
// //                         inactiveColor: Colors.grey,
// //                         selectedColor: Theme.of(context).primaryColor,
// //                       ),
// //                       animationType: AnimationType.fade,
// //                       animationDuration: const Duration(milliseconds: 300),
// //                       enableActiveFill: true,
// //                       onChanged: (value) {},
// //                     ),
// //                     const SizedBox(height: 20),
// //                     ElevatedButton(
// //                       onPressed:
// //                           isLoadingVerify
// //                               ? null
// //                               : () {
// //                                 if (_otpController.text.length == 6) {
// //                                   context.read<OtpCubit>().verifyOtp(
// //                                     email: widget.email,
// //                                     otp: _otpController.text,
// //                                     context: context,
// //                                   );
// //                                 } else {
// //                                   ShowToast.showToastError(
// //                                     message:
// //                                         "otp_verification_page.invalid_otp_error"
// //                                             .tr(context),
// //                                   );
// //                                 }
// //                               },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Theme.of(context).primaryColor,
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: context.width / 3,
// //                           vertical: 12,
// // =======
//           body: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: BlocConsumer<OtpCubit, OtpState>(
//               listener: (context, state) {
//                 if (state is OtpSuccess) {
//                   context.goNamed(AppRouter.verified.name);
//                 } else if (state is OtpResendSuccess) {
//                   ShowToast.showToastSuccess(message: state.message);
//                 } else if (state is OtpError) {
//                   ShowToast.showToastError(message: state.error);
//                 }
//               },
//               builder: (context, state) {
//                 bool isLoadingVerify = state is OtpLoadingVerify;
//
//                 return GestureDetector(
//                   onTap: () {
//                     if (!_isOtpLocked) {
//                       FocusScope.of(context).requestFocus(_otpFocusNode);
//                     }
//                   },
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: context.width,
//                           height: context.height / 3,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.asset(
//                               "assets/images/locks/111.png",
//                               fit: BoxFit.cover,
//                             ),
//                           ),
// // >>>>>>> c804e45c3224c511626af6e9cbcb1dd2e908ee6d
//                         ),
//                         Text(
//                           "otp_verification_page.enter_otp".tr(context),
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "otp_verification_page.sent_to".tr(context) +
//                               widget.email,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         AbsorbPointer(
//                           absorbing: _isOtpLocked,
//                           child: PinCodeTextField(
//                             appContext: context,
//                             length: 6,
//                             controller: _otpController,
//                             focusNode: _otpFocusNode,
//                             keyboardType:
//                                 _isOtpLocked
//                                     ? TextInputType.none
//                                     : TextInputType.number,
//                             autoDismissKeyboard: false,
//                             autoFocus: true,
//                             enabled: !_isOtpLocked,
//                             pinTheme: PinTheme(
//                               shape: PinCodeFieldShape.box,
//                               borderRadius: BorderRadius.circular(8),
//                               fieldHeight: 50,
//                               fieldWidth: 40,
//                               activeFillColor:
//                                   Theme.of(context).scaffoldBackgroundColor,
//                               inactiveFillColor:
//                                   Theme.of(context).scaffoldBackgroundColor,
//                               selectedFillColor:
//                                   Theme.of(context).scaffoldBackgroundColor,
//                               activeColor: Theme.of(context).primaryColor,
//                               inactiveColor: Colors.grey,
//                               selectedColor: Theme.of(context).primaryColor,
//                             ),
//                             animationType: AnimationType.fade,
//                             animationDuration: const Duration(
//                               milliseconds: 300,
//                             ),
//                             enableActiveFill: true,
//                             onChanged: (value) {
//                               if (!_isOtpLocked && value.isNotEmpty) {
//                                 setState(() {
//                                   _isOtpLocked = true;
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed:
//                               isLoadingVerify
//                                   ? null
//                                   : () {
//                                     if (_otpController.text.length == 6) {
//                                       context.read<OtpCubit>().verifyOtp(
//                                         email: widget.email,
//                                         otp: _otpController.text,
//                                         context: context,
//                                       );
//                                     } else {
//                                       ShowToast.showToastError(
//                                         message:
//                                             "otp_verification_page.invalid_otp_error"
//                                                 .tr(context),
//                                       );
//                                     }
//                                   },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: context.width / 3,
//                               vertical: 12,
//                             ),
//                           ),
//                           child:
//                               isLoadingVerify
//                                   ? LoadingButton(isWhite: true)
//                                   : Text(
//                                     "otp_verification_page.verify".tr(context),
//                                     style: const TextStyle(color: Colors.white),
//                                   ),
//                         ),
//                         const SizedBox(height: 20),
//                         BlocSelector<OtpCubit, OtpState, (bool, int)>(
//                           selector: (state) {
//                             if (state is OtpTimerRunning) {
//                               return (true, state.seconds);
//                             }
//                             return (false, 0);
//                           },
//                           builder: (context, timerState) {
//                             final isTimerRunning = timerState.$1;
//                             final secondsRemaining = timerState.$2;
//                             return Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   isTimerRunning
//                                       ? "otp_verification_page.resend_otp_in"
//                                               .tr(context) +
//                                           ' ${_formatTime(secondsRemaining)}'
//                                       : "otp_verification_page.didnt_receive_otp"
//                                           .tr(context),
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 if (!isTimerRunning)
//                                   TextButton(
//                                     onPressed: () {
//                                       context.read<OtpCubit>().resendOtp(
//                                         email: widget.email,
//                                         context: context,
//                                       );
//                                     },
//                                     child:
//                                         state is OtpLoadingResend
//                                             ? LoadingAnimationWidget.hexagonDots(
//                                               color:
//                                                   Theme.of(
//                                                     context,
//                                                   ).primaryColor,
//                                               size: 25,
//                                             )
//                                             : Text(
//                                               "otp_verification_page.resend_otp"
//                                                   .tr(context),
//                                               style: TextStyle(
//                                                 color:
//                                                     Theme.of(
//                                                       context,
//                                                     ).primaryColor,
//                                               ),
//                                             ),
//                                   ),
//                               ],
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$secs';
//   }
// }
