import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/service_list_item.dart';

class EncounterDetailsPage extends StatefulWidget {
  final String encounterId;

  const EncounterDetailsPage({super.key, required this.encounterId});

  @override
  State<EncounterDetailsPage> createState() => _EncounterDetailsPageState();
}

class _EncounterDetailsPageState extends State<EncounterDetailsPage> {
  void _showCustomTooltip(BuildContext context, String message, Offset offset) {
    final OverlayState overlayState = Overlay.of(context);
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(offset);
    final screenWidth = MediaQuery.of(context).size.width;

    OverlayEntry overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx.clamp(10.0, screenWidth - 200),
            top: position.dy + 30,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.8,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message,
                    style: TextStyle(color: AppColors.whiteColor, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEncounterDetails();
  }

  void _loadEncounterDetails() {
    context.read<EncounterCubit>().getSpecificEncounter(
      encounterId: widget.encounterId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color onPrimaryAppColor = theme.colorScheme.onPrimary;
    final Color cardElevationColor = Colors.black.withOpacity(0.08);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'encountersPge.encounterDetails'.tr(context),
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primaryColor,
              ) ??
              TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: onPrimaryAppColor),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadEncounterDetails();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<EncounterCubit, EncounterState>(
          listener: (context, state) {
            if (state is EncounterError) {
              ShowToast.showToastError(
                message: '${'encountersPge.Error'.tr(context)}: ${state.error}',
              );
            }
          },
          builder: (context, state) {
            if (state is EncounterLoading) {
              return const Center(child: LoadingPage());
            } else if (state is EncounterDetailsSuccess) {
              return _buildEncounterDetails(
                context,
                state.encounterModel,
                cardElevationColor,
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 70,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'encountersPge.failedToLoad'.tr(context),
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEncounterDetails(
    BuildContext context,
    EncounterModel encounter,
    Color cardElevationColor,
  ) {
    final ThemeData theme = Theme.of(context);
    final Color primaryTextColor =
        theme.textTheme.titleLarge?.color ?? Colors.black87;
    final Color secondaryTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.grey.shade700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  encounter.reason ??
                      'encountersPge.generalEncounter'.tr(context),
                  style:
                      theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ) ??
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: primaryTextColor,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusChip(encounter.status, context),
            ],
          ),
          const SizedBox(height: 30),
          _buildInfoCard(
            context,
            title: 'encountersPge.basicInformation'.tr(context),
            icon: Icons.info_outline,
            cardElevationColor: cardElevationColor,
            children: [
              _buildDetailRow(
                context,
                label: 'encountersPge.type'.tr(context),
                value: encounter.type?.display,
                icon: Icons.category_outlined,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                tooltip: encounter.type?.description,
              ),
              _buildDetailRow(
                context,
                label: 'encountersPge.status'.tr(context),
                value: encounter.status?.display,
                icon: Icons.check_circle_outline,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              if (encounter.actualStartDate != null)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.startDate'.tr(context),
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualStartDate!)),
                  icon: Icons.calendar_today_outlined,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              if (encounter.actualEndDate != null)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.endDate'.tr(context),
                  value: DateFormat(
                    'MMM d, y - h:mm a',
                  ).format(DateTime.parse(encounter.actualEndDate!)),
                  icon: Icons.calendar_today_outlined,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              if (encounter.specialArrangement!=null)
                _buildDetailRow(
                  context,
                  label: 'encountersPge.specialNotes'.tr(context),
                  value: encounter.specialArrangement,
                  icon: Icons.notes_outlined,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (encounter.appointment != null) ...[
            GestureDetector(
              onTap: () {
                context
                    .pushNamed(
                      AppRouter.appointmentDetails.name,
                      extra: {"appointmentId": encounter.appointment!.id},
                    )
                    .then((value) {
                      context.read<EncounterCubit>().getSpecificEncounter(
                        encounterId: widget.encounterId,
                        context: context,
                      );
                    });
              },
              child: _buildInfoCard(
                context,
                title: 'encountersPge.appointmentDetails'.tr(context),
                icon: Icons.schedule_outlined,
                cardElevationColor: cardElevationColor,
                actionWidget: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.primaryColor.withOpacity(0.8),
                    size: 18,
                  ),
                ),
                children: [
                  _buildDetailRow(
                    context,
                    label: 'encountersPge.reason'.tr(context),
                    value: encounter.appointment?.reason,
                    icon: Icons.description_outlined,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  if (encounter.appointment?.startDate != null)
                    _buildDetailRow(
                      context,
                      label: 'encountersPge.scheduled'.tr(context),
                      value: DateFormat('MMM d, y - h:mm a').format(
                        DateTime.parse(encounter.appointment!.startDate!),
                      ),
                      icon: Icons.access_time_outlined,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  if (encounter.appointment?.doctor != null)
                    _buildDetailRow(
                      context,
                      label: 'encountersPge.doctor'.tr(context),
                      value:
                          '${encounter.appointment?.doctor?.prefix ?? ''} ${encounter.appointment?.doctor?.fName ?? ''} ${encounter.appointment?.doctor?.lName ?? ''}'
                              .trim(),
                      icon: Icons.person_outline,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (encounter.healthCareServices?.isNotEmpty ?? false)
            _buildInfoCard(
              context,
              title: 'encountersPge.servicesProvided'.tr(context),
              icon: Icons.medical_services_outlined,
              cardElevationColor: cardElevationColor,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: encounter.healthCareServices?.length ?? 0,
                  itemBuilder: (context, index) {
                    final service = encounter.healthCareServices![index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ServiceListItem(service: service),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? actionWidget,
    required List<Widget> children,
    required Color cardElevationColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color headerIconColor = theme.primaryColor;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: headerIconColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (actionWidget != null) actionWidget,
              ],
            ),
            Divider(
              height: 28,
              thickness: 0.8,
              color: theme.dividerColor.withOpacity(0.6),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    String? value,
    required IconData icon,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    String? tooltip,
  }) {
    final ThemeData theme = Theme.of(context);

    Widget textWidget = Text(
      value ?? 'N/A',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      textWidget = InkWell(
        onTap: () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);
          _showCustomTooltip(context, tooltip, offset);
        },
        child: Tooltip(
          message: 'click_to_view_details'.tr(context),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: textWidget,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.cyan,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: textWidget),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CodeModel? status, BuildContext context) {
    Color chipColor;
    Color textColor;
    String statusKey = status?.code?.toLowerCase() ?? 'default';


    switch (statusKey) {
      case 'in-progress':
        chipColor = Colors.orange.withAlpha(40);
        textColor = Colors.orange.shade800;
        break;
      case 'final':
        chipColor = Colors.green.withAlpha(40);
        textColor = Colors.green.shade800;
        break;
      default:
        chipColor = Colors.grey.withAlpha(20);
        textColor = Colors.grey.shade800;
    }


    String translatedText = 'status.$statusKey'.tr(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withAlpha(100), width: 0.8),
      ),
      child: Text(
        translatedText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
