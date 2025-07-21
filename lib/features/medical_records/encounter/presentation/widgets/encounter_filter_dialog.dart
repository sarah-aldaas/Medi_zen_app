import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
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

    context.read<CodeTypesCubit>().getEncounterTypeCodes(context: context);
    context.read<CodeTypesCubit>().getEncounterStatusCodes(context: context);
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
                Text(
                  "encountersPge.filterEncounters".tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                        labelText: 'encountersPge.search'.tr(
                          context,
                        ),
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

                    Text(
                      "encountersPge.encounterType".tr(context),
                      style: const TextStyle(
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
                                title: Text(
                                  "encountersPge.allTypes".tr(context),
                                ),
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
                                    type.display ??
                                        'encountersPge.unknown'.tr(
                                          context,
                                        ),
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

                    Text(
                      "encountersPge.status".tr(context),
                      style: const TextStyle(
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
                                title: Text(
                                  "encountersPge.allStatuses".tr(context),
                                ),
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
                                    status.display ??
                                        'encountersPge.unknown'.tr(
                                          context,
                                        ),
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

                    Text(
                      "encountersPge.dateRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedMinStartDate != null
                            ? '${"encountersPge.from".tr(context)}: ${DateFormat('MMM d, y').format(_selectedMinStartDate!)}'
                            : "encountersPge.selectStartDate".tr(
                          context,
                        ),
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
                            ? '${"encountersPge.to".tr(context)}: ${DateFormat('MMM d, y').format(_selectedMaxStartDate!)}'
                            : "encountersPge.selectEndDate".tr(
                          context,
                        ),
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
                  child: Text(
                    "encountersPge.clearFilters".tr(context),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "encountersPge.cancel".tr(context),
                      ),
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
                      child: Text(
                        "encountersPge.apply".tr(context),
                      ),
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
