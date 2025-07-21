import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/profile/data/models/update_profile_request_Model.dart';
import 'package:medizen_app/features/profile/presentaiton/cubit/profile_cubit/profile_cubit.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/address_model.dart';

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

  Widget _buildInfoTile(IconData icon, String titleKey, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        titleKey.tr(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildSectionTitle(String titleKey, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Gap(8),
          Text(
            titleKey.tr(context),
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

  Widget _buildNavigationItem(
    String titleKey,
    IconData icon,
    VoidCallback onTap,
  ) {
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
                titleKey.tr(context),
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
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.whiteColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "${patient.fName ?? ''} ${patient.lName ?? ''}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        FlexibleImage(
                          imageUrl: patient.avatar ?? '',
                          errorWidget: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white70,
                          ),
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
                              image: patient.avatar,
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
                                "profileDetailsPage.email",
                                patient.email ?? 'N/A',
                              ),
                              _buildInfoTile(
                                Icons.person_outline,
                                "profileDetailsPage.gender",
                                patient.gender?.display ?? 'N/A',
                              ),
                              _buildInfoTile(
                                Icons.favorite_outline,
                                "profileDetailsPage.maritalStatus",
                                patient.maritalStatus?.display ?? 'N/A',
                              ),
                              if (patient.dateOfBirth != null)
                                _buildInfoTile(
                                  Icons.cake_outlined,
                                  "profileDetailsPage.age",
                                  '${_calculateAge(patient.dateOfBirth!)} ${"profileDetailsPage.age".tr(context).toLowerCase().replaceAll(':', '')}',
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "profileDetailsPage.aboutMe",
                        Icons.info_outline,
                      ),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            patient.text ??
                                'profileDetailsPage.noBioAvailable'.tr(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "profileDetailsPage.healthSnapshot",
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
                          title: Text(
                            "profileDetailsPage.healthInformation".tr(context),
                            style: const TextStyle(
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
                                      "${"profileDetailsPage.bloodType".tr(context)}: ${patient.bloodType!.display}",
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
                                    "${"profileDetailsPage.height".tr(context)}: ${patient.height?.toString() ?? 'N/A'} cm",
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
                                    "${"profileDetailsPage.weight".tr(context)}: ${patient.weight?.toString() ?? 'N/A'} kg",
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
                                      "${"profileDetailsPage.birthDate".tr(context)}: ${patient.dateOfBirth!}",
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
                                    "${"profileDetailsPage.smoker".tr(context)}: ${patient.smoker == true ? 'Yes' : 'No'}",
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
                                    "${"profileDetailsPage.alcohol".tr(context)}: ${patient.alcoholDrinker == true ? 'Yes' : 'No'}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _buildSectionTitle(
                        "profileDetailsPage.contactInformation",
                        Icons.contact_phone,
                      ),
                      const Gap(30),
                      _buildNavigationItem(
                        "profileDetailsPage.telecom",
                        Icons.phone,
                        () {
                          context.pushNamed(AppRouter.telecomDetails.name);
                        },
                      ),
                      _buildNavigationItem(
                        "profileDetailsPage.address",
                        Icons.home,
                        () {
                          context.pushNamed(
                            AppRouter.addressListPage.name,
                            extra: {
                              'addresses':
                                  patient.addressModel != null
                                      ? [patient.addressModel!]
                                      : <AddressModel>[],
                            },
                          );
                        },
                      ),
                      const Gap(40),
                    ]),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text("profileDetailsPage.noDataAvailable".tr(context)),
          );
        },
      ),
    );
  }
}
