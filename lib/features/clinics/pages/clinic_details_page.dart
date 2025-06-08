import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/clinics/data/models/clinic_model.dart';
import 'package:medizen_app/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';

import '../../doctor/data/datasource/doctor_remote_datasource.dart';
import '../../doctor/data/model/doctor_model.dart';
import '../../doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import '../../services/data/model/health_care_services_model.dart';
import '../data/datasources/clinic_remote_datasources.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key, required this.clinicId});

  final String clinicId;

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  late ClinicCubit _clinicCubit;
  late DoctorCubit _doctorCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _clinicCubit = ClinicCubit(
      remoteDataSource: serviceLocator<ClinicRemoteDataSource>(),
    );
    _doctorCubit = DoctorCubit(
      remoteDataSource: serviceLocator<DoctorRemoteDataSource>(),
    );
    _clinicCubit.getSpecificClinic(id: widget.clinicId);
    _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
  }

  @override
  void dispose() {
    _clinicCubit.close();
    _doctorCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),

          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        toolbarHeight: 70,

        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: BlocBuilder<ClinicCubit, ClinicState>(
          bloc: _clinicCubit,
          builder: (context, state) {
            TextStyle appBarTitleStyle =
                Theme.of(context).appBarTheme.titleTextStyle ??
                    Theme.of(
                      context,
                    ).textTheme.displayLarge!.copyWith(fontSize: 20); // fallback

            if (state is ClinicLoadedSuccess) {
              return Text(state.clinic.name, style: appBarTitleStyle);
            }
            return Text(
              'clinicDetails.clinicDetails'.tr(context),
              style: appBarTitleStyle.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
        elevation: 1,
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<ClinicCubit, ClinicState>(
        bloc: _clinicCubit,
        builder: (context, clinicState) {
          if (clinicState is ClinicLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (clinicState is ClinicError) {
            return Center(
              child: Text(
                'clinicDetails.errorLoadingClinic'.tr(context),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }
          if (clinicState is ClinicLoadedSuccess) {
            return _buildClinicDetails(clinicState.clinic);
          }
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildClinicDetails(ClinicModel clinic) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClinicImage(clinic),
            const Gap(20),
            Text(
              clinic.description,
              style: TextStyle(
                fontSize: 16,

                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
            const Gap(32),
            _buildDoctorsSection(),
            const Gap(32),
            _buildServicesSection(
              clinic.healthCareServices as List<HealthCareServiceModel>? ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicImage(ClinicModel clinic) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 2,

        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            clinic.photo,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                Image.asset(AppAssetImages.clinic6, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      bloc: _doctorCubit,
      builder: (context, state) {
        Widget content;

        TextStyle sectionTitleStyle = Theme.of(context).textTheme.displayLarge!
            .copyWith(fontSize: 20, fontWeight: FontWeight.bold);
        TextStyle normalTextStyle = Theme.of(context).textTheme.bodyLarge!;

        if (state is LoadedDoctorsOfClinicSuccess) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    'clinicDetails.ourDedicatedDoctors'.tr(context) +
                        "(${state.allDoctors.length})",
                    style: sectionTitleStyle,
                  ),
                ],
              ),
              const Gap(16),
              if (state.allDoctors.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'clinicDetails.noAvailable'.tr(context),
                    style: normalTextStyle.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.allDoctors.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) => const Gap(16),
                  itemBuilder: (context, index) {
                    if (index < state.allDoctors.length) {
                      return _buildDoctorItem(state.allDoctors[index]);
                    } else if (state.hasMore) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child:
                          _doctorCubit.isLoading
                              ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          )
                              : TextButton(
                            onPressed: () {
                              _doctorCubit.getDoctorsOfClinic(
                                clinicId: widget.clinicId,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                              Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'clinicDetails.loadMore'.tr(context),
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                Theme.of(
                                  context,
                                ).textTheme.labelLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
            ],
          );
        } else if (state is DoctorError) {
          content = Center(
            child: Column(
              children: [
                Text(
                  'clinicDetails.errorLoadingDoctors'.tr(context),
                  style: normalTextStyle.copyWith(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                TextButton(
                  onPressed: () {
                    _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'clinicDetails.retryLoading'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.labelLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is DoctorLoading && !_doctorCubit.isLoading) {
          content = Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        } else {
          content = const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: content,
        );
      },
    );
  }

  Widget _buildDoctorItem(DoctorModel doctor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),

      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            AppRouter.doctorDetails.name,
            extra: {"doctorModel": doctor},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      doctor.avatar,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                        Icons.person_outline,
                        size: 60,

                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${doctor.fName} ${doctor.lName}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,

                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      doctor.text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const Gap(8),
                        Text(
                          doctor.telecoms!.isNotEmpty
                              ? doctor.telecoms![0].value!
                              : 'clinicDetails.noContact'.tr(context),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(16),
                        Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            doctor.address,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color:
                              Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              //
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(List<HealthCareServiceModel> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const Gap(8),
            Text(
              'clinicDetails.ourServices'.tr(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,

                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const Gap(16),
        if (services.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                const Gap(8),
                Text(
                  'clinicDetails.noServicesAvailable'.tr(context),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          )
        else
          Card(
            elevation: 2,

            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ClinicServicesPage(services: services),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "clinicDetails.viewOurServices".tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,

                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.5),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ClinicServicesPage extends StatelessWidget {
  const ClinicServicesPage({super.key, required this.services});

  final List<HealthCareServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'clinicDetails.ourServices'.tr(context),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 1,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        services.isEmpty
            ? Center(
          child: Text(
            'clinicDetails.noServicesAvailable'.tr(
              context,
            ), // Localized
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        )
            : ListView.separated(
          itemCount: services.length,
          separatorBuilder:
              (context, index) =>
              Divider(color: Theme.of(context).dividerColor),
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              elevation: 2,

              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              service.photo!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).iconTheme.color?.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                service.comment ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(25),
                    Text(
                      service.extraDetails ??
                          'clinicDetails.noExtra'.tr(context),
                      style: TextStyle(
                        color:
                        Theme.of(
                          context,
                        ).textTheme.bodySmall?.color,
                      ),
                    ),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'clinicDetails.appointment'.tr(context),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const Gap(10),
                            Icon(
                              service.appointmentRequired!
                                  ? Icons.check_circle_outline
                                  : Icons.block,
                              color:
                              service.appointmentRequired!
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withOpacity(0.5),
                            ),
                            const Gap(12),
                            Text(
                              service.price ??
                                  'clinicDetails.free'.tr(context),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pushNamed(
                            AppRouter.healthServiceDetails.name,
                            extra: {"serviceId": service.id.toString()},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.9),
                          // foregroundColor:
                          //     Theme.of(context).buttonTheme.textTheme ==
                          //             ButtonTextTheme.primary
                          //         ? Theme.of(
                          //           context,
                          //         ).textTheme.labelLarge?.color
                          //         : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'clinicDetails.viewOurServices'.tr(context),
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
