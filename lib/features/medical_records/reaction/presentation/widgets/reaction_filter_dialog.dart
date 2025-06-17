import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
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

    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes(context: context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),

        decoration: BoxDecoration(
          color: theme.cardColor,
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
                  'reactionsPage.filterReactions'.tr(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'reactionsPage.search'.tr(context),
                        labelStyle: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'reactionsPage.severity'.tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> severities = [];
                        if (state is CodeTypesSuccess) {
                          severities =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'reaction_severity',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingPage());
                        }
                        if (severities.isEmpty) {
                          return Text(
                            'reactionsPage.noSeveritiesAvailable'.tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                'reactionsPage.allSeverities'.tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedSeverityId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeverityId = value;
                                });
                              },
                            ),
                            ...severities.map((severity) {
                              return RadioListTile<String>(
                                title: Text(
                                  severity.display ??
                                      'reactionsPage.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: severity.id,
                                groupValue: _selectedSeverityId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
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
                    Divider(color: theme.dividerColor),

                    Text(
                      'reactionsPage.exposureRoute'.tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> exposureRoutes = [];
                        if (state is CodeTypesSuccess) {
                          exposureRoutes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'reaction_exposure_route',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingPage());
                        }
                        if (exposureRoutes.isEmpty) {
                          return Text(
                            'reactionsPage.noExposureRoutesAvailable'.tr(
                              context,
                            ),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                'reactionsPage.allExposureRoutes'.tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedExposureRouteId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedExposureRouteId = value;
                                });
                              },
                            ),
                            ...exposureRoutes.map((route) {
                              return RadioListTile<String>(
                                title: Text(
                                  route.display ??
                                      'reactionsPage.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: route.id,
                                groupValue: _selectedExposureRouteId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
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

                    const SizedBox(height: 20),

                    Text(
                      'reactionsPage.sortOrder'.tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.iconTheme.color,
                      ),
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'reactionsPage.default'.tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'asc',
                          child: Text(
                            'reactionsPage.oldestFirst'.tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'desc',
                          child: Text(
                            'reactionsPage.newestFirst'.tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
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
            const SizedBox(height: 22),

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
                  child: Text(
                    'reactionsPage.clearFilters'.tr(context),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'reactionsPage.cancel'.tr(context),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ReactionFilterModel(
                            searchQuery: _filter.searchQuery,
                            severityId:
                            _selectedSeverityId != null
                                ? int.tryParse(_selectedSeverityId!)
                                : null,
                            exposureRouteId:
                            _selectedExposureRouteId != null
                                ? int.tryParse(_selectedExposureRouteId!)
                                : null,
                            key: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('reactionsPage.apply'.tr(context)),
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
