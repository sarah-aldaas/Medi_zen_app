import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
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
                  'complain filter',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'search',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                    const SizedBox(height: 16),
                    _buildTypeDropdown(),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('assignedToAdmin'),
                      value: _filter.assignedToAdmin ?? false,
                      onChanged: (value) => setState(() {
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
                    'reset',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _filter.copyWith(
                            searchQuery: _searchController.text.isNotEmpty
                                ? _searchController.text
                                : null,
                            statusId: _selectedStatusId,
                            typeId: _selectedTypeId,
                          ),
                        );
                      },
                      child: Text('apply'),
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
          return LoadingButton();
        }

        final statusCodes = state is CodeTypesSuccess
            ? state.codes?.where((code) => code.codeTypeModel?.name == 'complaint_status').toList()
            : [];

        return DropdownButtonFormField<String>(
          value: _selectedStatusId,
          decoration: InputDecoration(
            labelText: 'status',
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('all'),
            ),
            ...?statusCodes?.map((code) => DropdownMenuItem(
              value: code.id,
              child: Text(code.display),
            )),
          ],
          onChanged: (value) => setState(() => _selectedStatusId = value),
        );
      },
    );
  }

  Widget _buildTypeDropdown() {
    return BlocBuilder<CodeTypesCubit, CodeTypesState>(
      builder: (context, state) {
        if (state is CodeTypesLoading) {
          return LoadingButton();
        }

        final typeCodes = state is CodeTypesSuccess
            ? state.codes?.where((code) => code.codeTypeModel?.name == 'complaint_type').toList()
            : [];

        return DropdownButtonFormField<String>(
          value: _selectedTypeId,
          decoration: InputDecoration(
            labelText: 'type',
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('all'),
            ),
            ...?typeCodes?.map((code) => DropdownMenuItem(
              value: code.id,
              child: Text(code.display),
            )),
          ],
          onChanged: (value) => setState(() => _selectedTypeId = value),
        );
      },
    );
  }
}