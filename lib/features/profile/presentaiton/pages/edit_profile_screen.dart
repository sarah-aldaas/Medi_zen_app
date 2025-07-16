import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/update_profile_request_Model.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';

import '../../../../../../base/data/models/code_type_model.dart';
import '../../../../base/theme/app_color.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key, required this.patientModel});

  final UpdateProfileRequestModel patientModel;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ProfileCubit(
                remoteDataSource: serviceLocator(),
                networkInfo: serviceLocator(),
              ),
        ),
        BlocProvider(
          create:
              (context) => CodeTypesCubit(
                remoteDataSource: serviceLocator(),
                networkInfo: serviceLocator(),
              ),
        ),
        BlocProvider(
          create:
              (context) => EditProfileFormCubit(context.read<CodeTypesCubit>()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: 70,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.whiteColor, height: 1.0),
          ),
          leadingWidth: 100,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "editProfile.title".tr(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
                builder: (context, formState) {
                  final cubit = context.read<EditProfileFormCubit>();
                  return TextButton(
                    onPressed:
                        cubit.isFormValid()
                            ? () => cubit.submitForm(context)
                            : null,
                    child:
                        context.read<ProfileCubit>().state.status ==
                                ProfileStatus.loadignUpdate
                            ? LoadingButton(isWhite: false)
                            : Text(
                              'editProfile.updateButton'.tr(context),
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    cubit.isFormValid()
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[SizedBox(height: 20), EditProfileForm()],
            ),
          ),
        ),
      ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final EditProfileFormCubit _cubit;
  String? image;
  bool avatarChanged = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<EditProfileFormCubit>();
    context.read<ProfileCubit>().fetchMyProfile(context: context);
    _cubit.loadCodes(context: context);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success && state.patient == null) {
          ShowToast.showToasts(
            message: 'editProfile.updateSuccessMessage'.tr(context),
          );
          context.pushNamed(AppRouter.profileDetails.name);
        } else if (state.errorMessage.isNotEmpty) {
          ShowToast.showToastError(message: state.errorMessage);
        } else if (state.status == ProfileStatus.success &&
            state.patient != null) {
          _cubit.preFillForm(
            firstName: state.patient!.fName,
            lastName: state.patient!.lName,
            genderId: state.patient!.genderId?.toString(),
            maritalStatusId: state.patient!.maritalStatusId?.toString(),
            image: state.patient!.avatar,
          );
          setState(() {
            image = state.patient!.avatar;
          });
        }
      },
      builder: (context, profileState) {
        return BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
          builder: (context, formState) {
            if (formState.isLoadingCodes ||
                profileState.status == ProfileStatus.loadignUpdate) {
              return const Center(child: LoadingPage());
            }

            return Form(
              key: const Key('EditProfileForm'),
              child: Column(
                children: [
                  _buildAvatarPicker(formState.avatar),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'firstName',
                    'sign_up_page.first_name',
                    Icons.person,
                  ),
                  const Gap(12),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'lastName',
                    'sign_up_page.last_name',
                    Icons.person,
                  ),
                  const Gap(12),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'genderId',
                    'sign_up_page.gender',
                    formState.genderCodes,
                    (value) => _cubit.updateGenderId(value),
                    formState.genderId,
                  ),
                  const Gap(12),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'maritalStatusId',
                    'sign_up_page.marital_status',
                    formState.maritalStatusCodes,
                    (value) => _cubit.updateMaritalStatusId(value),
                    formState.maritalStatusId,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarPicker(File? avatar) {
    return Center(
      child: Stack(
        children: [
          avatar != null
              ? CircleAvatar(radius: 80, backgroundImage: FileImage(avatar))
              : image != null && image!.isNotEmpty
              ? CircleAvatar(
                child: ClipOval(
                  child: FlexibleImage(
                    imageUrl: image,
                    assetPath: "assets/images/person.jpg",
                  ),
                ),
                radius: 80,
              ) //AvatarImage(imageUrl: image, radius: 80, key: ValueKey(image))
              : CircleAvatar(
                radius: 80,
                backgroundImage: const AssetImage("assets/images/person.jpg"),
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 4.0,
                    ),
                  ),
                ),
              ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
              onPressed: _showImageSourceDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String key, String hintKey, IconData icon) {
    return TextFormField(
      onChanged: (value) => _cubit.updateFormData(key, value),
      initialValue: _cubit.state.formData[key],
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        hintText: hintKey.tr(context),
        prefixIcon: Icon(icon, color: const Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'sign_up_page.validation.${key}_required'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String key,
    String hintKey,
    List<CodeModel> codes,
    Function(String?) onChanged,
    String? value,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintKey.tr(context),
        prefixIcon: Icon(
          key == 'genderId' ? Icons.emoji_people : Icons.people,
          color: Theme.of(context).primaryColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      items:
          codes.map((code) {
            return DropdownMenuItem<String>(
              value: code.id.toString(),
              child: Container(
                // color: Colors.white,
                child:
                    key == 'genderId'
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                code.display.toLowerCase() == 'male'
                                    ? Icons.male
                                    : Icons.female,
                                color:
                                    code.display.toLowerCase() == 'male'
                                        ? Colors.blue
                                        : Colors.pink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(code.display),
                          ],
                        )
                        : Text(code.display),
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'sign_up_page.validation.${key.split('Id')[0]}_required'.tr(
            context,
          );
        }
        return null;
      },
    );
  }

  void _showImageSourceDialog() {
    final ThemeData theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'editProfile.selectImageSource'.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.camera,
                      color: theme.colorScheme.secondary,
                    ),
                    title: Text(
                      'editProfile.camera'.tr(context),
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          avatarChanged = true;
                          image = null;
                          debugPrint(
                            'Image cleared, new avatar: ${pickedFile.path}',
                          );
                        });
                        _cubit.updateAvatar(File(pickedFile.path));
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: theme.colorScheme.tertiary,
                    ),
                    title: Text(
                      'editProfile.gallery'.tr(context),
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          avatarChanged = true;
                          image = null;
                          debugPrint(
                            'Image cleared, new avatar: ${pickedFile.path}',
                          );
                        });
                        _cubit.updateAvatar(File(pickedFile.path));
                      }
                    },
                  ),
                  if (_cubit.state.avatar != null || image != null)
                    ListTile(
                      leading: Icon(
                        Icons.remove_circle,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        'editProfile.removeImage'.tr(context),
                        style: theme.textTheme.bodyLarge,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          avatarChanged = true;
                          image = null;
                          debugPrint('Image removed');
                        });
                        _cubit.updateAvatar(null);
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'editProfile.cancel'.tr(context),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class EditProfileFormState {
  final List<CodeModel> genderCodes;
  final List<CodeModel> maritalStatusCodes;
  final String? genderId;
  final String? maritalStatusId;
  final String? image;
  final bool isLoadingCodes;
  final Map<String, String> formData;
  final File? avatar;

  EditProfileFormState({
    this.genderCodes = const [],
    this.maritalStatusCodes = const [],
    this.genderId,
    this.maritalStatusId,
    this.isLoadingCodes = true,
    this.formData = const {'firstName': '', 'lastName': ''},
    this.avatar,
    this.image,
  });

  EditProfileFormState copyWith({
    List<CodeModel>? genderCodes,
    List<CodeModel>? maritalStatusCodes,
    String? genderId,
    String? maritalStatusId,
    String? image,
    bool? isLoadingCodes,
    Map<String, String>? formData,
    File? avatar,
  }) {
    return EditProfileFormState(
      genderCodes: genderCodes ?? this.genderCodes,
      maritalStatusCodes: maritalStatusCodes ?? this.maritalStatusCodes,
      genderId: genderId ?? this.genderId,
      maritalStatusId: maritalStatusId ?? this.maritalStatusId,
      isLoadingCodes: isLoadingCodes ?? this.isLoadingCodes,
      formData: formData ?? this.formData,
      avatar: avatar ?? this.avatar,
      image: image ?? this.image,
    );
  }
}

class EditProfileFormCubit extends Cubit<EditProfileFormState> {
  final CodeTypesCubit codeTypesCubit;
  final String id = UniqueKey().toString();

  EditProfileFormCubit(this.codeTypesCubit) : super(EditProfileFormState()) {
    debugPrint('EditProfileFormCubit created: $id');
  }

  Future<void> loadCodes({required BuildContext context}) async {
    if (state.isLoadingCodes) {
      final results = await Future.wait([
        codeTypesCubit.getGenderCodes(context: context),
        codeTypesCubit.getMaritalStatusCodes(context: context),
      ]);
      final uniqueGenderCodes = <String, CodeModel>{};
      final uniqueMaritalStatusCodes = <String, CodeModel>{};

      for (var code in results[0]) {
        uniqueGenderCodes[code.id.toString()] = code;
      }
      for (var code in results[1]) {
        uniqueMaritalStatusCodes[code.id.toString()] = code;
      }

      debugPrint('Gender Codes: ${uniqueGenderCodes.values.toList()}');
      debugPrint(
        'Marital Status Codes: ${uniqueMaritalStatusCodes.values.toList()}',
      );

      emit(
        state.copyWith(
          genderCodes: uniqueGenderCodes.values.toList(),
          maritalStatusCodes: uniqueMaritalStatusCodes.values.toList(),
          isLoadingCodes: false,
          genderId:
              state.genderId ?? uniqueGenderCodes.values.first.id.toString(),
          maritalStatusId:
              state.maritalStatusId ??
              uniqueMaritalStatusCodes.values.first.id.toString(),
        ),
      );
    }
  }

  void updateFormData(String key, String value) {
    final newFormData = Map<String, String>.from(state.formData)..[key] = value;
    emit(state.copyWith(formData: newFormData));
  }

  void updateGenderId(String? value) {
    debugPrint('Updated genderId: $value');
    emit(state.copyWith(genderId: value));
  }

  void updateMaritalStatusId(String? value) {
    debugPrint('Updated maritalStatusId: $value');
    emit(state.copyWith(maritalStatusId: value));
  }

  void updateAvatar(File? avatar) {
    emit(state.copyWith(avatar: avatar));
  }

  void preFillForm({
    required String? firstName,
    required String? lastName,
    required String? genderId,
    required String? maritalStatusId,
    String? image,
  }) {
    debugPrint(
      'Pre-filling form: firstName=$firstName, lastName=$lastName, genderId=$genderId, maritalStatusId=$maritalStatusId, image=$image',
    );
    final newFormData =
        Map<String, String>.from(state.formData)
          ..['firstName'] = firstName ?? ''
          ..['lastName'] = lastName ?? '';
    final validGenderId =
        state.genderCodes.any((code) => code.id.toString() == genderId)
            ? genderId
            : state.genderCodes.isNotEmpty
            ? state.genderCodes.first.id.toString()
            : null;
    final validMaritalStatusId =
        state.maritalStatusCodes.any(
              (code) => code.id.toString() == maritalStatusId,
            )
            ? maritalStatusId
            : state.maritalStatusCodes.isNotEmpty
            ? state.maritalStatusCodes.first.id.toString()
            : null;
    emit(
      state.copyWith(
        formData: newFormData,
        genderId: validGenderId,
        maritalStatusId: validMaritalStatusId,
        avatar: null,
        image: image,
      ),
    );
  }

  void submitForm(BuildContext context) {
    if (isFormValid()) {
      final cubit = context.read<ProfileCubit>();
      cubit.updateMyProfile(
        context: context,
        updateProfileRequestModel: UpdateProfileRequestModel(
          fName: state.formData['firstName']!,
          lName: state.formData['lastName']!,
          avatar: state.avatar,
          image: state.image,
          genderId: state.genderId!,
          maritalStatusId: state.maritalStatusId!,
        ),
      );
    }
  }

  bool isFormValid() {
    final data = state.formData;
    debugPrint(
      'Form Validation: firstName=${data['firstName']}, lastName=${data['lastName']}, genderId=${state.genderId}, maritalStatusId=${state.maritalStatusId}',
    );
    return data['firstName']!.isNotEmpty &&
        data['lastName']!.isNotEmpty &&
        state.genderId != null &&
        state.maritalStatusId != null;
  }
}
