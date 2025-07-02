import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/appointment/data/models/appointment_model.dart';
import 'package:medizen_app/features/invoice/presentation/cubit/invoice_cubit/invoice_cubit.dart';

import '../../data/models/invoice_filter_model.dart';
import '../widgets/invoice_filter_dialog.dart';
import 'invoice_details_page.dart';

class MyAppointmentFinishedInvoicePage extends StatefulWidget {
  const MyAppointmentFinishedInvoicePage({super.key});

  @override
  _MyAppointmentFinishedInvoicePageState createState() =>
      _MyAppointmentFinishedInvoicePageState();
}

class _MyAppointmentFinishedInvoicePageState
    extends State<MyAppointmentFinishedInvoicePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _paidScrollController = ScrollController();
  final ScrollController _unpaidScrollController = ScrollController();
  bool _isLoadingMorePaid = false;
  bool _isLoadingMoreUnpaid = false;
  late TabController _tabController;
  InvoiceFilterModel _paidFilter = InvoiceFilterModel(paidAppointment: true);
  InvoiceFilterModel _unpaidFilter = InvoiceFilterModel(paidAppointment: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paidScrollController.addListener(() => _scrollListener(true));
    _unpaidScrollController.addListener(() => _scrollListener(false));
    _loadInitialAppointments();
  }

  @override
  void dispose() {
    _paidScrollController.dispose();
    _unpaidScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialAppointments() {
    context.read<InvoiceCubit>().getFinishedAppointments(
      context: context,
      filters: _paidFilter.toJson(),
      isPaid: true,
    );

    context.read<InvoiceCubit>().getFinishedAppointments(
      context: context,
      filters: _unpaidFilter.toJson(),
      isPaid: false,
    );
  }

  void _scrollListener(bool isPaidTab) {
    final controller =
        isPaidTab ? _paidScrollController : _unpaidScrollController;
    final isLoadingMore = isPaidTab ? _isLoadingMorePaid : _isLoadingMoreUnpaid;
    final cubit = context.read<InvoiceCubit>();

    if (controller.position.pixels == controller.position.maxScrollExtent &&
        !isLoadingMore) {
      setState(() {
        if (isPaidTab) {
          _isLoadingMorePaid = true;
        } else {
          _isLoadingMoreUnpaid = true;
        }
      });

      cubit
          .getFinishedAppointments(
            filters: isPaidTab ? _paidFilter.toJson() : _unpaidFilter.toJson(),
            loadMore: true,
            context: context,
            isPaid: isPaidTab,
          )
          .then((_) {
            setState(() {
              if (isPaidTab) {
                _isLoadingMorePaid = false;
              } else {
                _isLoadingMoreUnpaid = false;
              }
            });
          });
    }
  }

  Future<void> _showFilterDialog(bool isPaidTab) async {
    final currentFilter = isPaidTab ? _paidFilter : _unpaidFilter;
    final result = await showDialog<InvoiceFilterModel>(
      context: context,
      builder: (context) => InvoiceFilterDialog(currentFilter: currentFilter),
    );

    if (result != null) {
      setState(() {
        if (isPaidTab) {
          _paidFilter = result;
        } else {
          _unpaidFilter = result;
        }
      });

      context.read<InvoiceCubit>().getFinishedAppointments(
        filters: result.toJson(),
        context: context,
        isPaid: isPaidTab,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "invoicesPage.title".tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "invoicesPage.paidAppointmentsTab".tr(context),
            ),
            Tab(
              text: "invoicesPage.unpaidAppointmentsTab".tr(context),
            ),
          ],
          labelColor: AppColors.primaryColor,
          indicatorColor: AppColors.primaryColor,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: () => _showFilterDialog(_tabController.index == 0),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(isPaid: true),
          _buildAppointmentsList(isPaid: false),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList({required bool isPaid}) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        final appointments =
            isPaid
                ? (state is InvoiceAppointmentsSuccess
                    ? state.paidAppointments
                    : [])
                : (state is InvoiceAppointmentsSuccess
                    ? state.unpaidAppointments
                    : []);

        final hasMore =
            isPaid
                ? (state is InvoiceAppointmentsSuccess
                    ? state.hasMorePaid
                    : false)
                : (state is InvoiceAppointmentsSuccess
                    ? state.hasMoreUnpaid
                    : false);

        final isLoading = state is InvoiceLoading;
        final isLoadingMore =
            isPaid ? _isLoadingMorePaid : _isLoadingMoreUnpaid;
        final isEmpty = appointments.isEmpty && !isLoading;

        if (isLoading && !isLoadingMore) {
          return const Center(child: LoadingPage());
        }

        if (isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  isPaid
                      ? "invoicesPage.noPaidAppointments".tr(
                        context,
                      )
                      : "invoicesPage.noUnpaidAppointments".tr(
                        context,
                      ),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: isPaid ? _paidScrollController : _unpaidScrollController,
          itemCount: appointments.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < appointments.length) {
              return _buildAppointmentItem(
                context,
                appointments[index],
              );
            } else if (hasMore) {
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildAppointmentItem(
    BuildContext context,
    AppointmentModel appointment,
  ) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => InvoiceDetailsPage(
                      appointmentId: appointment.id.toString(),
                      invoiceId: appointment.encounterModel!.invoice!.id!,
                    ),
              ),
            ).then((value) {
              _loadInitialAppointments();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("invoicesPage.notPaidMessage".tr(context)),
              ),
            ); // Changed key
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            AppAssetImages.photoDoctor1,
                            height: 100,
                            width: 100,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctor!.prefix +
                                  appointment.doctor!.fName +
                                  " " +
                                  appointment.doctor!.lName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.date_range_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  DateFormat('yyyy-M-d').format(
                                    DateTime.parse(appointment.startDate!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  DateFormat('hh:mma').format(
                                    DateTime.parse(appointment.startDate!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
