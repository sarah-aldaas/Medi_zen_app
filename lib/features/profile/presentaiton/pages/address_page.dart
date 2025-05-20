import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/widgets/show_toast.dart';
import '../cubit/address_cubit/address_cubit.dart';
import '../widgets/address/add_edit_address_page.dart';
import '../widgets/address/address_card.dart';
import '../widgets/address/empty_state.dart';
import '../widgets/address/error_state.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key, required addressModel});

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
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditAddressPage()),
                ).then((_) => context.read<AddressCubit>().fetchAddresses()),
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
                title: 'No Addresses',
                message: 'You haven\'t added any addresses yet',
                actionText: 'Add Address',
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
                      key: ValueKey(address.id), // Important for proper updates
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
            title: const Text('Delete Address'),
            content: const Text(
              'Are you sure you want to delete this address?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AddressCubit>().deleteAddress(id: addressId);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
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
                const Text(
                  "Filter Addresses",
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
                    const Text(
                      "Address Use",
                      style: TextStyle(
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
                          return const Text(
                            "No address uses available",
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Uses"),
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
                    const Text(
                      "Address Type",
                      style: TextStyle(
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
                          return const Text(
                            "No address types available",
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Types"),
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
