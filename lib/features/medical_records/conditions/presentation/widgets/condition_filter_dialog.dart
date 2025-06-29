import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_filter_model.dart';

import '../../../../../base/theme/app_color.dart';

class ConditionsFilterDialog extends StatefulWidget {
  final ConditionsFilterModel currentFilter;

  const ConditionsFilterDialog({super.key, required this.currentFilter});

  @override
  _ConditionsFilterDialogState createState() => _ConditionsFilterDialogState();
}

class _ConditionsFilterDialogState extends State<ConditionsFilterDialog> {
  late ConditionsFilterModel _filter;
  DateTime? _minOnSetDate;
  DateTime? _maxOnSetDate;
  DateTime? _minRecordDate;
  DateTime? _maxRecordDate;
  DateTime? _minAbatementDate;
  DateTime? _maxAbatementDate;
  bool? _isChronic;
  final TextEditingController _minOnSetAgeController = TextEditingController();
  final TextEditingController _maxOnSetAgeController = TextEditingController();
  final TextEditingController _minAbatementAgeController =
      TextEditingController();
  final TextEditingController _maxAbatementAgeController =
      TextEditingController();
  final TextEditingController _searchQueryController = TextEditingController();

  String? _selectedBodySiteId;
  String? _selectedClinicalStatusId;
  String? _selectedVerificationStatusId;
  String? _selectedStageId;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _minOnSetDate = _filter.minOnSetDate;
    _maxOnSetDate = _filter.maxOnSetDate;
    _minRecordDate = _filter.minRecordDate;
    _maxRecordDate = _filter.maxRecordDate;
    _minAbatementDate = _filter.minAbatementDate;
    _maxAbatementDate = _filter.maxAbatementDate;
    _isChronic = _filter.isChronic;
    _minOnSetAgeController.text = _filter.minOnSetAge ?? '';
    _maxOnSetAgeController.text = _filter.maxOnSetAge ?? '';
    _minAbatementAgeController.text = _filter.minAbatementAge ?? '';
    _maxAbatementAgeController.text = _filter.maxAbatementAge ?? '';
    _searchQueryController.text = _filter.searchQuery ?? '';
    _selectedBodySiteId = _filter.bodySiteId;
    _selectedClinicalStatusId = _filter.clinicalStatusId;
    _selectedVerificationStatusId = _filter.verificationStatusId;
    _selectedStageId = _filter.stageId;

    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
    context.read<CodeTypesCubit>().getConditionClinicalStatusTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getConditionVerificationStatusTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getConditionStageTypeCodes(context: context);
  }

  @override
  void dispose() {
    _minOnSetAgeController.dispose();
    _maxOnSetAgeController.dispose();
    _minAbatementAgeController.dispose();
    _maxAbatementAgeController.dispose();
    _searchQueryController.dispose();
    super.dispose();
  }

  Widget _buildCodeDropdown({
    required String title,
    required String? value,
    required String codeTypeName,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, state) {
            if (state is CodeTypesLoading ||
                state is CodesLoading ||
                state is CodeTypesInitial) {
              return LoadingButton();
            }

            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes =
                  state.codes
                      ?.where(
                        (code) => code.codeTypeModel?.name == codeTypeName,
                      )
                      .toList() ??
                  [];
            }

            return DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('conditionsFilter.all'.tr(context)),
                ),
                ...codes
                    .map(
                      (code) => DropdownMenuItem(
                        value: code.id,
                        child: Text(code.display),
                      ),
                    )
                    .toList(),
              ],
              onChanged: onChanged,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "conditionsFilter.title".tr(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.primaryColor),
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
                    Text(
                      "conditionsFilter.search".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _searchQueryController,
                      decoration: InputDecoration(
                        hintText: "conditionsFilter.enterSearchTerm".tr(
                          context,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildCodeDropdown(
                      title: "conditionsFilter.bodySite",
                      value: _selectedBodySiteId,
                      codeTypeName: 'body_site',
                      onChanged:
                          (value) =>
                              setState(() => _selectedBodySiteId = value),
                    ),

                    _buildCodeDropdown(
                      title: "conditionsFilter.clinicalStatus",
                      value: _selectedClinicalStatusId,
                      codeTypeName: 'condition_clinical_status',
                      onChanged:
                          (value) =>
                              setState(() => _selectedClinicalStatusId = value),
                    ),

                    _buildCodeDropdown(
                      title: "conditionsFilter.verificationStatus",
                      value: _selectedVerificationStatusId,
                      codeTypeName: 'condition_verification_status',
                      onChanged:
                          (value) => setState(
                            () => _selectedVerificationStatusId = value,
                          ),
                    ),

                    _buildCodeDropdown(
                      title: "conditionsFilter.stage",
                      value: _selectedStageId,
                      codeTypeName: 'condition_stage',
                      onChanged:
                          (value) => setState(() => _selectedStageId = value),
                    ),

                    Text(
                      "conditionsFilter.chronicCondition".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<bool?>(
                          value: null,
                          groupValue: _isChronic,
                          onChanged:
                              (value) => setState(() => _isChronic = value),
                        ),
                        Text("conditionsFilter.all".tr(context)),
                        const SizedBox(width: 16),
                        Radio<bool?>(
                          value: true,
                          groupValue: _isChronic,
                          onChanged:
                              (value) => setState(() => _isChronic = value),
                        ),
                        Text("conditionsFilter.chronic".tr(context)),
                        const SizedBox(width: 16),
                        Radio<bool?>(
                          value: false,
                          groupValue: _isChronic,
                          onChanged:
                              (value) => setState(() => _isChronic = value),
                        ),
                        Text("conditionsFilter.acute".tr(context)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "conditionsFilter.onSetAgeRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minOnSetAgeController,
                            decoration: InputDecoration(
                              labelText: "conditionsFilter.minAge".tr(context),
                              hintText: "10",
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxOnSetAgeController,
                            decoration: InputDecoration(
                              labelText: "conditionsFilter.maxAge".tr(context),
                              hintText: "25",
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "conditionsFilter.onSetDateRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _minOnSetDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_minOnSetDate!)
                                  : "conditionsFilter.from".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _minOnSetDate = date);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _maxOnSetDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_maxOnSetDate!)
                                  : "conditionsFilter.to".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _minOnSetDate ?? DateTime.now(),
                                firstDate: _minOnSetDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _maxOnSetDate = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "conditionsFilter.recordDateRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _minRecordDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_minRecordDate!)
                                  : "conditionsFilter.from".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _minRecordDate = date);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _maxRecordDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_maxRecordDate!)
                                  : "conditionsFilter.to".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _minRecordDate ?? DateTime.now(),
                                firstDate: _minRecordDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _maxRecordDate = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "conditionsFilter.abatementAgeRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minAbatementAgeController,
                            decoration: InputDecoration(
                              labelText: "conditionsFilter.minAge".tr(context),
                              hintText: "10",
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxAbatementAgeController,
                            decoration: InputDecoration(
                              labelText: "conditionsFilter.maxAge".tr(context),
                              hintText: "25",
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "conditionsFilter.abatementDateRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _minAbatementDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_minAbatementDate!)
                                  : "conditionsFilter.from".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _minAbatementDate = date);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              _maxAbatementDate != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_maxAbatementDate!)
                                  : "conditionsFilter.to".tr(context),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    _minAbatementDate ?? DateTime.now(),
                                firstDate: _minAbatementDate ?? DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _maxAbatementDate = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isChronic = null;
                      _minOnSetDate = null;
                      _maxOnSetDate = null;
                      _minRecordDate = null;
                      _maxRecordDate = null;
                      _minAbatementDate = null;
                      _maxAbatementDate = null;
                      _minOnSetAgeController.clear();
                      _maxOnSetAgeController.clear();
                      _minAbatementAgeController.clear();
                      _maxAbatementAgeController.clear();
                      _searchQueryController.clear();
                      _selectedBodySiteId = null;
                      _selectedClinicalStatusId = null;
                      _selectedVerificationStatusId = null;
                      _selectedStageId = null;
                    });
                  },
                  child: Text(
                    "conditionsFilter.clearFilters".tr(context),
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "conditionsFilter.cancel".tr(context),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ConditionsFilterModel(
                            searchQuery:
                                _searchQueryController.text.isNotEmpty
                                    ? _searchQueryController.text
                                    : null,
                            isChronic: _isChronic,
                            minOnSetDate: _minOnSetDate,
                            maxOnSetDate: _maxOnSetDate,
                            minRecordDate: _minRecordDate,
                            maxRecordDate: _maxRecordDate,
                            minOnSetAge:
                                _minOnSetAgeController.text.isNotEmpty
                                    ? _minOnSetAgeController.text
                                    : null,
                            maxOnSetAge:
                                _maxOnSetAgeController.text.isNotEmpty
                                    ? _maxOnSetAgeController.text
                                    : null,
                            minAbatementAge:
                                _minAbatementAgeController.text.isNotEmpty
                                    ? _minAbatementAgeController.text
                                    : null,
                            maxAbatementAge:
                                _maxAbatementAgeController.text.isNotEmpty
                                    ? _maxAbatementAgeController.text
                                    : null,
                            minAbatementDate: _minAbatementDate,
                            maxAbatementDate: _maxAbatementDate,
                            bodySiteId: _selectedBodySiteId,
                            clinicalStatusId: _selectedClinicalStatusId,
                            verificationStatusId: _selectedVerificationStatusId,
                            stageId: _selectedStageId,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("conditionsFilter.apply".tr(context)),
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
