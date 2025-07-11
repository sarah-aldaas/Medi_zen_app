import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/appointment/pages/widgets/cancel_appointment_dialog.dart';
import 'package:medizen_app/features/appointment/pages/widgets/filter_appointment_dialog.dart';
import 'package:medizen_app/features/appointment/pages/widgets/update_appointment_page.dart';
import 'package:shimmer/shimmer.dart';

import '../data/models/appointment_filter.dart';
import 'cubit/appointment_cubit/appointment_cubit.dart';

class MyAppointmentPage extends StatefulWidget {
  const MyAppointmentPage({super.key});

  @override
  _MyAppointmentPageState createState() => _MyAppointmentPageState();
}

class _MyAppointmentPageState extends State<MyAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  AppointmentFilter _filter = AppointmentFilter();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialAppointments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAppointments() {
    _isLoadingMore = false;
    context.read<AppointmentCubit>().getMyAppointment(
      context: context,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<AppointmentCubit>()
          .getMyAppointment(
            filters: _filter.toJson(),
            loadMore: true,
            context: context,
          )
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AppointmentFilter>(
      context: context,
      builder: (context) => AppointmentFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pushReplacementNamed(AppRouter.homePage.name);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "myAppointments.title".tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () {
              context.pushNamed(AppRouter.clinics.name).then((value) {
                _loadInitialAppointments();
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AppointmentLoading && !state.isLoadMore) {
            return _buildShimmerLoader();
          }

          final appointments =
              state is AppointmentSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore = state is AppointmentSuccess ? state.hasMore : false;
          if (appointments.isEmpty) {
            return NotFoundDataPage();
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: appointments.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < appointments.length) {
                return _buildAppointmentItem(appointments[index]);
              } else if (hasMore && state is! AppointmentError) {
                return Center(child: LoadingButton());
              }
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap:
            () => context
                .pushNamed(
                  AppRouter.appointmentDetails.name,
                  extra: {"appointmentId": appointment.id.toString()},
                )
                .then((value) {
                  _loadInitialAppointments();
                }),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 10,
                  ),
                  child: Row(
                    spacing: 10,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FlexibleImage(
                            imageUrl: appointment.doctor!.avatar,
                            assetPath: AppAssetImages.photoDoctor1,
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ),
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctor!.prefix +
                                appointment.doctor!.fName +
                                " " +
                                appointment.doctor!.lName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(
                                Icons.date_range_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              Text(
                                DateFormat('yyyy-M-d').format(
                                  DateTime.parse(appointment.startDate!),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              Text(
                                DateFormat('hh:mma').format(
                                  DateTime.parse(appointment.startDate!),
                                ),
                              ),
                            ],
                          ),
                          // Text(DateFormat('yyyy-M-d / hh:mma').format(DateTime.parse(appointment.startDate!))),
                          Row(
                            spacing: 20,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  appointment.status!.display,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              if (appointment.status!.code ==
                                  "canceled_appointment")
                                Icon(Icons.block, color: Colors.red),
                              if (appointment.status!.code ==
                                  "finished_appointment")
                                Icon(Icons.check, color: Colors.green),
                              if (appointment.status!.code ==
                                  "booked_appointment")
                                Icon(Icons.timelapse, color: Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (appointment.status!.code == 'booked_appointment') ...[
                  const Gap(30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => _cancelAppointment(appointment),
                          child: Text(
                            "myAppointments.buttons.cancelAppointment".tr(
                              context,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),

                        ElevatedButton(
                          onPressed:
                              () => _editAppointment(context, appointment),
                          child: Text(
                            "myAppointments.buttons.update".tr(context),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) =>
              CancelAppointmentDialog(appointmentId: appointment.id.toString()),
    );

    if (reason != null && reason.isNotEmpty) {
      await context.read<AppointmentCubit>().cancelAppointment(
        context: context,
        id: appointment.id.toString(),
        cancellationReason: reason,
      );
      _loadInitialAppointments();
    }
  }

  void _editAppointment(BuildContext context, AppointmentModel appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UpdateAppointmentPage(
              appointmentId: appointment.id.toString(),
              initialReason: appointment.reason ?? '',
              initialDescription: appointment.description ?? '',
              initialNote: appointment.note ?? '',
            ),
      ),
    ).then((success) {
      if (success) {
        _loadInitialAppointments();
        ShowToast.showToastSuccess(
          message: 'appointmentDetails.updateSuccess'.tr(context),
        );
      }
      if (!success) {
        _loadInitialAppointments();
      }
    });
  }

  Widget _buildShimmerLoader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[100]!;
    final containerColor = isDarkMode ? Colors.grey[700]! : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,

      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Doctor details column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Doctor name
                              Container(
                                width: 150,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Date row
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: containerColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 100,
                                    height: 16,
                                    color: containerColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Time row
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: containerColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 80,
                                    height: 16,
                                    color: containerColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Status
                              Container(
                                width: 100,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Buttons (only for some items)
                    if (index % 2 == 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 120,
                            height: 36,
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 36,
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
