import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/theme/app_color.dart';
// <<<<<<< HEAD
import '../../../../../base/widgets/not_found_data_page.dart';
import '../../../../../base/widgets/show_toast.dart';
// =======
// >>>>>>> c804e45c3224c511626af6e9cbcb1dd2e908ee6d
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/encounter_list_item.dart';
import 'encounter_details_page.dart';

class AllEncountersOfAppointmentPage extends StatefulWidget {
  final String appointmentId;
  const AllEncountersOfAppointmentPage({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AllEncountersOfAppointmentPage> createState() =>
      _AllEncountersOfAppointmentPageState();
}

class _AllEncountersOfAppointmentPageState
    extends State<AllEncountersOfAppointmentPage> {
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
// <<<<<<< HEAD
//         listener: (context, state) {
//           // if (state is EncounterError) {
//           //   // ShowToast.showToastError(message: 'encountersPge.errorLoading'.tr(context));
//           // }
//         },
// =======
        listener: (context, state) {},
// >>>>>>> c804e45c3224c511626af6e9cbcb1dd2e908ee6d
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          }

          final List<EncounterModel> encounters =
              state is EncounterOfAppointmentSuccess
                  ? state.encounterModel != null
                      ? [state.encounterModel]
                      : []
                  : [];

          if (encounters.isEmpty) {
            return NotFoundDataPage();
          }

          return ListView.builder(
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              if (index < encounters.length) {
                return EncounterListItem(
                  encounter: encounters[index],
                  onTap:
                      () => _navigateToEncounterDetails(encounters[index].id!),
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
