import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../cubit/telecom_cubit/telecom_cubit.dart';
import '../widgets/telecom/telecom_details_dialog.dart';
import '../widgets/telecom/telecom_update_create_dialogs.dart';

class TelecomPage extends StatefulWidget {
  const TelecomPage({super.key});

  @override
  State<TelecomPage> createState() => _TelecomPageState();
}

class _TelecomPageState extends State<TelecomPage> {
  CodeModel? _selectedTab;
  List<CodeModel> _telecomTypes = [];
  List<CodeModel> _telecomUses = [];
  final CodeModel _allTab = CodeModel(
    id: 'all',
    display: 'All',
    code: '',
    description: '',
    codeTypeId: '',
  );

  @override
  void initState() {
    super.initState();

    context.read<CodeTypesCubit>().getTelecomTypeCodes(context: context).then((
      types,
    ) {
      if (mounted) {
        setState(() {
          _telecomTypes = [_allTab, ...types];
          _selectedTab = _allTab;
        });
      }
    });
    context.read<CodeTypesCubit>().getTelecomUseCodes(context: context).then((
      uses,
    ) {
      if (mounted) {
        setState(() {
          _telecomUses = uses;
        });
      }
    });

    context.read<TelecomCubit>().fetchTelecoms(
      context: context,
      rank: '1',
      paginationCount: '100',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()),
        BlocProvider(create: (context) => serviceLocator<TelecomCubit>()),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'telecomPage.telecoms'.tr(context),
            style:
                theme.appBarTheme.titleTextStyle?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child:
                _telecomTypes.isEmpty
                    ? Center(
                      child: LinearProgressIndicator(color: theme.primaryColor),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _telecomTypes.map((type) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(type.display ?? 'N/A'),
                                  selected: _selectedTab == type,
                                  selectedColor: theme.primaryColor,
                                  backgroundColor:
                                      theme.chipTheme.backgroundColor,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedTab = type;
                                    });
                                  },
                                  labelStyle: theme.chipTheme.labelStyle
                                      ?.copyWith(
                                        color:
                                            _selectedTab == type
                                                ? theme.colorScheme.onPrimary
                                                : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                      ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ),
        body: BlocBuilder<TelecomCubit, TelecomState>(
          builder: (context, state) {
            if (state is TelecomInitial) {
              context.read<TelecomCubit>().fetchTelecoms(
                rank: '1',
                paginationCount: '100',
                context: context,
              );
              return const Center(child: LoadingPage());
            }
            if (state is TelecomLoading) {
              return const Center(child: LoadingPage());
            }

            List<TelecomModel>? telecoms =
                state is TelecomSuccess
                    ? state.paginatedResponse.paginatedData?.items
                    : [];

            final ThemeData theme = Theme.of(context);

            if (_selectedTab == null) return const SizedBox.shrink();
            final filteredTelecoms =
                _selectedTab!.id == 'all'
                    ? telecoms?.toList() ?? []
                    : telecoms
                            ?.where(
                              (telecom) => telecom.type?.id == _selectedTab!.id,
                            )
                            .toList() ??
                        [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showCreateTelecomDialog(
                        context: context,
                        telecomTypesFuture: Future.value(
                          _telecomTypes.where((t) => t.id != 'all').toList(),
                        ),
                        telecomUseFuture: Future.value(_telecomUses),
                        telecomCubit: context.read<TelecomCubit>(),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Row(
                          spacing: 10,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create telecom",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.add, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Gap(20),
                  filteredTelecoms.isEmpty
                      ? Center(
                        child: Text(
                          'telecomPage.noTelecomsOfType'.tr(context),
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTelecoms.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            color: theme.cardColor,
                            child: ExpansionTile(
                              leading: Icon(
                                Icons.phone_android,
                                color: theme.iconTheme.color,
                                size: 30,
                              ),
                              title: Text(
                                filteredTelecoms[index].value ?? 'N/A',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${filteredTelecoms[index].type?.display ?? 'N/A'} - ${filteredTelecoms[index].use?.display ?? 'N/A'}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              childrenPadding: const EdgeInsets.all(20),
                              collapsedIconColor: theme.iconTheme.color,
                              iconColor: theme.primaryColor,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.tag,
                                      size: 25,
                                      color: theme.iconTheme.color,
                                    ),
                                    const Gap(12),
                                    Text(
                                      "telecomPage.type".tr(context) +
                                          "${filteredTelecoms[index].type?.display ?? 'N/A'}",
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.label,
                                      size: 25,
                                      color: theme.iconTheme.color,
                                    ),
                                    const Gap(12),
                                    Text(
                                      "telecomPage.use".tr(context) +
                                          "${filteredTelecoms[index].use?.display ?? 'N/A'}",
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Gap(25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: theme.colorScheme.secondary,
                                        size: 20,
                                      ),
                                      onPressed:
                                          () => showUpdateTelecomDialog(
                                            context: context,
                                            telecom: filteredTelecoms[index],
                                            telecomCubit:
                                                context.read<TelecomCubit>(),
                                            telecomTypesFuture: Future.value(
                                              _telecomTypes
                                                  .where((t) => t.id != 'all')
                                                  .toList(),
                                            ),
                                            telecomUseFuture: Future.value(
                                              _telecomUses,
                                            ),
                                          ),
                                    ),
                                    const Gap(10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                      onPressed:
                                          () => context
                                              .read<TelecomCubit>()
                                              .deleteTelecom(
                                                id: filteredTelecoms[index].id!,
                                                context: context,
                                              ),
                                    ),
                                    const Gap(10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                        size: 20,
                                      ),
                                      onPressed:
                                          () => showTelecomDetailsDialog(
                                            context: context,
                                            telecom: filteredTelecoms[index],
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                          // return _buildTelecomCard(context, filteredTelecoms[index],state);
                        },
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
