import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/allergy_filter_model.dart';

class AllergyFilterDialog extends StatefulWidget {
  final AllergyFilterModel currentFilter;

  const AllergyFilterDialog({super.key, required this.currentFilter});

  @override
  State<AllergyFilterDialog> createState() => _AllergyFilterDialogState();
}

class _AllergyFilterDialogState extends State<AllergyFilterDialog> {
  late AllergyFilterModel _filter;
  String? _selectedTypeId;
  String? _selectedSort;
  int? _selectedCategoryId;
  int? _selectedClinicalStatusId;
  int? _selectedVerificationStatusId;
  int? _selectedCriticalityId;
  int? _selectedDiscoveredDuringEncounter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController = TextEditingController(text: _filter.searchQuery);
    _selectedTypeId = _filter.typeId?.toString();
    _selectedCategoryId = _filter.categoryId;
    _selectedClinicalStatusId = _filter.clinicalStatusId;
    _selectedVerificationStatusId = _filter.verificationStatusId;
    _selectedCriticalityId = _filter.criticalityId;
    _selectedDiscoveredDuringEncounter = _filter.isDiscoveredDuringEncounter;
    _selectedSort = _filter.sort;

    // Initialize code types
    context.read<CodeTypesCubit>().getAllergyTypeCodes();
    context.read<CodeTypesCubit>().getAllergyCategoryCodes();
    context.read<CodeTypesCubit>().getAllergyClinicalStatusCodes();
    context.read<CodeTypesCubit>().getAllergyVerificationStatusCodes();
    context.read<CodeTypesCubit>().getAllergyCriticalityCodes();
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
                const Text("Filter Allergies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                    // Discovered During Encounter
                    const Text("Discovered During Encounter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<int?>(
                          title: const Text("Any"),
                          value: null,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: const Text("Yes", style: TextStyle(fontSize: 14)),
                          value: 1,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: const Text("No", style: TextStyle(fontSize: 14)),
                          value: 0,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),

                    // Type Filter
                    const Text("Allergy Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> allergyTypes = [];
                        if (state is CodeTypesSuccess) {
                          allergyTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_type').toList() ?? [];
                        }
                        if (state is CodeTypesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (allergyTypes.isEmpty) {
                          return const Text("No allergy types available", style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Types"),
                              value: null,
                              groupValue: _selectedTypeId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTypeId = value;
                                });
                              },
                            ),
                            ...allergyTypes.map((type) {
                              return RadioListTile<String>(
                                title: Text(type.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: type.id,
                                groupValue: _selectedTypeId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedTypeId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),

                    // Category Filter
                    const Text("Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> categories = [];
                        if (state is CodeTypesSuccess) {
                          categories = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_category').toList() ?? [];
                        }
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (categories.isEmpty) {
                          return const Text("No categories available", style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: const Text("All Categories"),
                              value: null,
                              groupValue: _selectedCategoryId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            ),
                            ...categories.map((category) {
                              return RadioListTile<int>(
                                title: Text(category.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: int.parse(category.id),
                                groupValue: _selectedCategoryId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),

                    // Clinical Status Filter
                    const Text("Clinical Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> clinicalStatuses = [];
                        if (state is CodeTypesSuccess) {
                          clinicalStatuses = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_clinical_status').toList() ?? [];
                        }
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (clinicalStatuses.isEmpty) {
                          return const Text("No clinical statuses available", style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: const Text("All Statuses"),
                              value: null,
                              groupValue: _selectedClinicalStatusId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedClinicalStatusId = value;
                                });
                              },
                            ),
                            ...clinicalStatuses.map((status) {
                              return RadioListTile<int>(
                                title: Text(status.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: int.parse(status.id),
                                groupValue: _selectedClinicalStatusId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedClinicalStatusId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),

                    // Criticality Filter
                    const Text("Criticality", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> criticalities = [];
                        if (state is CodeTypesSuccess) {
                          criticalities = state.codes?.where((code) => code.codeTypeModel?.name == 'allergy_criticality').toList() ?? [];
                        }
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (criticalities.isEmpty) {
                          return const Text("No criticalities available", style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: const Text("All Criticalities"),
                              value: null,
                              groupValue: _selectedCriticalityId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedCriticalityId = value;
                                });
                              },
                            ),
                            ...criticalities.map((criticality) {
                              return RadioListTile<int>(
                                title: Text(criticality.display ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                value: int.parse(criticality.id),
                                groupValue: _selectedCriticalityId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedCriticalityId = value;
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
                    const Text("Sort Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Default")),
                        DropdownMenuItem(value: 'asc', child: Text("Oldest First")),
                        DropdownMenuItem(value: 'desc', child: Text("Newest First")),
                      ],
                      onChanged:
                          (value) => setState(() {

                            _selectedSort = value;
                          }),
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
                      _selectedTypeId = null;
                      _selectedCategoryId = null;
                      _selectedClinicalStatusId = null;
                      _selectedVerificationStatusId = null;
                      _selectedCriticalityId = null;
                      _selectedDiscoveredDuringEncounter = null;
                      _searchController.clear();
                      _selectedSort = null;
                      _filter = AllergyFilterModel();
                    });
                  },
                  child: const Text("Clear Filters", style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AllergyFilterModel(
                            searchQuery: _filter.searchQuery,
                            isDiscoveredDuringEncounter: _selectedDiscoveredDuringEncounter,
                            typeId: _selectedTypeId != null ? int.tryParse(_selectedTypeId!) : null,
                            clinicalStatusId: _selectedClinicalStatusId,
                            verificationStatusId: _selectedVerificationStatusId,
                            categoryId: _selectedCategoryId,
                            criticalityId: _selectedCriticalityId,
                            sort: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
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
  }
}
