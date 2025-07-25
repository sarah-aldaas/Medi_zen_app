import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
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
  final ImagePicker _picker = ImagePicker();
  List<File> _attachments = [];

  @override
  void initState() {
    super.initState();

    context.read<CodeTypesCubit>().getComplainTypeCodes(context: context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _attachments.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _attachments.add(File(pickedFile.path));
      });
    }
  }

  void _submitComplain() {
    print("********************************");
    print(_attachments.length);
    print("********************************");

    if (_formKey.currentState!.validate()) {
      final complain = ComplainModel(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        attachmentsFiles: _attachments,
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
          })
          .catchError((error) {
            ShowToast.showToastError(message: error.toString());
          });
    }
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'createComplainPage.createComplain_titleLabel'.tr(
                    context,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 22),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      'createComplainPage.createComplain_descriptionLabel'.tr(
                        context,
                      ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 22),
              BlocBuilder<CodeTypesCubit, CodeTypesState>(
                builder: (context, state) {
                  if (state is CodeTypesInitial) {
                    context.read<CodeTypesCubit>().getComplainTypeCodes(
                      context: context,
                    );
                  }
                  if (state is CodeTypesLoading || state is CodesLoading) {
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
                          : <CodeModel>[];

                  return DropdownButtonFormField<CodeModel>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'createComplainPage.createComplain_typeLabel'
                          .tr(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      ...?types?.map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.display ?? ''),
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

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        'createComplainPage.createComplain_addFromGallery'.tr(
                          context,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        'createComplainPage.createComplain_takePhoto'.tr(
                          context,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(_attachments[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _attachments.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitComplain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
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
}
