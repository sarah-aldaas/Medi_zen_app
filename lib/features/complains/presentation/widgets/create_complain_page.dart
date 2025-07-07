import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';
import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
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
        title: Text('Create complaint'),
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
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'titleRequired';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'description',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'descriptionRequired';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<CodeTypesCubit, CodeTypesState>(
                builder: (context, state) {
                  if(state is CodeTypesInitial){
                    context.read<CodeTypesCubit>().getComplainTypeCodes(context: context);
                  }
                  if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial ) {
                    return  LoadingButton();
                  }

                  final types = state is CodeTypesSuccess
                      ? state.codes?.where((code) => code.codeTypeModel?.name == 'complaint_type').toList()
                      : [];

                  return DropdownButtonFormField<CodeModel>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'type',
                    ),
                    items: [
                      ...?types?.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.display),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedType = value),
                    validator: (value) {
                      if (value == null) {
                        return 'typeRequired';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitComplain,
                child: Text('submit'),
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

      context.read<ComplainCubit>().createComplain(
        appointmentId: widget.appointmentId,
        complain: complain,
        context: context,
      ).then((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
}