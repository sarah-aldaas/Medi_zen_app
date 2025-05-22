import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_filter_model.dart';

class ReactionFilterDialog extends StatefulWidget {
  final ReactionFilterModel currentFilter;

  const ReactionFilterDialog({super.key, required this.currentFilter});

  @override
  State<ReactionFilterDialog> createState() => _ReactionFilterDialogState();
}

class _ReactionFilterDialogState extends State<ReactionFilterDialog> {
  late ReactionFilterModel _filter;
  String? _selectedSeverityId;
  String? _selectedExposureRouteId;
  String? _selectedSort;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController = TextEditingController(text: _filter.searchQuery);
    _selectedSeverityId = _filter.severityId?.toString();
    _selectedExposureRouteId = _filter.exposureRouteId?.toString();
    _selectedSort = _filter.key;

    // Initialize code types
    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes();
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Reactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),

                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Severity Filter
                    const Text('Severity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> severities = [];
                        if (state is CodeTypesSuccess) {
                          severities = state.codes?.where((code) => code.codeTypeModel?.name == 'reaction_severity').toList() ?? [];
                        }
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (severities.isEmpty) {
                          return const Text('No severities available', style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text('All Severities'),
                              value: null,
                              groupValue: _selectedSeverityId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeverityId = value;
                                });
                              },
                            ),
                            ...severities.map((severity) {
                              return RadioListTile<String>(
                                title: Text(severity.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: severity.id,
                                groupValue: _selectedSeverityId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSeverityId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),

                    // Exposure Route Filter
                    const Text('Exposure Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> exposureRoutes = [];
                        if (state is CodeTypesSuccess) {
                          exposureRoutes = state.codes?.where((code) => code.codeTypeModel?.name == 'reaction_exposure_route').toList() ?? [];
                        }
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (exposureRoutes.isEmpty) {
                          return const Text('No exposure routes available', style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text('All Exposure Routes'),
                              value: null,
                              groupValue: _selectedExposureRouteId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _selectedExposureRouteId = value;
                                });
                              },
                            ),
                            ...exposureRoutes.map((route) {
                              return RadioListTile<String>(
                                title: Text(route.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: route.id,
                                groupValue: _selectedExposureRouteId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedExposureRouteId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    // Sort Order
                    const Text('Sort Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),

                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Default')),
                        DropdownMenuItem(value: 'asc', child: Text('Oldest First')),
                        DropdownMenuItem(value: 'desc', child: Text('Newest First')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSeverityId = null;
                      _selectedExposureRouteId = null;
                      _searchController.clear();
                      _selectedSort = null;
                      _filter = ReactionFilterModel();
                    });
                  },
                  child: const Text('Clear Filters', style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ReactionFilterModel(
                            searchQuery: _filter.searchQuery,
                            severityId: _selectedSeverityId != null ? int.tryParse(_selectedSeverityId!) : null,
                            exposureRouteId: _selectedExposureRouteId != null ? int.tryParse(_selectedExposureRouteId!) : null,
                            key: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),

                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
