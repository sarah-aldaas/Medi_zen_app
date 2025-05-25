import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../data/models/encounter_filter_model.dart';

class EncounterFilterDialog extends StatefulWidget {
  final EncounterFilterModel currentFilter;

  const EncounterFilterDialog({super.key, required this.currentFilter});

  @override
  State<EncounterFilterDialog> createState() => _EncounterFilterDialogState();
}

class _EncounterFilterDialogState extends State<EncounterFilterDialog> {
  late EncounterFilterModel _filter;
  String? _selectedTypeId;
  int? _selectedStatusId;
  DateTime? _selectedMinStartDate;
  DateTime? _selectedMaxStartDate;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController = TextEditingController(text: _filter.searchQuery);
    _selectedTypeId = _filter.typeId?.toString();
    _selectedStatusId = _filter.statusId;
    _selectedMinStartDate = _filter.minStartDate;
    _selectedMaxStartDate = _filter.maxStartDate;

    context.read<CodeTypesCubit>().getEncounterTypeCodes();
    context.read<CodeTypesCubit>().getEncounterStatusCodes();
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
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Encounters",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Encounter Type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodeTypesSuccess) {
                          final types =
                              state.codes
                                  ?.where(
                                    (c) =>
                                        c.codeTypeModel?.name ==
                                        'encounter_type',
                                  )
                                  .toList() ??
                              [];
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
                              ...types.map(
                                (type) => RadioListTile<String>(
                                  title: Text(
                                    type.display ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: type.id,
                                  groupValue: _selectedTypeId,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedTypeId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return LoadingButton();
                      },
                    ),
                    const Divider(),

                    const Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodeTypesSuccess) {
                          final statuses =
                              state.codes
                                  ?.where(
                                    (c) =>
                                        c.codeTypeModel?.name ==
                                        'encounter_status',
                                  )
                                  .toList() ??
                              [];
                          return Column(
                            children: [
                              RadioListTile<int?>(
                                title: const Text("All Statuses"),
                                value: null,
                                groupValue: _selectedStatusId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedStatusId = value;
                                  });
                                },
                              ),
                              ...statuses.map(
                                (status) => RadioListTile<int>(
                                  title: Text(
                                    status.display ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: int.parse(status.id),
                                  groupValue: _selectedStatusId,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (int? value) {
                                    setState(() {
                                      _selectedStatusId = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return LoadingButton();
                      },
                    ),
                    const Divider(),

                    const Text(
                      "Date Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedMinStartDate != null
                            ? 'From: ${DateFormat('MMM d, y').format(_selectedMinStartDate!)}'
                            : "Select start date",
                        style: TextStyle(
                          color:
                              _selectedMinStartDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedMinStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedMinStartDate = picked;
                            if (_selectedMaxStartDate != null &&
                                _selectedMaxStartDate!.isBefore(picked)) {
                              _selectedMaxStartDate = null;
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedMaxStartDate != null
                            ? 'To: ${DateFormat('MMM d, y').format(_selectedMaxStartDate!)}'
                            : "Select end date",
                        style: TextStyle(
                          color:
                              _selectedMaxStartDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              _selectedMaxStartDate ??
                              (_selectedMinStartDate ?? DateTime.now()),
                          firstDate: _selectedMinStartDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedMaxStartDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypeId = null;
                      _selectedStatusId = null;
                      _selectedMinStartDate = null;
                      _selectedMaxStartDate = null;
                      _searchController.clear();
                      _filter = EncounterFilterModel();
                    });
                  },
                  child: const Text(
                    "Clear Filters",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          EncounterFilterModel(
                            searchQuery: _filter.searchQuery,
                            typeId:
                                _selectedTypeId != null
                                    ? int.tryParse(_selectedTypeId!)
                                    : null,
                            statusId: _selectedStatusId,
                            minStartDate: _selectedMinStartDate,
                            maxStartDate: _selectedMaxStartDate,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
