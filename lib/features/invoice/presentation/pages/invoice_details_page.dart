import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/invoice/data/models/invoice_model.dart';
import 'package:medizen_app/features/invoice/presentation/cubit/invoice_cubit/invoice_cubit.dart';

import '../../../../base/theme/app_color.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final String appointmentId;
  final String invoiceId;

  const InvoiceDetailsPage({
    super.key,
    required this.appointmentId,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'invoiceDetailsPage.title'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<InvoiceCubit, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const LoadingPage();
          }

          if (state is InvoiceDetailsSuccess) {
            return _buildInvoiceDetails(
              context,
              state.invoice,
              isDarkMode,
              theme,
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<InvoiceCubit>().getInvoiceDetails(
              appointmentId: appointmentId,
              invoiceId: invoiceId,
              context: context,
            );
          });

          return const LoadingPage();
        },
      ),
    );
  }

  Widget _buildInvoiceDetails(
    BuildContext context,
    InvoiceModel invoice,
    bool isDarkMode,
    ThemeData theme,
  ) {
    final isPaid = invoice.status?.code == 'paid';
    final dateFormat = DateFormat('dd MMM yyyy');
    final cardColor = isDarkMode ? theme.cardColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'invoiceDetailsPage.invoiceHeader'.tr(context),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          invoice.status?.code,
                        )?.withOpacity(isDarkMode ? 0.3 : 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              _getStatusColor(invoice.status?.code) ??
                              Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getTranslatedStatus(invoice.status?.code, context),
                        style: TextStyle(
                          color:
                              _getStatusColor(invoice.status?.code) ??
                              Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'invoiceDetailsPage.invoiceNum'.tr(context)} #${invoice.id ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          '${'invoiceDetailsPage.issuedDate'.tr(context)}: ${dateFormat.format(DateTime.now())}',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ],
                    ),
                    if (isPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(
                            isDarkMode ? 0.3 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'invoiceDetailsPage.paidStatus'.tr(context),
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'invoiceDetailsPage.billedBy'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (invoice.practitioner != null) ...[
                  Text(
                    '${invoice.practitioner!.prefix} ${invoice.practitioner!.fName} ${invoice.practitioner!.lName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    invoice.practitioner!.email,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  if (invoice.practitioner!.clinic != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      invoice.practitioner!.clinic!.name,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'invoiceDetailsPage.descriptionHeader'.tr(context),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'invoiceDetailsPage.amountHeader'.tr(context),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'invoiceDetailsPage.medicalConsultation'.tr(context),
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        invoice.totalGross ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (invoice.factor != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'invoiceDetailsPage.adjustmentFactor'.tr(context),
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          invoice.factor!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'invoiceDetailsPage.totalHeader'.tr(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        invoice.totalNet ?? 'N/A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'invoiceDetailsPage.notesHeader'.tr(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.note!,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
          ],

          if (invoice.cancelledReason != null &&
              invoice.cancelledReason!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(isDarkMode ? 0.05 : 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'invoiceDetailsPage.cancellationReasonHeader'.tr(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.cancelledReason!,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color? _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'issued':
        return Colors.blue;
      default:
        return null;
    }
  }

  String _getTranslatedStatus(String? statusCode, BuildContext context) {
    switch (statusCode) {
      case 'paid':
        return 'invoiceDetailsPage.statusPaid'.tr(context);
      case 'cancelled':
        return 'invoiceDetailsPage.statusCancelled'.tr(context);
      case 'pending':
        return 'invoiceDetailsPage.statusPending'.tr(context);
      case 'issued':
        return 'invoiceDetailsPage.statusIssued'.tr(context);
      default:
        return 'invoiceDetailsPage.statusUnknown'.tr(context);
    }
  }
}
