import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../../medication/data/models/medication_model.dart';
import '../../../medication/presentation/pages/my_medications_page.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';

class MedicationRequestDetailsPage extends StatefulWidget {
  final String medicationRequestId;


  const MedicationRequestDetailsPage({super.key, required this.medicationRequestId});

  @override
  _MedicationRequestDetailsPageState createState() => _MedicationRequestDetailsPageState();
}

class _MedicationRequestDetailsPageState extends State<MedicationRequestDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMedicationRequest();
  }

  void _loadMedicationRequest(){
    context.read<MedicationRequestCubit>().getMedicationRequestDetails(context: context, medicationRequestId: widget.medicationRequestId);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text("medicationRequestDetails.title".tr(context), style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor), onPressed: () => context.pop()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.info_outline), text: "medicationRequestDetails.details".tr(context)),
            Tab(icon: Icon(Icons.medication), text: "medicationRequestDetails.medication".tr(context)),
          ],
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMedicationRequest();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
          listener: (context, state) {
            if (state is MedicationRequestError) {
              ShowToast.showToastError(message: state.error);
            }
          },
          builder: (context, state) {
            if (state is MedicationRequestDetailsSuccess) {
              return TabBarView(
                controller: _tabController,
                children: [
                  // Details Tab
                  _buildDetailsTab(state.medicationRequest),

                  // Medication Tab
                  MyMedicationsPage(
                    conditionId:state.medicationRequest.condition!.id! ,
                    medicationRequestId: state.medicationRequest.id!,
                  )
                ],
              );
            } else if (state is MedicationRequestLoading) {
              return const Center(child: LoadingPage());
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 70, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        "medicationRequestDetails.failedToLoad".tr(context),
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailsTab(MedicationRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(request),
          const SizedBox(height: 30),

          _buildInfoSection(
            title: "medicationRequestDetails.requestInfo".tr(context),
            children: [
              _buildDetailRow(label: "medicationRequestDetails.status".tr(context), value: request.status?.display, icon: Icons.info_outline),
              _buildDetailRow(label: "medicationRequestDetails.statusReason".tr(context), value: request.statusReason, icon: Icons.notes),
              _buildDetailRow(
                label: "medicationRequestDetails.statusChanged".tr(context),
                value: request.statusChanged != null ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(request.statusChanged!)) : null,
                icon: Icons.calendar_today,
              ),
              _buildDetailRow(label: "medicationRequestDetails.intent".tr(context), value: request.intent?.display, icon: Icons.flag),
              _buildDetailRow(label: "medicationRequestDetails.priority".tr(context), value: request.priority?.display, icon: Icons.priority_high),
            ],
          ),
          const SizedBox(height: 30),

          if (request.condition != null) ...[
            _buildInfoSection(
              title: "medicationRequestDetails.conditionInfo".tr(context),
              children: [
                _buildDetailRow(
                  label: "medicationRequestDetails.condition".tr(context),
                  value: request.condition?.healthIssue,
                  icon: Icons.medical_information,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.isChronic".tr(context),
                  value: request.condition?.isChronic == 1 ? 'medicationRequestDetails.yes'.tr(context) : 'medicationRequestDetails.no'.tr(context),
                  icon: Icons.history,
                ),
                _buildDetailRow(label: "medicationRequestDetails.onSetDate".tr(context), value: request.condition?.onSetDate, icon: Icons.date_range),
                _buildDetailRow(label: "medicationRequestDetails.onSetAge".tr(context), value: request.condition?.onSetAge?.toString(), icon: Icons.elderly),
                _buildDetailRow(label: "medicationRequestDetails.recordDate".tr(context), value: request.condition?.recordDate, icon: Icons.receipt),
                _buildDetailRow(
                  label: "medicationRequestDetails.conditionNote".tr(context),
                  value: request.condition?.note,
                  icon: Icons.sticky_note_2_outlined,
                ),
                _buildDetailRow(label: "medicationRequestDetails.summary".tr(context), value: request.condition?.summary, icon: Icons.summarize_outlined),
                _buildDetailRow(label: "medicationRequestDetails.extraNote".tr(context), value: request.condition?.extraNote, icon: Icons.note_add_outlined),
                _buildDetailRow(
                  label: "medicationRequestDetails.clinicalStatus".tr(context),
                  value: request.condition?.clinicalStatus?.display,
                  icon: Icons.bar_chart,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.verificationStatus".tr(context),
                  value: request.condition?.verificationStatus?.display,
                  icon: Icons.verified,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.bodySite".tr(context),
                  value: request.condition?.bodySite?.display,
                  icon: Icons.sports_handball,
                ),
                _buildDetailRow(label: "medicationRequestDetails.stage".tr(context), value: request.condition?.stage?.display, icon: Icons.stairs),
              ],
            ),
            const SizedBox(height: 30),
            if (request.condition!.encounters != null && request.condition!.encounters!.isNotEmpty) ...[
              _buildInfoSection(
                title: "medicationRequestDetails.encounters".tr(context),
                children:
                    request.condition!.encounters!.map((encounter) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(label: "medicationRequestDetails.reason".tr(context), value: encounter.reason, icon: Icons.question_mark_outlined),
                            _buildDetailRow(
                              label: "medicationRequestDetails.actualStartDate".tr(context),
                              value:
                                  encounter.actualStartDate != null
                                      ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(encounter.actualStartDate!))
                                      : null,
                              icon: Icons.event_available,
                            ),
                            _buildDetailRow(
                              label: "medicationRequestDetails.actualEndDate".tr(context),
                              value:
                                  encounter.actualEndDate != null ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(encounter.actualEndDate!)) : null,
                              icon: Icons.event_busy_outlined,
                            ),
                            _buildDetailRow(
                              label: "medicationRequestDetails.specialArrangement".tr(context),
                              value: encounter.specialArrangement,
                              icon: Icons.star_outline,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ],

          _buildInfoSection(
            title: "medicationRequestDetails.additionalInfo".tr(context),
            children: [
              _buildDetailRow(
                label: "medicationRequestDetails.courseOfTherapy".tr(context),
                value: request.courseOfTherapyType?.display,
                icon: Icons.directions_walk,
              ),
              _buildDetailRow(
                label: "medicationRequestDetails.repeatsAllowed".tr(context),
                value: request.numberOfRepeatsAllowed?.toString(),
                icon: Icons.repeat,
              ),
              _buildDetailRow(label: "medicationRequestDetails.note".tr(context), value: request.note, icon: Icons.sticky_note_2_outlined),
              _buildDetailRow(
                label: "medicationRequestDetails.doNotPerform".tr(context),
                value:
                    request.doNotPerform != null
                        ? (request.doNotPerform == 1 ? 'medicationRequestDetails.yes'.tr(context) : 'medicationRequestDetails.no'.tr(context))
                        : null,
                icon: Icons.block,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationRequestModel request) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 60),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.medication?.name ?? request.reason ?? "medicationRequestDetails.defaultMedicationRequest".tr(context),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  request.status?.display ?? "medicationRequestDetails.unknownStatus".tr(context),
                  style: TextStyle(fontSize: 15, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationHeader(MedicationModel medication) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.medication, color: AppColors.primaryColor, size: 60),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name ?? "medicationRequestDetails.unknownMedication".tr(context),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (medication.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(medication.status!.display, style: TextStyle(fontSize: 15, color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    final visibleChildren = children.where((widget) => !(widget is SizedBox && widget.key == null)).toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.titel)),
          const Divider(height: 25, thickness: 1.2, color: Colors.grey),
          ...visibleChildren,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, String? value, required IconData icon}) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.label, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
// import 'package:medizen_app/base/theme/app_color.dart';
// import 'package:medizen_app/base/widgets/loading_page.dart';
// import 'package:medizen_app/base/widgets/show_toast.dart';
//
// import '../../../medication/data/models/medication_model.dart';
// import '../../data/models/medication_request_model.dart';
// import '../cubit/medication_request_cubit/medication_request_cubit.dart';
//
// class MedicationRequestDetailsPage extends StatefulWidget {
//   final String medicationRequestId;
//
//   const MedicationRequestDetailsPage({
//     super.key,
//     required this.medicationRequestId,
//   });
//
//   @override
//   _MedicationRequestDetailsPageState createState() =>
//       _MedicationRequestDetailsPageState();
// }
//
// class _MedicationRequestDetailsPageState
//     extends State<MedicationRequestDetailsPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<MedicationRequestCubit>().getMedicationRequestDetails(
//       context: context,
//       medicationRequestId: widget.medicationRequestId,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//         title: Text(
//           "medicationRequestDetails.title".tr(context),
//           style: TextStyle(
//             color: AppColors.primaryColor,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
//         listener: (context, state) {
//           if (state is MedicationRequestError) {
//             ShowToast.showToastError(message: state.error);
//           }
//         },
//         builder: (context, state) {
//           if (state is MedicationRequestDetailsSuccess) {
//             return _buildMedicationRequestDetails(state.medicationRequest);
//           } else if (state is MedicationRequestLoading) {
//             return const Center(child: LoadingPage());
//           } else {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 70,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "medicationRequestDetails.failedToLoad".tr(context),
//                       style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildMedicationRequestDetails(MedicationRequestModel request) {
//     final MedicationModel? medication = request.medication;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(request),
//           const SizedBox(height: 30),
//
//           _buildInfoSection(
//             title: "medicationRequestDetails.requestInfo".tr(context),
//             children: [
//               _buildDetailRow(
//                 label: "medicationRequestDetails.status".tr(context),
//                 value: request.status?.display,
//                 icon: Icons.info_outline,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.statusReason".tr(context),
//                 value: request.statusReason,
//                 icon: Icons.notes,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.statusChanged".tr(context),
//                 value:
//                     request.statusChanged != null
//                         ? DateFormat(
//                           'MMM d, yyyy - hh:mm a',
//                         ).format(DateTime.parse(request.statusChanged!))
//                         : null,
//                 icon: Icons.calendar_today,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.intent".tr(context),
//                 value: request.intent?.display,
//                 icon: Icons.flag,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.priority".tr(context),
//                 value: request.priority?.display,
//                 icon: Icons.priority_high,
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//
//           if (medication != null) ...[
//             _buildInfoSection(
//               title: "medicationRequestDetails.medicationDetails".tr(context),
//               children: [
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.medicationName".tr(context),
//                   value: medication.name,
//                   icon: Icons.medication_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.medicationDefinition".tr(
//                     context,
//                   ),
//                   value: medication.definition,
//                   icon: Icons.description_outlined,
//                 ),
//                 if (medication.dose != null && medication.doseUnit != null)
//                   _buildDetailRow(
//                     label: "medicationRequestDetails.dose".tr(context),
//                     value: "${medication.dose} ${medication.doseUnit}",
//                     icon: Icons.science_outlined,
//                   ),
//                 if (medication.maxDosePerPeriod != null)
//                   _buildDetailRow(
//                     label: "medicationRequestDetails.maxDose".tr(context),
//                     value:
//                         "${medication.maxDosePerPeriod!.numerator.value} ${medication.maxDosePerPeriod!.numerator.unit} ${"medicationRequestDetails.per".tr(context)} ${medication.maxDosePerPeriod!.denominator.value} ${medication.maxDosePerPeriod!.denominator.unit}",
//                     icon: Icons.medical_services_outlined,
//                   ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.dosageInstructions".tr(
//                     context,
//                   ),
//                   value: medication.dosageInstructions,
//                   icon: Icons.text_snippet_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.patientInstructions".tr(
//                     context,
//                   ),
//                   value: medication.patientInstructions,
//                   icon: Icons.person_outline,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.additionalInstructions".tr(
//                     context,
//                   ),
//                   value: medication.additionalInstructions,
//                   icon: Icons.add_box_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.asNeeded".tr(context),
//                   value:
//                       medication.asNeeded != null
//                           ? (medication.asNeeded!
//                               ? 'medicationRequestDetails.yes'.tr(context)
//                               : 'medicationRequestDetails.no'.tr(context))
//                           : null,
//                   icon: Icons.event_note,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.medicationStatus".tr(
//                     context,
//                   ),
//                   value: medication.status?.display,
//                   icon: Icons.check_circle_outline,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.startDate".tr(context),
//                   value:
//                       medication.effectiveMedicationStartDate != null
//                           ? DateFormat(
//                             'MMM d, yyyy',
//                           ).format(medication.effectiveMedicationStartDate!)
//                           : null,
//                   icon: Icons.event,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.endDate".tr(context),
//                   value:
//                       medication.effectiveMedicationEndDate != null
//                           ? DateFormat(
//                             'MMM d, yyyy',
//                           ).format(medication.effectiveMedicationEndDate!)
//                           : null,
//                   icon: Icons.event_busy,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//           ],
//
//           if (request.condition != null) ...[
//             _buildInfoSection(
//               title: "medicationRequestDetails.conditionInfo".tr(context),
//               children: [
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.condition".tr(context),
//                   value: request.condition?.healthIssue,
//                   icon: Icons.medical_information,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.isChronic".tr(context),
//                   value:
//                       request.condition?.isChronic == 1
//                           ? 'medicationRequestDetails.yes'.tr(context)
//                           : 'medicationRequestDetails.no'.tr(context),
//                   icon: Icons.history,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.onSetDate".tr(context),
//                   value: request.condition?.onSetDate,
//                   icon: Icons.date_range,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.onSetAge".tr(context),
//                   value: request.condition?.onSetAge?.toString(),
//                   icon: Icons.elderly,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.recordDate".tr(context),
//                   value: request.condition?.recordDate,
//                   icon: Icons.receipt,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.conditionNote".tr(context),
//                   value: request.condition?.note,
//                   icon: Icons.sticky_note_2_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.summary".tr(context),
//                   value: request.condition?.summary,
//                   icon: Icons.summarize_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.extraNote".tr(context),
//                   value: request.condition?.extraNote,
//                   icon: Icons.note_add_outlined,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.clinicalStatus".tr(context),
//                   value: request.condition?.clinicalStatus?.display,
//                   icon: Icons.bar_chart,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.verificationStatus".tr(
//                     context,
//                   ),
//                   value: request.condition?.verificationStatus?.display,
//                   icon: Icons.verified,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.bodySite".tr(context),
//                   value: request.condition?.bodySite?.display,
//                   icon: Icons.sports_handball,
//                 ),
//                 _buildDetailRow(
//                   label: "medicationRequestDetails.stage".tr(context),
//                   value: request.condition?.stage?.display,
//                   icon: Icons.stairs,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             if (request.condition!.encounters != null &&
//                 request.condition!.encounters!.isNotEmpty) ...[
//               _buildInfoSection(
//                 title: "medicationRequestDetails.encounters".tr(context),
//                 children:
//                     request.condition!.encounters!.map((encounter) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildDetailRow(
//                               label: "medicationRequestDetails.reason".tr(
//                                 context,
//                               ),
//                               value: encounter.reason,
//                               icon: Icons.question_mark_outlined,
//                             ),
//                             _buildDetailRow(
//                               label: "medicationRequestDetails.actualStartDate"
//                                   .tr(context),
//                               value:
//                                   encounter.actualStartDate != null
//                                       ? DateFormat(
//                                         'MMM d, yyyy - hh:mm a',
//                                       ).format(
//                                         DateTime.parse(
//                                           encounter.actualStartDate!,
//                                         ),
//                                       )
//                                       : null,
//                               icon: Icons.event_available,
//                             ),
//                             _buildDetailRow(
//                               label: "medicationRequestDetails.actualEndDate"
//                                   .tr(context),
//                               value:
//                                   encounter.actualEndDate != null
//                                       ? DateFormat(
//                                         'MMM d, yyyy - hh:mm a',
//                                       ).format(
//                                         DateTime.parse(
//                                           encounter.actualEndDate!,
//                                         ),
//                                       )
//                                       : null,
//                               icon: Icons.event_busy_outlined,
//                             ),
//                             _buildDetailRow(
//                               label:
//                                   "medicationRequestDetails.specialArrangement"
//                                       .tr(context),
//                               value: encounter.specialArrangement,
//                               icon: Icons.star_outline,
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ],
//
//           _buildInfoSection(
//             title: "medicationRequestDetails.additionalInfo".tr(context),
//             children: [
//               _buildDetailRow(
//                 label: "medicationRequestDetails.courseOfTherapy".tr(context),
//                 value: request.courseOfTherapyType?.display,
//                 icon: Icons.directions_walk,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.repeatsAllowed".tr(context),
//                 value: request.numberOfRepeatsAllowed?.toString(),
//                 icon: Icons.repeat,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.note".tr(context),
//                 value: request.note,
//                 icon: Icons.sticky_note_2_outlined,
//               ),
//               _buildDetailRow(
//                 label: "medicationRequestDetails.doNotPerform".tr(context),
//                 value:
//                     request.doNotPerform != null
//                         ? (request.doNotPerform == 1
//                             ? 'medicationRequestDetails.yes'.tr(context)
//                             : 'medicationRequestDetails.no'.tr(context))
//                         : null,
//                 icon: Icons.block,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader(MedicationRequestModel request) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 60),
//         const SizedBox(width: 20),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 request.medication?.name ??
//                     request.reason ??
//                     "medicationRequestDetails.defaultMedicationRequest".tr(
//                       context,
//                     ),
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   request.status?.display ??
//                       "medicationRequestDetails.unknownStatus".tr(context),
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     final visibleChildren =
//         children
//             .where((widget) => !(widget is SizedBox && widget.key == null))
//             .toList();
//
//     if (visibleChildren.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(18.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             spreadRadius: 2,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.titel,
//             ),
//           ),
//           const Divider(height: 25, thickness: 1.2, color: Colors.grey),
//           ...visibleChildren,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow({
//     required String label,
//     String? value,
//     required IconData icon,
//   }) {
//     if (value == null || value.trim().isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: AppColors.secondaryColor, size: 22),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.label,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(fontSize: 15),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
