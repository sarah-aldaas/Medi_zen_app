import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';

import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/theme/app_color.dart';
import '../cubit/complain_cubit/complain_cubit.dart';

class CreateComplainPage extends StatefulWidget {
  final String appointmentId;

  const CreateComplainPage({super.key, required this.appointmentId});

  @override
  _CreateComplainPageState createState() => _CreateComplainPageState();
}

class _CreateComplainPageState extends State<CreateComplainPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  CodeModel? _selectedType;

  @override
  void initState() {
    context.read<CodeTypesCubit>().getComplainTypeCodes(context: context);
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text('createComplainPage.createComplain_pageTitle'.tr(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'createComplainPage.createComplain_titleLabel'.tr(
                    context,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'createComplainPage.createComplain_titleRequired'.tr(
                      context,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      'createComplainPage.createComplain_descriptionLabel'.tr(
                        context,
                      ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'createComplainPage.createComplain_descriptionRequired'
                        .tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<CodeTypesCubit, CodeTypesState>(
                builder: (context, state) {
                  if (state is CodeTypesInitial) {
                    context.read<CodeTypesCubit>().getComplainTypeCodes(
                      context: context,
                    );
                  }
                  if (state is CodeTypesLoading ||
                      state is CodesLoading ||
                      state is CodeTypesInitial) {
                    return const Center(child: LoadingPage());
                  }

                  final types =
                      state is CodeTypesSuccess
                          ? state.codes
                              ?.where(
                                (code) =>
                                    code.codeTypeModel?.name ==
                                    'complaint_type',
                              )
                              .toList()
                          : [];

                  return DropdownButtonFormField<CodeModel>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'createComplainPage.createComplain_typeLabel'
                          .tr(context),
                    ),
                    items: [
                      ...?types?.map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.display),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedType = value),
                    validator: (value) {
                      if (value == null) {
                        return 'createComplainPage.createComplain_typeRequired'
                            .tr(context);
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitComplain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),

                  elevation: 3,
                ),
                child: Text(
                  'createComplainPage.createComplain_submit'.tr(context),
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitComplain() {
    if (_formKey.currentState!.validate()) {
      final complain = ComplainModel(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
      );

      context
          .read<ComplainCubit>()
          .createComplain(
            appointmentId: widget.appointmentId,
            complain: complain,
            context: context,
          )
          .then((_) {
            if (mounted) {
              Navigator.pop(context);
            }
          });
    }
  }
}
