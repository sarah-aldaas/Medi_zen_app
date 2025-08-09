import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/complains/data/models/complain_filter_model.dart';

class ComplainFilterDialog extends StatefulWidget {
  final ComplainFilterModel currentFilter;

  const ComplainFilterDialog({super.key, required this.currentFilter});

  @override
  _ComplainFilterDialogState createState() => _ComplainFilterDialogState();
}

class _ComplainFilterDialogState extends State<ComplainFilterDialog> {
  late ComplainFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedStatusId;
  String? _selectedTypeId;

  @override
  void initState() {
    super.initState();

    _filter = widget.currentFilter;

    _searchController.text = _filter.searchQuery ?? '';
    _selectedStatusId = _filter.statusId;
    _selectedTypeId = _filter.typeId;

    context.read<CodeTypesCubit>().getComplainStatusTypeCodes(context: context);
    context.read<CodeTypesCubit>().getComplainTypeCodes(context: context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'complainFilterPage.complainFilter_title'.tr(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const Gap(12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'complainFilterPage.complainFilter_search'
                            .tr(context),
                        border: const OutlineInputBorder(),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _filter = _filter.copyWith(
                                        searchQuery: null,
                                      );
                                    });
                                  },
                                )
                                : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            searchQuery: value.isNotEmpty ? value : null,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildStatusDropdown(),
                    const SizedBox(height: 20),

                    _buildTypeDropdown(),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      title: Text(
                        'complainFilterPage.complainFilter_assignedToAdmin'.tr(
                          context,
                        ),
                      ),
                      value: _filter.assignedToAdmin ?? false,
                      onChanged:
                          (value) => setState(() {
                            _filter = _filter.copyWith(assignedToAdmin: value);
                          }),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedStatusId = null;
                      _selectedTypeId = null;

                      _filter = ComplainFilterModel();
                    });
                  },
                  child: Text(
                    'complainFilterPage.complainFilter_reset'.tr(context),
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'complainFilterPage.cancelButton'.tr(context),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _filter.copyWith(
                            searchQuery:
                                _searchController.text.isNotEmpty
                                    ? _searchController.text
                                    : null,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'complainFilterPage.complainFilter_apply'.tr(context),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

  Widget _buildStatusDropdown() {
    return BlocBuilder<CodeTypesCubit, CodeTypesState>(
      builder: (context, state) {
        if (state is CodeTypesLoading) {
          return const Center(child: LoadingPage());
        }

        final statusCodes =
            state is CodeTypesSuccess
                ? state.codes
                    ?.where(
                      (code) => code.codeTypeModel?.name == 'complaint_status',
                    )
                    .toList()
                : [];

        return DropdownButtonFormField<String>(
          value: _selectedStatusId,
          decoration: InputDecoration(
            labelText: 'complainFilterPage.complainFilter_status'.tr(context),
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('complainFilterPage.complainFilter_all'.tr(context)),
            ),

            ...?statusCodes?.map(
              (code) =>
                  DropdownMenuItem(value: code.id, child: Text(code.display)),
            ),
          ],
          onChanged:
              (value) => setState(() {
                _selectedStatusId = value;

                _filter = _filter.copyWith(statusId: value);
              }),
        );
      },
    );
  }

  Widget _buildTypeDropdown() {
    return BlocBuilder<CodeTypesCubit, CodeTypesState>(
      builder: (context, state) {
        if (state is CodeTypesLoading) {
          return const Center(child: LoadingPage());
        }

        final typeCodes =
            state is CodeTypesSuccess
                ? state.codes
                    ?.where(
                      (code) => code.codeTypeModel?.name == 'complaint_type',
                    )
                    .toList()
                : [];

        return DropdownButtonFormField<String>(
          value: _selectedTypeId,
          decoration: InputDecoration(
            labelText: 'complainFilterPage.complainFilter_type'.tr(context),
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('complainFilterPage.complainFilter_all'.tr(context)),
            ),

            ...?typeCodes?.map(
              (code) =>
                  DropdownMenuItem(value: code.id, child: Text(code.display)),
            ),
          ],
          onChanged:
              (value) => setState(() {
                _selectedTypeId = value;
                _filter = _filter.copyWith(typeId: value);
              }),
        );
      },
    );
  }
}
