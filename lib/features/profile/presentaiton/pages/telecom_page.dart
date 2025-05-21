import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';

import '../../../../base/theme/app_color.dart';
import '../cubit/telecom_cubit/telecom_cubit.dart';

class TelecomPage extends StatefulWidget {
  const TelecomPage({super.key});

  @override
  State<TelecomPage> createState() => _TelecomPageState();
}

class _TelecomPageState extends State<TelecomPage> {
  late Future<List<CodeModel>> telecomTypesFuture;
  late Future<List<CodeModel>> telecomUseFuture;

  @override
  void initState() {
    telecomTypesFuture = context.read<CodeTypesCubit>().getTelecomTypeCodes();
    telecomUseFuture = context.read<CodeTypesCubit>().getTelecomUseCodes();
    context.read<TelecomCubit>().fetchTelecoms(
      rank: '1',
      paginationCount: '100',
    );
    super.initState();
  }

  void _showUpdateDialog(TelecomModel telecom, TelecomCubit telecomCubit) {
    final valueController = TextEditingController(text: telecom.value);
    CodeModel? selectedType;
    CodeModel? selectedUse;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: FutureBuilder<List<CodeModel>>(
              future: Future.wait([
                telecomTypesFuture,
                telecomUseFuture,
              ]).then((results) => results[0]),
              builder: (context, typeSnapshot) {
                return FutureBuilder<List<CodeModel>>(
                  future: telecomUseFuture,
                  builder: (context, useSnapshot) {
                    if (typeSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        useSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: LoadingButton(isWhite: false)),
                      );
                    }

                    final telecomTypes = typeSnapshot.data ?? [];
                    final telecomUses = useSnapshot.data ?? [];

                    selectedType =
                        telecomTypes.isNotEmpty
                            ? telecomTypes.firstWhere(
                              (type) => type.id == telecom.type?.id,
                              orElse:
                                  () => telecomTypes.first, // Provide default
                            )
                            : null;

                    selectedUse =
                        telecomUses.isNotEmpty
                            ? telecomUses.firstWhere(
                              (use) => use.id == telecom.use?.id,
                              orElse:
                                  () => telecomUses.first, // Provide default
                            )
                            : null;

                    return SingleChildScrollView(
                      child: Column(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'telecomPage.updateTelecom'.tr(context),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: valueController,
                            style: TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'telecomPage.value'.tr(context),
                            ),
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items:
                                telecomTypes
                                    .map(
                                      (type) => DropdownMenuItem<CodeModel>(
                                        value: type,
                                        child: Text(type.display),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setState(() => selectedType = value),
                            decoration: InputDecoration(
                              labelText: 'telecomPage.typeLabel'.tr(context),
                            ),
                            value: selectedType,
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items:
                                telecomUses
                                    .map(
                                      (use) => DropdownMenuItem<CodeModel>(
                                        value: use,
                                        child: Text(use.display),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setState(() => selectedUse = value),
                            decoration: InputDecoration(
                              labelText: 'telecomPage.useLabel'.tr(context),
                            ),
                            value: selectedUse,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'telecomPage.cancel'.tr(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (valueController.text.isNotEmpty &&
                                      selectedType != null &&
                                      selectedUse != null) {
                                    final updatedTelecom = TelecomModel(
                                      id: telecom.id,
                                      value: valueController.text,
                                      rank: telecom.rank,
                                      startDate: telecom.startDate,
                                      endDate: telecom.endDate,
                                      type: selectedType,
                                      use: selectedUse,
                                      useId: selectedUse!.id,
                                      typeId: selectedType!.id,
                                    );
                                    telecomCubit.updateTelecom(
                                      id: telecom.id!,
                                      telecomModel: updatedTelecom,
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ShowToast.showToastError(
                                      message: 'telecomPage.allFieldsRequired'
                                          .tr(context),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor
                                      .withOpacity(0.7),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  'telecomPage.update'.tr(context),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final telecomCubit = context.read<TelecomCubit>();
    final valueController = TextEditingController();
    final ValueNotifier<CodeModel?> selectedTypeNotifier = ValueNotifier(null);
    final ValueNotifier<CodeModel?> selectedUseNotifier = ValueNotifier(null);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            surfaceTintColor: Colors.white,
            contentPadding: const EdgeInsets.all(
              25,
            ), // Increased overall padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: FutureBuilder<List<List<CodeModel>>>(
              future: Future.wait([telecomTypesFuture, telecomUseFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 180, // Slightly more height for loading state
                    child: Center(child: LoadingButton(isWhite: false)),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: 180,
                    child: Center(
                      child: Text('telecomPage.errorLoadingData'.tr(context)),
                    ),
                  );
                }

                final telecomTypes = snapshot.data![0];
                final telecomUses = snapshot.data![1];

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'telecomPage.createNewTelecom'.tr(context),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22, // Slightly larger title
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.secondaryColor,
                              size: 30, // Larger close icon
                            ),
                          ),
                        ],
                      ),
                      const Gap(30), // Increased space after title
                      TextField(
                        controller: valueController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'telecomPage.valueLabel'.tr(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Slightly more rounded corners
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ), // More internal padding
                        ),
                      ),
                      const Gap(
                        20,
                      ), // Increased space between text field and first dropdown
                      ValueListenableBuilder<CodeModel?>(
                        valueListenable: selectedTypeNotifier,
                        builder: (context, selectedType, child) {
                          return DropdownButtonFormField<CodeModel>(
                            items:
                                telecomTypes
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type.display,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              selectedTypeNotifier.value = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'telecomPage.typeLabel'.tr(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                            ),
                            value: selectedType,
                            hint: Text('telecomPage.selectType'.tr(context)),
                          );
                        },
                      ),
                      const Gap(20), // Increased space between dropdowns
                      ValueListenableBuilder<CodeModel?>(
                        valueListenable: selectedUseNotifier,
                        builder: (context, selectedUse, child) {
                          return DropdownButtonFormField<CodeModel>(
                            items:
                                telecomUses
                                    .map(
                                      (use) => DropdownMenuItem(
                                        value: use,
                                        child: Text(
                                          use.display,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              selectedUseNotifier.value = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'telecomPage.use'.tr(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                            ),
                            value: selectedUse,
                            hint: Text('telecomPage.selectUse'.tr(context)),
                          );
                        },
                      ),
                      const Gap(40), // Increased space before buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ), // Larger button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'telecomPage.cancel'.tr(context),
                              style: const TextStyle(
                                fontSize: 17, // Slightly larger button text
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(20), // Increased space between buttons
                          ElevatedButton(
                            onPressed: () {
                              if (valueController.text.isNotEmpty &&
                                  selectedTypeNotifier.value != null &&
                                  selectedUseNotifier.value != null) {
                                final newTelecom = TelecomModel(
                                  id: '',
                                  value: valueController.text,
                                  rank: '1',
                                  startDate: null,
                                  endDate: null,
                                  type: selectedTypeNotifier.value!,
                                  use: selectedUseNotifier.value!,
                                  typeId: selectedTypeNotifier.value!.id,
                                  useId: selectedUseNotifier.value!.id,
                                );
                                telecomCubit.createTelecom(
                                  telecomModel: newTelecom,
                                );
                                Navigator.pop(context);
                              } else {
                                ShowToast.showToastError(
                                  message: 'telecomPage.allFieldsRequired'.tr(
                                    context,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ), // Larger button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              'telecomPage.create'.tr(context),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  void _showDetailsDialog(TelecomModel telecom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'telecomPage.telecomDetails'.tr(context),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.blackColor),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(
                    'telecomPage.value : ',
                    telecom.value ?? 'N/A'.tr(context),
                  ),
                  Gap(30),
                  _buildDetailRow(
                    'telecomPage.type : ',
                    telecom.type?.display ?? 'N/A'.tr(context),
                  ),
                  Gap(30),
                  _buildDetailRow(
                    'telecomPage.use : ',
                    telecom.use?.display ?? 'N/A'.tr(context),
                  ),
                  Gap(30),
                  _buildDetailRow(
                    'telecomPage.startDateLabel : ',
                    telecom.startDate ?? 'N/A'.tr(context),
                  ),
                  Gap(30),
                  _buildDetailRow(
                    'telecomPage.endDateLabel : ',
                    telecom.endDate ?? 'N/A'.tr(context),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'telecomPage.cancel'.tr(context),
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle_outlined, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  void _showUpdateDeleteDialog(
    TelecomModel telecom,
    TelecomCubit telecomCubit,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'telecomPage.manageTelecom'.tr(context),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.dangerous_outlined,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'telecomPage.value: ${telecom.value ?? 'N/A'}'.tr(context),
                  style: TextStyle(fontSize: 18),
                ),
                const Gap(13),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateDialog(telecom, telecomCubit);
                  },
                  child: Container(
                    width: context.width / 2,
                    decoration: BoxDecoration(
                      color: AppColors.update,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(5),
                    child: Text(
                      'telecomPage.update'.tr(context),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    telecomCubit.deleteTelecom(id: telecom.id!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: context.width / 2,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'telecomPage.delete'.tr(context),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTelecomCard(TelecomModel telecom) {
    return Card(
      // Increased horizontal margin and vertical margin for more separation between cards
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      // Increased borderRadius significantly for much more rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // <-- Changed from 10 to 20
      // Added elevation for a subtle shadow effect, making the card pop out more
      elevation:
          5, // You can adjust this value (e.g., 8, 10) for more/less shadow
      child: ExpansionTile(
        // Larger icon for better visibility
        leading: const Icon(
          Icons.phone_android,
          color: AppColors.gallery,
          size: 30,
        ),
        title: Text(
          telecom.value ?? 'N/A',
          // Larger font size for the title
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ), // <-- Changed from 18 to 20
        ),
        subtitle: Text(
          '${telecom.type?.display ?? 'N/A'} - ${telecom.use?.display ?? 'N/A'}',
          // Larger font size for the subtitle
          style: const TextStyle(fontSize: 18), // <-- Changed from 16 to 18
        ),
        // Increased childrenPadding for more internal space
        childrenPadding: const EdgeInsets.all(20), // <-- Changed from 16 to 20
        children: [
          Row(
            children: [
              // Larger icon
              Icon(Icons.tag, size: 25), // <-- Added size: 25
              // Increased gap
              const Gap(12),
              Text(
                'telecomPage.type: ${telecom.type?.display ?? 'N/A'}'.tr(
                  context,
                ),
                // Larger font size
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
          // Increased gap
          const Gap(12), // <-- Changed from 8 to 12
          Row(
            children: [
              // Larger icon
              const Icon(Icons.label, size: 25), // <-- Added size: 25
              // Increased gap
              const Gap(12), // <-- Changed from 8 to 12
              Text(
                'telecomPage.use: ${telecom.use?.display ?? 'N/A'}'.tr(context),
                // Larger font size
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
          // Increased gap
          const Gap(25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                // Larger icon
                icon: const Icon(
                  Icons.edit,
                  color: Colors.cyan,
                  size: 30,
                ), // <-- Added size: 30
                onPressed:
                    () => _showUpdateDialog(
                      telecom,
                      context.read<TelecomCubit>(),
                    ),
              ),
              // Added gap between icons for more visual separation
              const Gap(10),
              IconButton(
                // Larger icon
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 30,
                ), // <-- Added size: 30
                onPressed:
                    () => _showUpdateDeleteDialog(
                      telecom,
                      context.read<TelecomCubit>(),
                    ),
              ),
              // Added gap between icons
              const Gap(10),
              IconButton(
                // Larger icon
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.blueGrey,
                  size: 30,
                ), // <-- Added size: 30
                onPressed: () => _showDetailsDialog(telecom),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentForTab(CodeModel? type) {
    if (type == null) return const SizedBox.shrink();

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        if (state is TelecomInitial) {
          context.read<TelecomCubit>().fetchTelecoms(
            rank: '1',
            paginationCount: '100',
          );
        }

        if (state is TelecomLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final telecoms =
            state is TelecomSuccess
                ? state.paginatedResponse.paginatedData!.items
                : [];
        final filteredTelecoms =
            telecoms.where((telecom) => telecom.type!.id == type.id).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Gap(30),
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    _showCreateDialog(context);
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
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    elevation: 3,
                  ),
                  child: Text('telecomPage.addNewTelecom'.tr(context)),
                ),
              ),
              const Gap(30),
              filteredTelecoms!.isEmpty
                  ? const Center(child: Text('No telecoms of this type.'))
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTelecoms.length,
                    itemBuilder: (context, index) {
                      return _buildTelecomCard(filteredTelecoms[index]);
                    },
                  ),
            ],
          ),
        );
      },
    );
  }

  CodeModel? _selectedTab;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()),
        BlocProvider(create: (context) => serviceLocator<TelecomCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'telecomPage.telecoms'.tr(context),
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.primaryColor,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: FutureBuilder<List<CodeModel>>(
              future: telecomTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }
                final telecomTypes = snapshot.data ?? [];
                if (telecomTypes.isEmpty) {
                  return const SizedBox.shrink();
                }
                _selectedTab ??= telecomTypes.first;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        telecomTypes.map((type) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ChoiceChip(
                              label: Text(type.display ?? 'N/A'),
                              selected: _selectedTab == type,
                              selectedColor: AppColors.primaryColor,
                              backgroundColor: Colors.grey[200],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTab = type;
                                });
                              },
                              labelStyle: TextStyle(
                                color:
                                    _selectedTab == type
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        body: FutureBuilder<List<CodeModel>>(
          future: telecomTypesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final telecomTypes = snapshot.data ?? [];
            return _buildContentForTab(_selectedTab ?? telecomTypes.first);
          },
        ),
      ),
    );
  }
}
