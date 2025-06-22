import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../services/pages/cubits/service_cubit/service_cubit.dart';
import '../../data/models/service_request_filter.dart';

class ServiceRequestFilterDialog extends StatefulWidget {
  final ServiceRequestFilter currentFilter;

  const ServiceRequestFilterDialog({required this.currentFilter, super.key});

  @override
  _ServiceRequestFilterDialogState createState() => _ServiceRequestFilterDialogState();
}

class _ServiceRequestFilterDialogState extends State<ServiceRequestFilterDialog> {
  late ServiceRequestFilter _filter;
  String? _selectedStatusId;
  String? _selectedCategoryId;
  String? _selectedBodySiteId;
  String? _selectedHealthCareServiceId;
  String? _selectedPriorityId;
  List<HealthCareServiceModel> _healthCareServices = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedStatusId = _filter.statusId;
    _selectedCategoryId = _filter.categoryId;
    _selectedBodySiteId = _filter.bodySiteId;
    _selectedHealthCareServiceId = _filter.healthCareServiceId;
    _selectedPriorityId = _filter.priorityId;

    // Load code types
    context.read<CodeTypesCubit>().getServiceRequestStatusCodes(context: context);
    context.read<CodeTypesCubit>().getServiceRequestCategoryCodes(context: context);
    context.read<CodeTypesCubit>().getServiceRequestPriorityCodes(context: context);
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);

    // Load healthcare services
    _loadHealthCareServices();
  }

  Future<void> _loadHealthCareServices() async {
    // Trigger the load
    context.read<ServiceCubit>().getAllServiceHealthCare(context: context, filters: {});

    // Listen for state changes
    await Future.delayed(Duration.zero); // Allow the cubit to emit the initial loading state

    await for (final state in context.read<ServiceCubit>().stream) {
      if (state is ServiceHealthCareSuccess) {
        setState(() {
          _healthCareServices = state.paginatedResponse.paginatedData!.items;
        });
        break; // Stop listening after we get the success state
      } else if (state is ServiceHealthCareError) {
        // Handle error if needed
        debugPrint('Error loading healthcare services: ${state.error}');
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceCubit, ServiceState>(
      listener: (context, state) {
        if (state is ServiceHealthCareSuccess) {
          setState(() {
            _healthCareServices = state.paginatedResponse.paginatedData!.items;
          });
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Service Request Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Filter
                        _buildFilterSection(
                          title: "Status",
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> statusCodes = [];
                              if (state is CodeTypesSuccess) {
                                statusCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_status').toList() ?? [];
                              }
                              return _buildCodeDropdown(
                                value: _selectedStatusId,
                                items: statusCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedStatusId = value;
                                    }),
                              );
                            },
                          ),
                        ),

                        // Category Filter
                        _buildFilterSection(
                          title: "Category",
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> categoryCodes = [];
                              if (state is CodeTypesSuccess) {
                                categoryCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_category').toList() ?? [];
                              }
                              return _buildCodeDropdown(
                                value: _selectedCategoryId,
                                items: categoryCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedCategoryId = value;
                                    }),
                              );
                            },
                          ),
                        ),

                        // Priority Filter
                        _buildFilterSection(
                          title: "Priority",
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> priorityCodes = [];
                              if (state is CodeTypesSuccess) {
                                priorityCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_priority').toList() ?? [];
                              }
                              return _buildCodeDropdown(
                                value: _selectedPriorityId,
                                items: priorityCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedPriorityId = value;
                                    }),
                              );
                            },
                          ),
                        ),

                        // Body Site Filter
                        _buildFilterSection(
                          title: "Body Site",
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> bodySiteCodes = [];
                              if (state is CodeTypesSuccess) {
                                bodySiteCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'body_site').toList() ?? [];
                              }
                              return _buildCodeDropdown(
                                value: _selectedBodySiteId,
                                items: bodySiteCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedBodySiteId = value;
                                    }),
                              );
                            },
                          ),
                        ),

                        // Healthcare Service Filter
                        _buildFilterSection(title: "Healthcare Service", child: _buildHealthCareServiceDropdown(state)),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatusId = null;
                          _selectedCategoryId = null;
                          _selectedBodySiteId = null;
                          _selectedHealthCareServiceId = null;
                          _selectedPriorityId = null;
                        });
                      },
                      child: const Text("Clear Filters", style: TextStyle(color: Colors.red)),
                    ),
                    Row(
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              ServiceRequestFilter(
                                statusId: _selectedStatusId,
                                categoryId: _selectedCategoryId,
                                bodySiteId: _selectedBodySiteId,
                                healthCareServiceId: _selectedHealthCareServiceId,
                                priorityId: _selectedPriorityId,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), child],
      ),
    );
  }

  Widget _buildCodeDropdown({required String? value, required List<CodeModel> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All')),
        ...items.map((code) {
          return DropdownMenuItem(value: code.id, child: Text(code.display ?? 'Unknown'));
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildHealthCareServiceDropdown(ServiceState state) {
    return state is ServiceHealthCareLoading
        ? LoadingButton()
        : DropdownButtonFormField<String>(
          value: _selectedHealthCareServiceId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Services')),
            ..._healthCareServices.map((service) {
              return DropdownMenuItem(value: service.id, child: Text(service.name ?? 'Unknown Service'));
            }).toList(),
          ],
          onChanged:
              (value) => setState(() {
                _selectedHealthCareServiceId = value;
              }),
        );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
//
// import '../../../../../base/data/models/code_type_model.dart';
// import '../../data/models/service_request_filter.dart';
//
// class ServiceRequestFilterDialog extends StatefulWidget {
//   final ServiceRequestFilter currentFilter;
//
//   const ServiceRequestFilterDialog({required this.currentFilter, super.key});
//
//   @override
//   _ServiceRequestFilterDialogState createState() => _ServiceRequestFilterDialogState();
// }
//
// class _ServiceRequestFilterDialogState extends State<ServiceRequestFilterDialog> {
//   late ServiceRequestFilter _filter;
//   String? _selectedStatusId;
//   String? _selectedCategoryId;
//   String? _selectedBodySiteId;
//   String? _selectedHealthCareServiceId;
//   String? _selectedPriorityId;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _filter = widget.currentFilter;
//     _selectedStatusId = _filter.statusId;
//     _selectedCategoryId = _filter.categoryId;
//     _selectedBodySiteId = _filter.bodySiteId;
//     _selectedHealthCareServiceId = _filter.healthCareServiceId;
//     _selectedPriorityId = _filter.priorityId;
//
//     // Load code types
//     context.read<CodeTypesCubit>().getServiceRequestStatusCodes(context: context);
//     context.read<CodeTypesCubit>().getServiceRequestCategoryCodes(context: context);
//     context.read<CodeTypesCubit>().getServiceRequestPriorityCodes(context: context);
//     context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.8),
//         decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16.0)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Service request filter", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
//               ],
//             ),
//             const Divider(),
//             Flexible(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Status Filter
//                     Text("Status", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                       builder: (context, state) {
//                         List<CodeModel> statusCodes = [];
//                         if (state is CodeTypesSuccess) {
//                           statusCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_status').toList() ?? [];
//                         }
//                         return _buildCodeDropdown(
//                           value: _selectedStatusId?.toString(),
//                           items: statusCodes,
//                           onChanged:
//                               (value) => setState(() {
//                                 _selectedStatusId = value != null ? value : null;
//                               }),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Category Filter
//                     Text("Category", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                       builder: (context, state) {
//                         List<CodeModel> categoryCodes = [];
//                         if (state is CodeTypesSuccess) {
//                           categoryCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_category').toList() ?? [];
//                         }
//                         return _buildCodeDropdown(
//                           value: _selectedCategoryId?.toString(),
//                           items: categoryCodes,
//                           onChanged:
//                               (value) => setState(() {
//                                 _selectedCategoryId = value != null ? value : null;
//                               }),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Priority Filter
//                     Text("Priority", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                       builder: (context, state) {
//                         List<CodeModel> priorityCodes = [];
//                         if (state is CodeTypesSuccess) {
//                           priorityCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'service_request_priority').toList() ?? [];
//                         }
//                         return _buildCodeDropdown(
//                           value: _selectedPriorityId?.toString(),
//                           items: priorityCodes,
//                           onChanged:
//                               (value) => setState(() {
//                                 _selectedPriorityId = value != null ? value : null;
//                               }),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Body Site Filter
//                     Text("Body site", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     BlocBuilder<CodeTypesCubit, CodeTypesState>(
//                       builder: (context, state) {
//                         List<CodeModel> bodySiteCodes = [];
//                         if (state is CodeTypesSuccess) {
//                           bodySiteCodes = state.codes?.where((code) => code.codeTypeModel?.name == 'body_site').toList() ?? [];
//                         }
//                         return _buildCodeDropdown(
//                           value: _selectedBodySiteId?.toString(),
//                           items: bodySiteCodes,
//                           onChanged:
//                               (value) => setState(() {
//                                 _selectedBodySiteId = value != null ? value : null;
//                               }),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 10),
//
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Action Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedStatusId = null;
//                       _selectedCategoryId = null;
//                       _selectedBodySiteId = null;
//                       _selectedPriorityId = null;
//                     });
//                   },
//                   child: Text("Clear filters", style: const TextStyle(color: Colors.red)),
//                 ),
//                 Row(
//                   children: [
//                     TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel")),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(
//                           context,
//                           ServiceRequestFilter(
//                             statusId: _selectedStatusId,
//                             categoryId: _selectedCategoryId,
//                             bodySiteId: _selectedBodySiteId,
//                             priorityId: _selectedPriorityId,
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context).primaryColor,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                       ),
//                       child: Text("apply"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCodeDropdown({required String? value, required List<CodeModel> items, required Function(String?) onChanged}) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//       ),
//       items: [
//         const DropdownMenuItem(value: null, child: Text('All')),
//         ...items.map((code) {
//           return DropdownMenuItem(value: code.id, child: Text(code.display ?? 'Unknown'));
//         }).toList(),
//       ],
//       onChanged: onChanged,
//     );
//   }
// }
