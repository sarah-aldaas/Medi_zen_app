import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/update_profile_request_Model.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/telecom_cubit/telecom_cubit.dart';
import 'package:medizen_app/features/profile/presentaiton/pages/telecom_page.dart';

import '../cubit/profile_cubit/profile_cubit.dart';
import '../widgets/address/address_list_page.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  int _calculateAge(String dateOfBirthStr) {
    final dob = DateTime.parse(dateOfBirthStr);
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            context.goNamed(AppRouter.homePage.name);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.success &&
                  state.patient != null) {
                return IconButton(
                  onPressed: () {
                    // Navigate to an edit page or show a dialog to edit the profile
                    // context.pushNamed('editProfile', extra: state.patient);
                    context.pushNamed(
                      AppRouter.editProfile.name,
                      extra: {
                        'patientModel': UpdateProfileRequestModel(
                          image: state.patient!.active,
                          genderId: state.patient!.genderId,
                          maritalStatusId: state.patient!.maritalStatusId,
                          fName: state.patient!.fName,
                          lName: state.patient!.lName,
                        ),
                      },
                    );
                  },
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error) {
            ShowToast.showToastError(message: state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: LoadingPage());
          }

          if (state.status == ProfileStatus.error) {
            return Center(child: Text(state.errorMessage));
          }

          if (state.status == ProfileStatus.success && state.patient != null) {
            final patient = state.patient!;
            return Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // AvatarImage(imageUrl: patient.avatar, radius: 70),
                    const Gap(30),
                    Text(
                      "${patient.fName ?? 'N/A'} ${patient.lName ?? 'N/A'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(patient.email),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (patient.bloodType != null &&
                            patient.bloodType!.display != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.bloodtype),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      patient.bloodType!.display,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.person),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    patient.gender!.display,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.favorite),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    patient.maritalStatus!.display,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(30),
                    Container(
                      width: context.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bio",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Text(
                            patient.text ?? 'No bio available',
                            maxLines: 4,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(30),
                    Row(
                      children: [
                        Text(
                          "Telecom",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.phone,
                          color: Theme.of(context).primaryColor,
                          size: 15,
                        ),
                      ],
                    ),
                    const Gap(10),
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => serviceLocator<CodeTypesCubit>(),
                        ),
                        BlocProvider(
                          create: (context) => serviceLocator<TelecomCubit>(),
                        ),
                      ],
                      child: const TelecomPage(),
                    ),
                    const Gap(30),
                    Row(
                      children: [
                        Text(
                          "Address",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.home,
                          color: Theme.of(context).primaryColor,
                          size: 15,
                        ),
                      ],
                    ),
                    const Gap(10),
                    SizedBox(
                        height: context.height/1.5,
                        child: AddressListPage()),
                    // AddressPage(addressModel: patient.addressModel),
                    const Gap(30),
                    Row(
                      children: [
                        Text(
                          "Health Information",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    SizedBox(
                      width: context.width,
                      child: Table(
                        border: TableBorder.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(60), // Icon column
                          1: IntrinsicColumnWidth(), // Attribute column
                          2: IntrinsicColumnWidth(), // Value column
                          3: FixedColumnWidth(80), // Image column
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.info,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Attribute",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Value",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Image",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.height,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Height"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${patient.height ?? 'N/A'} cm"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "assets/images/height.jpg",
                                    width: 40,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.height,
                                        size: 40,
                                      ); // Fallback icon
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Weight"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${patient.weight ?? 'N/A'} kg"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "assets/images/weight.jpg",
                                    width: 40,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.fitness_center,
                                        size: 40,
                                      ); // Fallback icon
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.cake,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Birth and Age"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "${patient.dateOfBirth != null ? _calculateAge(patient.dateOfBirth!) : 'N/A'} years",
                                    ),
                                    const Gap(5),
                                    Text(patient.dateOfBirth ?? 'N/A'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "assets/images/age.png",
                                    width: 40,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.cake,
                                        size: 40,
                                      ); // Fallback icon
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.smoking_rooms,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Smoker"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  patient.smoker == true ? 'Yes' : 'No',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "assets/images/smoker.jpg",
                                    width: 40,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.smoking_rooms,
                                        size: 40,
                                      ); // Fallback icon
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.local_drink,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Alcohol Drinker"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  patient.alcoholDrinker == true ? 'Yes' : 'No',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "assets/images/drink.png",
                                    width: 40,
                                    height: 80,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.local_drink,
                                        size: 40,
                                      ); // Fallback icon
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Gap(40),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
