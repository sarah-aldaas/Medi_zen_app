import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';
import 'package:medizen_app/features/profile/presentaiton/widgets/telecom/telecom_details_dialog.dart';
import 'package:medizen_app/features/profile/presentaiton/widgets/telecom/telecom_update_create_dialogs.dart';

import '../../../../../../../../base/theme/app_color.dart';
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

  Widget _buildTelecomCard(TelecomModel telecom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: ExpansionTile(
        leading: const Icon(
          Icons.phone_android,
          color: AppColors.gallery,
          size: 30,
        ),
        title: Text(
          telecom.value ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${telecom.type?.display ?? 'N/A'} - ${telecom.use?.display ?? 'N/A'}',
          style: const TextStyle(fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(Icons.tag, size: 25),
              const Gap(12),
              Text(
                "telecomPage.type".tr(context) +
                    "${telecom.type?.display ?? 'N/A'}",
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              const Icon(Icons.label, size: 25),
              const Gap(12),
              Text(
                "telecomPage.use".tr(context) +
                    "${telecom.use?.display ?? 'N/A'}",
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),

          const Gap(25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.cyan, size: 20),
                onPressed:
                    () => showUpdateTelecomDialog(
                      context: context,
                      telecom: telecom,
                      telecomCubit: context.read<TelecomCubit>(),
                      telecomTypesFuture: telecomTypesFuture,
                      telecomUseFuture: telecomUseFuture,
                    ),
              ),
              const Gap(10),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed:
                    () => showUpdateDeleteTelecomDialog(
                      context: context,
                      telecom: telecom,
                      telecomCubit: context.read<TelecomCubit>(),
                    ),
              ),
              const Gap(10),
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.blueGrey,
                  size: 20,
                ),
                onPressed:
                    () => showTelecomDetailsDialog(
                      context: context,
                      telecom: telecom,
                    ),
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
                    showCreateTelecomDialog(
                      context: context,
                      telecomTypesFuture: telecomTypesFuture,
                      telecomUseFuture: telecomUseFuture,
                      telecomCubit: context.read<TelecomCubit>(),
                    );
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
              filteredTelecoms.isEmpty
                  ? Center(
                    child: Text('telecomPage.noTelecomsOfType'.tr(context)),
                  )
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
