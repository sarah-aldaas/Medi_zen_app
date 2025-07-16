import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/encounter_list_item.dart';
import 'encounter_details_page.dart';

const double _kCardMarginVertical = 8.0;
const double _kCardMarginHorizontal = 16.0;
const double _kCardElevation = 4.0;
const double _kCardBorderRadius = 16.0;
const double _kCardPaddingVertical = 16.0;
const double _kCardPaddingHorizontal = 20.0;

class AllEncountersOfAppointmentPage extends StatefulWidget {
final String appointmentId;
  const AllEncountersOfAppointmentPage({super.key,required this.appointmentId});

  @override
  State<AllEncountersOfAppointmentPage> createState() => _AllEncountersOfAppointmentPageState();
}

class _AllEncountersOfAppointmentPageState extends State<AllEncountersOfAppointmentPage> {

  @override
  void initState() {
    super.initState();
    _loadInitialEncounters();
  }
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'in_progress':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'planned':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  void _loadInitialEncounters() {
    context.read<EncounterCubit>().getAllMyEncounterOfAppointment(
      appointmentId: widget.appointmentId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadInitialEncounters();
      },
      color: Theme.of(context).primaryColor,
      child: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ShowToast.showToastError(message: 'encountersPge.errorLoading'.tr(context));
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          }

          final List<EncounterModel> encounters =
          state is EncounterOfAppointmentSuccess
              ? state.encounterModel!=null?[state.encounterModel]:[]:[];

          if (encounters.isEmpty) {
            return NotFoundDataPage();
          }

          return ListView.builder(
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              // if (index < encounters.length) {
              //   return _EncounterCard(
              //     encounter: encounters[index],
              //     // showAppointmentReason: widget.appointmentId == null,
              //     statusColor: _getStatusColor(
              //       encounters[index].status?.display,
              //     ),
              //     onTap: () =>_navigateToEncounterDetails(encounters[index].id!),
              //   );
              // } else  {
              //   return  Center(
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(vertical: 24.0),
              //       child: LoadingButton(),
              //     ),
              //   );
              // }
              if (index < encounters.length) {
                return EncounterListItem(
                  encounter: encounters[index],
                  onTap: () => _navigateToEncounterDetails(encounters[index].id!),
                );
              } else {
                return Center(child: LoadingButton());
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToEncounterDetails(String encounterId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncounterDetailsPage(encounterId: encounterId),
      ),
    ).then((_) {
      _loadInitialEncounters();
    });
  }
}
class _EncounterCard extends StatelessWidget {
  final EncounterModel encounter;
  // final bool showAppointmentReason;
  final Color statusColor;
  final VoidCallback onTap;

  const _EncounterCard({
    required this.encounter,
    // required this.showAppointmentReason,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    String formattedDate = 'N/A';
    String formattedTime = '';
    try {
      if (encounter.actualStartDate != null) {
        final dateTime = DateTime.parse(encounter.actualStartDate!);
        formattedDate = DateFormat('EEE, MMM d, y').format(dateTime);
        formattedTime = DateFormat('hh:mm a').format(dateTime);
      }
    } catch (e) {
      formattedDate = encounter.actualStartDate ?? 'encounterPage.not_available_short'.tr(context);
    }

    return Card(
      color: Theme.of(context).appBarTheme.backgroundColor,
      margin: const EdgeInsets.symmetric(
        horizontal: _kCardMarginHorizontal,
        vertical: _kCardMarginVertical,
      ),
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        side: BorderSide(color: Theme.of(context).cardColor, width: 2.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kCardPaddingHorizontal,
            vertical: _kCardPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      encounter.reason ?? 'encounterPage.no_reason_specified'.tr(context),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(15),
                  Chip(
                    label: Text(
                      encounter.status?.display ?? 'encounterPage.unknown_status'.tr(context),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    formattedDate,
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Gap(16),
                  Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    formattedTime,
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const Gap(15),
              Row(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      '${'encounterPage.appointment_label'.tr(context)}: ${encounter.appointment?.reason ?? 'encounterPage.not_available_short'.tr(context)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
