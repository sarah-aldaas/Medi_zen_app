import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import '../../../../../../base/data/models/code_type_model.dart';
import '../../../../data/models/update_profile_request_Model.dart';
import '../../../cubit/profile_cubit/profile_cubit.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit(remoteDataSource: serviceLocator()),
        ),
        BlocProvider(
          create: (context) => CodeTypesCubit(remoteDataSource: serviceLocator()),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Edit profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 50),
                const EditProfileForm(),
              ],
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

  @override
  void initState() {
    super.initState();
    _cubit = EditProfileFormCubit(context.read<CodeTypesCubit>());
    _cubit.loadCodes();
    context.read<ProfileCubit>().fetchMyProfile(); // Fetch profile data on init
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
      ],
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success && state.patient == null) {
            ShowToast.showToastSuccess(message: 'Profile updated successfully');
            context.pushNamed(AppRouter.profile.name);
          } else if (state.errorMessage.isNotEmpty) {
            ShowToast.showToastError(message: state.errorMessage);
          }
        },
        builder: (context, profileState) {
          return BlocBuilder<EditProfileFormCubit, EditProfileFormState>(
            builder: (context, formState) {
              if (formState.isLoadingCodes || profileState.status == ProfileStatus.loading) {
                return const Center(child: LoadingPage());
              }

              // Pre-fill form with profile data if available
              if (profileState.patient != null && formState.formData['firstName']!.isEmpty) {
                _cubit.preFillForm(
                  firstName: profileState.patient!.fName,
                  lastName: profileState.patient!.lName,
                  email: profileState.patient!.email,
                  genderId: profileState.patient!.genderId?.toString(),
                  maritalStatusId: profileState.patient!.maritalStatusId?.toString(),
                );
              }

              return Form(
                key: const Key('EditProfileForm'),
                child: Column(
                  children: [
                    _buildAvatarPicker(formState.avatar),
                    const SizedBox(height: 20),
                    _buildTextField('firstName', 'sign_up_page.first_name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField('lastName', 'sign_up_page.last_name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextField('email', 'sign_up_page.email', Icons.email),
                    const SizedBox(height: 20),
                    _buildDropdown('genderId', 'sign_up_page.gender', formState.genderCodes, (value) => _cubit.updateGenderId(value)),
                    const SizedBox(height: 20),
                    _buildDropdown('maritalStatusId', 'sign_up_page.marital_status', formState.maritalStatusCodes, (value) => _cubit.updateMaritalStatusId(value)),
                    const SizedBox(height: 40),
                    _buildEditProfileButton(context, profileState),
                    const SizedBox(height: 20),
                    _buildLoginLink(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvatarPicker(File? avatar) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatar != null ? FileImage(avatar) : null,
            child: avatar == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
              onPressed: () async {
                // final picker = ImagePicker();
                // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                // if (pickedFile != null) {
                //   _cubit.updateAvatar(File(pickedFile.path));
                // }
              },
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
        if (key == 'email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'sign_up_page.validation.email_invalid'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String key, String hintKey, List<CodeModel> codes, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: key == 'genderId' ? _cubit.state.genderId : _cubit.state.maritalStatusId,
      decoration: InputDecoration(
        hintText: hintKey.tr(context),
        prefixIcon: Icon(key == 'genderId' ? Icons.male : Icons.people, color: const Color(0xFF47BD93)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      items: codes.map((code) {
        return DropdownMenuItem<String>(
          value: code.id.toString(),
          child: key == 'genderId'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  code.display.toLowerCase() == 'male' ? Icons.male : Icons.female,
                  color: code.display.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
                ),
              ),
              Text(code.display),
            ],
          )
              : Text(code.display),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'sign_up_page.validation.${key.split('Id')[0]}_required'.tr(context);
        }
        return null;
      },
    );
  }

  Widget _buildEditProfileButton(BuildContext context, ProfileState profileState) {
    return ElevatedButton(
      onPressed: _cubit.isFormValid() ? () => _cubit.submitForm(context) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: context.width / 3, vertical: 15),
      ),
      child: profileState.status == ProfileStatus.loading
          ? const LoadingButton(isWhite: true)
          : Text("sign_up_page.update_profile".tr(context), style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("sign_up_page.already_have_account".tr(context)),
        TextButton(
          onPressed: () {
            context.pushNamed(AppRouter.login.name);
          },
          child: Text("sign_up_page.login".tr(context), style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
      ],
    );
  }
}

class EditProfileFormState {
  final List<CodeModel> genderCodes;
  final List<CodeModel> maritalStatusCodes;
  final String? genderId;
  final String? maritalStatusId;
  final bool isLoadingCodes;
  final Map<String, String> formData;
  final File? avatar;

  EditProfileFormState({
    this.genderCodes = const [],
    this.maritalStatusCodes = const [],
    this.genderId,
    this.maritalStatusId,
    this.isLoadingCodes = true,
    this.formData = const {'firstName': '', 'lastName': '', 'email': ''},
    this.avatar,
  });

  EditProfileFormState copyWith({
    List<CodeModel>? genderCodes,
    List<CodeModel>? maritalStatusCodes,
    String? genderId,
    String? maritalStatusId,
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
    );
  }
}

class EditProfileFormCubit extends Cubit<EditProfileFormState> {
  final CodeTypesCubit codeTypesCubit;

  EditProfileFormCubit(this.codeTypesCubit) : super(EditProfileFormState());

  Future<void> loadCodes() async {
    if (state.isLoadingCodes) {
      final results = await Future.wait([codeTypesCubit.getGenderCodes(), codeTypesCubit.getMaritalStatusCodes()]);
      final uniqueGenderCodes = <String, CodeModel>{};
      final uniqueMaritalStatusCodes = <String, CodeModel>{};

      for (var code in results[0]) {
        uniqueGenderCodes[code.id.toString()] = code;
      }
      for (var code in results[1]) {
        uniqueMaritalStatusCodes[code.id.toString()] = code;
      }

      emit(state.copyWith(
        genderCodes: uniqueGenderCodes.values.toList(),
        maritalStatusCodes: uniqueMaritalStatusCodes.values.toList(),
        isLoadingCodes: false,
        genderId: uniqueGenderCodes.isNotEmpty ? uniqueGenderCodes.values.first.id.toString() : null,
        maritalStatusId: uniqueMaritalStatusCodes.isNotEmpty ? uniqueMaritalStatusCodes.values.first.id.toString() : null,
      ));
    }
  }

  void updateFormData(String key, String value) {
    final newFormData = Map<String, String>.from(state.formData)..[key] = value;
    emit(state.copyWith(formData: newFormData));
  }

  void updateGenderId(String? value) {
    emit(state.copyWith(genderId: value));
  }

  void updateMaritalStatusId(String? value) {
    emit(state.copyWith(maritalStatusId: value));
  }

  void updateAvatar(File avatar) {
    emit(state.copyWith(avatar: avatar));
  }

  void preFillForm({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? genderId,
    required String? maritalStatusId,
  }) {
    final newFormData = Map<String, String>.from(state.formData)
      ..['firstName'] = firstName ?? ''
      ..['lastName'] = lastName ?? ''
      ..['email'] = email ?? '';
    emit(state.copyWith(
      formData: newFormData,
      genderId: genderId ?? state.genderId,
      maritalStatusId: maritalStatusId ?? state.maritalStatusId,
    ));
  }

  void submitForm(BuildContext context) {
    if (isFormValid()) {
      final cubit = context.read<ProfileCubit>();
      cubit.updateMyProfile(
        updateProfileRequestModel: UpdateProfileRequestModel(
          fName: state.formData['firstName']!,
          lName: state.formData['lastName']!,
          avatar: state.avatar,
          genderId: state.genderId!,
          maritalStatusId: state.maritalStatusId!,
        ),
      );
    }
  }

  bool isFormValid() {
    final data = state.formData;
    return data['firstName']!.isNotEmpty &&
        data['lastName']!.isNotEmpty &&
        data['email']!.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data['email']!) &&
        state.genderId != null &&
        state.maritalStatusId != null;
  }
}

class LoadingButton extends StatelessWidget {
  final bool isWhite;
  const LoadingButton({super.key, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: isWhite ? Colors.white : Theme.of(context).primaryColor,
      ),
    );
  }
}