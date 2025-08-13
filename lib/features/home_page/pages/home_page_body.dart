import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:medizen_app/features/authentication/data/models/patient_model.dart';
import 'package:medizen_app/features/home_page/pages/widgets/definition_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/greeting_widget.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_articles.dart';
import 'package:medizen_app/features/home_page/pages/widgets/some_clinics.dart';
import 'package:medizen_app/features/notifications/presentation/cubit/notification_cubit/notification_cubit.dart';
import 'package:medizen_app/features/notifications/presentation/pages/notification_page.dart';

import '../../../base/constant/storage_key.dart';
import '../../../base/services/di/injection_container_common.dart';
import '../../../base/services/storage/storage_service.dart';
import '../../../base/theme/app_color.dart';
import '../../../main.dart';
import '../../authentication/presentation/logout/cubit/logout_cubit.dart';
import '../../complains/presentation/pages/complain_list_page.dart';
import '../../invoice/presentation/pages/my_appointment_finished_invoice_page.dart';
import '../../steps/steps_screen.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final String clinicId = "1";
  int? _selectedLogoutOption;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showExitConfirmationDialog(context);
        if (shouldPop) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SomeClinics(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DefinitionWidget(),
                ),
                Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SimpleArticlesPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: Text(
                  'homePage.confirm_exit'.tr(context),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                content: Text('homePage.sure_want'.tr(context)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('homePage.no'.tr(context)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('homePage.yes'.tr(context)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildHeader(BuildContext context) {
    PatientModel? myPatientModel = loadingPatientModel();
    final ThemeData theme = Theme.of(context);
    context.read<NotificationCubit>().getMyNotifications(context: context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 20, left: 16, right: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.profile.name);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: FlexibleImage(
                        imageUrl: myPatientModel.avatar,
                        assetPath: "assets/images/person.jpg",
                      ),
                    ),
                    radius: 20,
                  ),

                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingWidget(),
                      Text(
                        "${myPatientModel.fName.toString()} ${myPatientModel.lName.toString()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: theme.iconTheme.color,
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 8,
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      final unreadCount =
                          state is NotificationSuccess
                              ? state.paginatedResponse.paginatedData?.items
                                      .where((n) => !n.isRead)
                                      .length ??
                                  0
                              : 0;

                      if (unreadCount == 0) return SizedBox.shrink();

                      return Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),

            color: theme.scaffoldBackgroundColor,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onSelected: (String value) {
              if (value == 'services') {
                context.pushNamed(AppRouter.healthCareServicesPage.name);
              } else if (value == 'invoice') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAppointmentFinishedInvoicePage(),
                  ),
                );
              } else if (value == 'complain') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplainListPage()),
                );
              }else if (value == 'step') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepsScreen()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'services',
                    child: ListTile(
                      leading: Icon(
                        Icons.health_and_safety,
                        color: Theme.of(context).primaryColor,
                      ),

                      title: Text(
                        'homePage.health_services'.tr(context),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),

                  PopupMenuItem<String>(
                    value: 'invoice',
                    child: ListTile(
                      leading: Icon(
                        Icons.paid,
                        color: Theme.of(context).primaryColor,
                      ),

                      title: Text(
                        'homePage.invoices'.tr(context),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'complain',
                    child: ListTile(
                      leading: Icon(
                        Icons.feedback,
                        color: Theme.of(context).primaryColor,
                      ),

                      title: Text(
                        'homePage.complaints'.tr(context),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'step',
                    child: ListTile(
                      leading: Icon(
                        Icons.feedback,
                        color: Theme.of(context).primaryColor,
                      ),

                      title: Text(
                        "steps",
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'complain',
                    child: BlocConsumer<LogoutCubit, LogoutState>(
                      listener: (context, state) {
                        if (state is LogoutSuccess) {
                          context.goNamed(AppRouter.welcomeScreen.name);
                        } else if (state is LogoutError) {
                          _selectedLogoutOption = null;
                          serviceLocator<StorageService>().removeFromDisk(
                            StorageKey.patientModel,
                          );
                          context.goNamed(AppRouter.welcomeScreen.name);
                        }
                      },
                      builder: (context, state) {
                        return ExpansionTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'profilePage.logout'.tr(context),
                            style: TextStyle(color: Colors.red),
                          ),
                          children: [
                            RadioListTile<int>(
                              title:
                                  state is LogoutLoadingOnlyThisDevice
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'profilePage.logoutThisDevice'.tr(
                                              context,
                                            ),
                                          ),
                                          SizedBox(width: 10),

                                          LoadingAnimationWidget.hexagonDots(
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 25,
                                          ),
                                        ],
                                      )
                                      : Text(
                                        'profilePage.logoutThisDevice'.tr(
                                          context,
                                        ),
                                        style: TextStyle(color: Colors.red),
                                      ),
                              value: 0,
                              groupValue: _selectedLogoutOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLogoutOption = value;
                                });
                                context.read<LogoutCubit>().sendResetLink(
                                  0,
                                  context,
                                );
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                            RadioListTile<int>(
                              title:
                                  state is LogoutLoadingAllDevices
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'profilePage.logoutAllDevices'.tr(
                                              context,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          LoadingAnimationWidget.hexagonDots(
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 25,
                                          ),
                                        ],
                                      )
                                      : Text(
                                        'profilePage.logoutAllDevices'.tr(
                                          context,
                                        ),
                                        style: TextStyle(color: Colors.red),
                                      ),
                              value: 1,
                              groupValue: _selectedLogoutOption,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLogoutOption = value;
                                });
                                context.read<LogoutCubit>().sendResetLink(
                                  1,
                                  context,
                                );
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}
