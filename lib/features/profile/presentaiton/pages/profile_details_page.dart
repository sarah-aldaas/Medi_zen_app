import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/update_profile_request_Model.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';

import '../../../../base/theme/app_color.dart';

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

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Gap(8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "${patient.fName ?? 'N/A'} ${patient.lName ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (patient.active != null)
                          Image.network(
                            patient.active!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white70,
                                ),
                          )
                        else
                          const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white70,
                          ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black, Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.editProfile.name,
                          extra: {
                            'patientModel': UpdateProfileRequestModel(
                              image: patient.active,
                              genderId: patient.genderId,
                              maritalStatusId: patient.maritalStatusId,
                              fName: patient.fName,
                              lName: patient.lName,
                            ),
                          },
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const Gap(8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoTile(
                                Icons.email_outlined,
                                "Email",
                                patient.email,
                              ),
                              _buildInfoTile(
                                Icons.person_outline,
                                "Gender",
                                patient.gender.display,
                              ),
                              _buildInfoTile(
                                Icons.favorite_outline,
                                "Marital Status",
                                patient.maritalStatus.display,
                              ),
                              if (patient.dateOfBirth != null)
                                _buildInfoTile(
                                  Icons.cake_outlined,
                                  "Age",
                                  '${_calculateAge(patient.dateOfBirth!)} years',
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle("About Me", Icons.info_outline),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            patient.text ?? 'No bio available',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "Health Snapshot",
                        Icons.healing_outlined,
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        child: ExpansionTile(
                          leading: const Icon(
                            Icons.medical_information_outlined,
                            color: AppColors.primaryColor,
                          ),
                          title: const Text(
                            "Health Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: <Widget>[
                            if (patient.bloodType != null &&
                                patient.bloodType!.display != null)
                              Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.bloodtype,
                                      color: AppColors.primaryColor,
                                    ),
                                    title: Text(
                                      "Blood Type: ${patient.bloodType!.display}",
                                    ),
                                  ),
                                  const Divider(indent: 16.0, endIndent: 16.0),
                                ],
                              ),
                            Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.height,
                                    color: AppColors.primaryColor,
                                  ),
                                  title: Text(
                                    "Height: ${patient.height ?? 'N/A'} cm",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primaryColor,
                                  ),
                                  title: Text(
                                    "Weight: ${patient.weight ?? 'N/A'} kg",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            if (patient.dateOfBirth != null)
                              Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.primaryColor,
                                    ),
                                    title: Text(
                                      "Birth Date: ${patient.dateOfBirth!}",
                                    ),
                                  ),
                                  const Divider(indent: 16.0, endIndent: 16.0),
                                ],
                              ),
                            Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.smoke_free,
                                    color: AppColors.primaryColor,
                                  ),
                                  title: Text(
                                    "Smoker: ${patient.smoker == true ? 'Yes' : 'No'}",
                                  ),
                                ),
                                const Divider(indent: 16.0, endIndent: 16.0),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.local_bar_outlined,
                                    color: AppColors.primaryColor,
                                  ),
                                  title: Text(
                                    "Alcohol: ${patient.alcoholDrinker == true ? 'Yes' : 'No'}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "Contact Information",
                        Icons.contact_phone,
                      ),
                      _buildNavigationItem("Telecom", Icons.phone, () {
                        context.pushNamed(AppRouter.telecomDetails.name);
                      }),
                      _buildNavigationItem("Address", Icons.home, () {
                        if (patient.addressModel != null) {
                          context.pushNamed(
                            AppRouter
                                .addressDetails
                                .name, // تأكد من أن هذا هو نفس الاسم المستخدم في تعريف الـ GoRoute
                            extra: {
                              'addressModel':
                                  patient
                                      .addressModel!, // تمرير الـ AddressModel هنا
                            },
                          );
                        } else {
                          ShowToast.showToastInfo(
                            message: "No address information available.",
                          );
                        }
                      }),

                      // else {
                      //   ShowToast.showToastInfo(
                      //     message: "No address information available.",
                      //   );
                      // }
                      //            }
                      const Gap(40),
                    ]),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
