import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../data/model/health_care_service_filter.dart';

class HealthCareServiceFilterDialog extends StatefulWidget {
  final HealthCareServiceFilter currentFilter;

  const HealthCareServiceFilterDialog({required this.currentFilter, super.key});

  @override
  _HealthCareServiceFilterDialogState createState() =>
      _HealthCareServiceFilterDialogState();
}

class _HealthCareServiceFilterDialogState
    extends State<HealthCareServiceFilterDialog> {
  late HealthCareServiceFilter _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedClinicId;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getServiceCategoryCodes(context: context);

    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _minPriceController.text = _filter.minPrice?.toString() ?? '';
    _maxPriceController.text = _filter.maxPrice?.toString() ?? '';
    _selectedCategoryId = _filter.categoryId?.toString();
    _selectedClinicId = _filter.clinicId?.toString();
  }

  List<CodeModel> categories = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: context.width,
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
                  "healthCareServicesPage.filterHealthCareServices".tr(context),
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
                    const SizedBox(height: 16),
                    // Search Field
                    Text(
                      "healthCareServicesPage.search".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'healthCareServicesPage.searchServicesHint'
                            .tr(context),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
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

                    const Divider(),
                    Text(
                      "healthCareServicesPage.priceRange".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minPriceController,
                            decoration: InputDecoration(
                              labelText: 'healthCareServicesPage.minPrice'.tr(
                                context,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _filter = _filter.copyWith(
                                minPrice:
                                value.isNotEmpty
                                    ? double.tryParse(value)
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _maxPriceController,
                            decoration: InputDecoration(
                              labelText: 'healthCareServicesPage.maxPrice'.tr(
                                context,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _filter = _filter.copyWith(
                                maxPrice:
                                value.isNotEmpty
                                    ? double.tryParse(value)
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const Divider(),
                    Text(
                      "healthCareServicesPage.status".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: [
                        RadioListTile<bool?>(
                          title: Text(
                            "healthCareServicesPage.allStatuses".tr(context),
                          ),
                          value: null,
                          groupValue: _filter.active,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(active: null);
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "healthCareServicesPage.active".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: true,
                          groupValue: _filter.active,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(active: value);
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "healthCareServicesPage.inactive".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: false,
                          groupValue: _filter.active,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(active: value);
                            });
                          },
                        ),
                      ],
                    ),

                    const Divider(),
                    // Appointment Required
                    Text(
                      "healthCareServicesPage.appointmentRequired".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: [
                        RadioListTile<bool?>(
                          title: Text("healthCareServicesPage.all".tr(context)),
                          value: null,
                          groupValue: _filter.appointmentRequired,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                appointmentRequired: null,
                              );
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "healthCareServicesPage.required".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: true,
                          groupValue: _filter.appointmentRequired,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                appointmentRequired: value,
                              );
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "healthCareServicesPage.notRequired".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: false,
                          groupValue: _filter.appointmentRequired,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                appointmentRequired: value,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    // Categories
                    Text(
                      "healthCareServicesPage.category".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    BlocConsumer<CodeTypesCubit, CodeTypesState>(
                      listener: (context, state) {
                        if (state is CodeTypesSuccess) {
                          setState(() {
                            categories =
                                state.codes
                                    ?.where(
                                      (code) =>
                                  code.codeTypeModel?.name ==
                                      'categories',
                                )
                                    .toList() ??
                                    [];
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (state is CodesError) {
                          context
                              .read<CodeTypesCubit>()
                              .getServiceCategoryCodes(context: context);

                          return Text(
                            "${'healthCareServicesPage.errorLoadingCategories'.tr(context)} ${state.error}",
                          );
                        }
                        if (categories.isEmpty) {
                          return Text(
                            "healthCareServicesPage.noCategoriesAvailable".tr(
                              context,
                            ),
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "healthCareServicesPage.allCategories".tr(
                                  context,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedCategoryId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                  _filter = _filter.copyWith(categoryId: null);
                                });
                              },
                            ),
                            ...categories.map((category) {
                              return RadioListTile<String>(
                                title: Text(
                                  category.display,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: category.id,
                                groupValue: _selectedCategoryId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                    _filter = _filter.copyWith(
                                      categoryId:
                                      value != null
                                          ? int.tryParse(value)
                                          : null,
                                    );
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                      _filter = HealthCareServiceFilter();
                      _searchController.clear();
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      _selectedCategoryId = null;
                      _selectedClinicId = null;
                      _selectedSort = null;
                    });
                  },
                  child: Text(
                    "healthCareServicesPage.clear".tr(context),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("healthCareServicesPage.cancel".tr(context)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text("healthCareServicesPage.apply".tr(context)),
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

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}
