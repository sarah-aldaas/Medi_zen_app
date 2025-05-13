import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/telecom_model.dart';
import 'package:medizen_app/base/data/models/code_type_model.dart';
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
    context.read<TelecomCubit>().fetchTelecoms(rank: '1', paginationCount: '100');
    super.initState();
  }

  void _showUpdateDialog(TelecomModel telecom,TelecomCubit telecomCubit) {
    // final telecomCubit = context.read<TelecomCubit>();
    final valueController = TextEditingController(text: telecom.value);
    CodeModel? selectedType;
    CodeModel? selectedUse;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        content: FutureBuilder<List<CodeModel>>(
          future: Future.wait([telecomTypesFuture, telecomUseFuture]).then((results) => results[0]),
          builder: (context, typeSnapshot) {
            return FutureBuilder<List<CodeModel>>(
              future: telecomUseFuture,
              builder: (context, useSnapshot) {
                if (typeSnapshot.connectionState == ConnectionState.waiting || useSnapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: LoadingButton(isWhite: false,)),
                  );
                }

                final telecomTypes = typeSnapshot.data ?? [];
                final telecomUses = useSnapshot.data ?? [];

                selectedType = telecomTypes.firstWhere(
                      (type) => type.id == telecom.type?.id,
                  orElse: () => telecomTypes.isNotEmpty ? telecomTypes.first : telecomTypes.first,
                );
                selectedUse = telecomUses.firstWhere(
                      (use) => use.id == telecom.use?.id,
                  orElse: () => telecomUses.isNotEmpty ? telecomUses.first : telecomUses.first,
                );

                return SingleChildScrollView(
                  child: Column(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Update Telecom', style: TextStyle(color: Theme.of(context).primaryColor)),
                          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.dangerous, color: Colors.grey)),
                        ],
                      ),
                      TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Value')),
                      DropdownButtonFormField<CodeModel>(
                        items: telecomTypes.map((type) => DropdownMenuItem<CodeModel>(value: type, child: Text(type.display))).toList(),
                        onChanged: (value) => setState(() => selectedType = value),
                        decoration: const InputDecoration(labelText: 'Type'),
                        value: selectedType,
                      ),
                      DropdownButtonFormField<CodeModel>(
                        items: telecomUses.map((use) => DropdownMenuItem<CodeModel>(value: use, child: Text(use.display))).toList(),
                        onChanged: (value) => setState(() => selectedUse = value),
                        decoration: const InputDecoration(labelText: 'Use'),
                        value: selectedUse,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 30,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              if (valueController.text.isNotEmpty && selectedType != null && selectedUse != null) {
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
                                telecomCubit.updateTelecom(id: telecom.id!, telecomModel: updatedTelecom);

                                Navigator.pop(context);

                              } else {
                                ShowToast.showToastError(message: "All fields are required");
                              }
                            },
                            child: const Text('Update'),
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
    CodeModel? selectedType;
    CodeModel? selectedUse;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: FutureBuilder<List<CodeModel>>(
              future: Future.wait([telecomTypesFuture, telecomUseFuture]).then((results) => results[0]),
              builder: (context, typeSnapshot) {
                return FutureBuilder<List<CodeModel>>(
                  future: telecomUseFuture,
                  builder: (context, useSnapshot) {
                    if (typeSnapshot.connectionState == ConnectionState.waiting || useSnapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: LoadingButton(isWhite: false,)),
                      );
                    }

                    final telecomTypes = typeSnapshot.data ?? [];
                    final telecomUses = useSnapshot.data ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Create new telecom', style: TextStyle(color: Theme.of(context).primaryColor)),
                              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.dangerous, color: Colors.grey)),
                            ],
                          ),
                          TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Value')),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomTypes.map((type) => DropdownMenuItem(value: type, child: Text(type.display))).toList(),
                            onChanged: (value) => selectedType = value,
                            decoration: const InputDecoration(labelText: 'Type'),
                            value: selectedType,
                          ),
                          DropdownButtonFormField<CodeModel>(
                            items: telecomUses.map((use) => DropdownMenuItem(value: use, child: Text(use.display))).toList(),
                            onChanged: (value) => selectedUse = value,
                            decoration: const InputDecoration(labelText: 'Use'),
                            value: selectedUse,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  if (valueController.text.isNotEmpty && selectedType != null && selectedUse != null) {
                                    final newTelecom = TelecomModel(
                                      id: '',
                                      value: valueController.text,
                                      rank: '1',
                                      startDate: null,
                                      endDate: null,
                                      type: selectedType,
                                      use: selectedUse,
                                      typeId: selectedType!.id,
                                      useId: selectedUse!.id,
                                    );
                                    telecomCubit.createTelecom(telecomModel: newTelecom);
                                    Navigator.pop(context);
                                  } else {
                                    ShowToast.showToastError(message: "All fields are required");
                                  }
                                },
                                child: const Text('Create'),
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

  void _showDetailsDialog(TelecomModel telecom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Telecom Details', style: TextStyle(color: Theme.of(context).primaryColor)),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.dangerous, color: Colors.grey)),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Value: ${telecom.value}'),
                Text('Type: ${telecom.type!.display}'),
                Text('Use: ${telecom.use!.display}'),
                Text('Start Date: ${telecom.startDate ?? 'N/A'}'),
                Text('End Date: ${telecom.endDate ?? 'N/A'}'),
              ],
            ),
          ),
    );
  }

  void _showUpdateDeleteDialog(TelecomModel telecom, TelecomCubit telecomCubit) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Manage Telecom', style: TextStyle(color: Theme.of(context).primaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.dangerous, color: Colors.grey)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Value: ${telecom.value}'),
                Gap(10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateDialog(telecom,telecomCubit);
                  },
                  child: Container(
                    width: context.width / 2,
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    child: const Text('Update', style: TextStyle(color: Colors.white)),
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
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildContentForTab(CodeModel? type) {
    if (type == null) return const SizedBox.shrink();

    return BlocBuilder<TelecomCubit, TelecomState>(
      builder: (context, state) {
        if (state is TelecomInitial) {
          context.read<TelecomCubit>().fetchTelecoms(rank: '1', paginationCount: '100');
        }

        if (state is TelecomLoading) {
          return  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: LoadingButton(isWhite: false,)),
          );
        }

        final telecoms = state is TelecomSuccess ? state.paginatedResponse.paginatedData.items : [];
        final filteredTelecoms = telecoms.where((telecom) => telecom.type!.id == type.id).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    width: context.width / 2,
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text("Create new telecom", style: TextStyle(color: Colors.white)), Icon(Icons.add, color: Colors.white)],
                    ),
                  ),
                  onTap: () => _showCreateDialog(context),
                ),
                Column(
                  children:
                      filteredTelecoms
                          .map(
                            (telecom) => Card(
                              child: ListTile(
                                title: Text(telecom.value!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${telecom.use!.display}/${telecom.type!.display}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showUpdateDeleteDialog(telecom, context.read<TelecomCubit>()),
                                ),
                                onTap: () => _showDetailsDialog(telecom),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CodeModel? _selectedTab;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => serviceLocator<CodeTypesCubit>()), BlocProvider(create: (context) => serviceLocator<TelecomCubit>())],
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(10)),
        width: context.width,
        child: BlocBuilder<TelecomCubit, TelecomState>(
          builder: (context, telecomState) {
            return FutureBuilder<List<CodeModel>>(
              future: telecomTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: LoadingButton(isWhite: false));
                }

                final telecomTypes = snapshot.data!;
                if (_selectedTab == null && telecomTypes.isNotEmpty) {
                  _selectedTab = telecomTypes.first;
                }

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        child: SizedBox(height: context.height / 3.5, child: Image.asset("assets/images/telecom.jpg", fit: BoxFit.fill, width: context.width)),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: Theme.of(context).primaryColor)),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                                  telecomTypes
                                      .map(
                                        (type) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: TextButton(
                                            onPressed: () => setState(() => _selectedTab = type),
                                            child: Text(
                                              type.display,
                                              style: TextStyle(
                                                fontWeight: _selectedTab == type ? FontWeight.bold : FontWeight.w500,
                                                color:
                                                    _selectedTab == type
                                                        ? Theme.of(context).primaryColor
                                                        : Theme.of(context).primaryColor.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                        Expanded(child: _buildContentForTab(_selectedTab)),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
