import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/invoice/presentation/cubit/invoice_cubit/invoice_cubit.dart';
import 'package:medizen_app/features/invoice/data/models/invoice_model.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Invoice Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            return _buildInvoiceDetails(state.invoice, isDarkMode, theme);
          }

          // Load invoice details when page first loads
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

  Widget _buildInvoiceDetails(InvoiceModel invoice, bool isDarkMode, ThemeData theme) {
    final isPaid = invoice.status?.code == 'paid';
    final dateFormat = DateFormat('dd MMM yyyy');
    final cardColor = isDarkMode ? theme.cardColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Invoice header with status
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
                      'INVOICE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status?.code)
                            ?.withOpacity(isDarkMode ? 0.3 : 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(invoice.status?.code) ??
                              Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        invoice.status?.display ?? 'N/A',
                        style: TextStyle(
                          color: _getStatusColor(invoice.status?.code) ??
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
                          'Invoice #${invoice.id ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Issued: ${dateFormat.format(DateTime.now())}',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    if (isPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(isDarkMode ? 0.3 : 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'PAID',
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

          // Practitioner details
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
                  'BILLED BY',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (invoice.practitioner != null) ...[
                  Text(
                    '${invoice.practitioner!.prefix} ${invoice.practitioner!.fName} ${invoice.practitioner!.lName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.practitioner!.email,
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                  if (invoice.practitioner!.clinic != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      invoice.practitioner!.clinic!.name,
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Financial details
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
                      flex: 3,
                      child: Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
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
                      flex: 3,
                      child: Text(
                        'Medical Consultation',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
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
                        flex: 3,
                        child: Text(
                          'Adjustment Factor',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
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
                      flex: 3,
                      child: Text(
                        'TOTAL',
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
                    'NOTES',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.note!,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (invoice.cancelledReason != null && invoice.cancelledReason!.isNotEmpty) ...[
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
                    'CANCELLATION REASON',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.cancelledReason!,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          // Action buttons
          // if (!isPaid) ...[
          //   Row(
          //     children: [
          //       Expanded(
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: theme.primaryColor,
          //             padding: const EdgeInsets.symmetric(vertical: 16),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //           ),
          //           onPressed: () {
          //             // Handle pay now action
          //           },
          //           child: const Text(
          //             'Pay Now',
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
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
}