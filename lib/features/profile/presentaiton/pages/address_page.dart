import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/widgets/show_toast.dart';
import '../../../../base/theme/app_color.dart';
import '../cubit/address_cubit/address_cubit.dart';
import '../widgets/address/add_edit_address_page.dart';
import '../widgets/address/address_card.dart';
import '../widgets/address/empty_state.dart';
import '../widgets/address/error_state.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final ScrollController _scrollController = ScrollController();
  AddressFilter _filter = const AddressFilter();
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    if (!_hasFetched) {
      context.read<AddressCubit>().fetchAddresses();
      context.read<CodeTypesCubit>().getAddressTypeCodes();
      context.read<CodeTypesCubit>().getAddressUseCodes();
      _hasFetched = true;
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<AddressCubit>().fetchAddresses(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AddressFilter>(
      context: context,
      builder: (context) => AddressFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      context.read<AddressCubit>().applyFilters(
        typeId: result.typeId,
        useId: result.useId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primaryColor,
        ),
        title: Text(
          'addressList.myAddresses'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
            iconSize: 30,
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryColor),
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditAddressPage()),
            ).then((_) => context.read<AddressCubit>().fetchAddresses()),
            iconSize: 30,
          ),
        ],
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AddressInitial ||
              (state is AddressLoading && state.isFirstFetch)) {
            return const Center(child: LoadingPage());
          } else if (state is AddressError) {
            return ErrorState(
              message: state.error,
              onRetry: () => context.read<AddressCubit>().fetchAddresses(),
            );
          } else if (state is AddressSuccess) {
            final addresses =
                state.paginatedResponse.paginatedData?.items ?? [];

            if (addresses.isEmpty) {
              return EmptyState(
                icon: Icons.location_on,
                title: 'addressList.noAddresses'.tr(context),
                message: 'addressList.noAddressesMessage'.tr(context),
                actionText: 'addressList.addAddress'.tr(context),
                onAction:
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressPage(),
                  ),
                ).then(
                      (_) => context.read<AddressCubit>().fetchAddresses(),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () async => context.read<AddressCubit>().fetchAddresses(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= addresses.length) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: LoadingButton()),
                    );
                  }
                  final address = addresses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AddressCard(
                      key: ValueKey(address.id),
                      address: address,
                      onEdit:
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AddEditAddressPage(address: address),
                        ),
                      ).then(
                            (_) =>
                            context.read<AddressCubit>().fetchAddresses(),
                      ),
                      onDelete: () => _showDeleteDialog(context, address.id!),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String addressId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'addressList.deleteAddress'.tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primaryColor,
          ),
        ),
        content: Text(
          'addressList.confirmDeleteAddress'.tr(context),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'addressList.cancel'.tr(context),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gallery,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressCubit>().deleteAddress(id: addressId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              elevation: 3,
            ),
            child: Text(
              'addressList.delete'.tr(context),
              style: TextStyle(color: AppColors.whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}

class AddressFilter {
  final String? typeId;
  final String? useId;

  const AddressFilter({this.typeId, this.useId});

  AddressFilter copyWith({String? typeId, String? useId}) {
    return AddressFilter(
      typeId: typeId ?? this.typeId,
      useId: useId ?? this.useId,
    );
  }
}

class AddressFilterDialog extends StatefulWidget {
  final AddressFilter currentFilter;

  const AddressFilterDialog({required this.currentFilter, super.key});

  @override
  _AddressFilterDialogState createState() => _AddressFilterDialogState();
}

class _AddressFilterDialogState extends State<AddressFilterDialog> {
  late String? _selectedTypeId;
  late String? _selectedUseId;

  @override
  void initState() {
    super.initState();
    _selectedTypeId = widget.currentFilter.typeId;
    _selectedUseId = widget.currentFilter.useId;
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
                  "addressList.filterAddresses".tr(context),
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
                    Text(
                      "addressList.addressUse".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> addressUses = [];
                        if (state is CodeTypesSuccess) {
                          addressUses =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'address_use',
                              )
                                  .fold<Map<String, CodeModel>>(
                                {},
                                    (map, code) => map..[code.id] = code,
                              )
                                  .values
                                  .toList() ??
                                  [];
                        }
                        if (state is CodeTypesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (addressUses.isEmpty) {
                          return Text(
                            "addressList.noAddressUsesAvailable".tr(
                              context,
                            ), // ترجمة
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "addressList.allUses".tr(context),
                              ), // ترجمة
                              value: null,
                              groupValue: _selectedUseId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() => _selectedUseId = value);
                              },
                            ),
                            ...addressUses.map((use) {
                              return RadioListTile<String>(
                                title: Text(
                                  use.display,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: use.id,
                                groupValue: _selectedUseId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() => _selectedUseId = value);
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "addressList.addressType".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> addressTypes = [];
                        if (state is CodeTypesSuccess) {
                          addressTypes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'address_type',
                              )
                                  .fold<Map<String, CodeModel>>(
                                {},
                                    (map, code) => map..[code.id] = code,
                              )
                                  .values
                                  .toList() ??
                                  [];
                        }
                        if (state is CodeTypesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (addressTypes.isEmpty) {
                          return Text(
                            "addressList.noAddressTypesAvailable".tr(
                              context,
                            ), // ترجمة
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "addressList.allTypes".tr(context),
                              ), // ترجمة
                              value: null,
                              groupValue: _selectedTypeId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() => _selectedTypeId = value);
                              },
                            ),
                            ...addressTypes.map((type) {
                              return RadioListTile<String>(
                                title: Text(
                                  type.display,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: type.id,
                                groupValue: _selectedTypeId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() => _selectedTypeId = value);
                                },
                              );
                            }).toList(),
                          ],
                        );
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
                      _selectedUseId = null;
                    });
                  },
                  child: Text(
                    "addressList.clearFilters".tr(context),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("addressList.cancel".tr(context)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AddressFilter(
                            typeId: _selectedTypeId,
                            useId: _selectedUseId,
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
                      child: Text("addressList.apply".tr(context)),
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
