import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medizen_app/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:medizen_app/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';

import '../../../base/theme/app_color.dart';
import '../../doctor/data/model/doctor_model.dart';
import '../data/models/clinic_model.dart';
import 'cubit/clinic_cubit/clinic_cubit.dart';

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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: BlocBuilder<ClinicCubit, ClinicState>(
          bloc: _clinicCubit,
          builder: (context, state) {
            if (state is ClinicLoadedSuccess) {
              return Text(
                state.clinic.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              );
            }
            return const Text(
              'Clinic Details',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            );
          },
        ),
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<ClinicCubit, ClinicState>(
        bloc: _clinicCubit,
        builder: (context, clinicState) {
          if (clinicState is ClinicLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (clinicState is ClinicError) {
            return Center(child: Text(clinicState.error));
          }
          if (clinicState is ClinicLoadedSuccess) {
            return _buildClinicDetails(clinicState.clinic);
          }
          return const Center(child: CircularProgressIndicator());
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const Gap(32),
            _buildDoctorsSection(),
            const Gap(32),
            _buildServicesSection(
              clinic.healthCareServices as List<HealthCareServiceModel> ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicImage(ClinicModel clinic) {
    return SizedBox(
      width: context.width,
      child: Card(
        elevation: 2,
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
                    "Our Dedicated Doctors (${state.allDoctors.length})",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (state.allDoctors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "No doctors available in this clinic at the moment.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
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
                              ? const CircularProgressIndicator()
                              : TextButton(
                            onPressed: () {
                              _doctorCubit.getDoctorsOfClinic(
                                clinicId: widget.clinicId,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text(
                              "Load More Doctors",
                              style: TextStyle(fontSize: 16),
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
                  state.error,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                TextButton(
                  onPressed: () {
                    _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Retry Loading Doctors",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        } else if (state is DoctorLoading && !_doctorCubit.isLoading) {
          content = const Center(child: CircularProgressIndicator());
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
                          (context, error, stackTrace) => const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.grey,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      doctor.text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                              : "No contact",
                          style: const TextStyle(
                            color: Colors.grey,
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
                            style: const TextStyle(
                              color: Colors.grey,
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
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
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
            const Text(
              "Our Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const Gap(16),
        if (services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                Gap(8),
                Text(
                  "No services available at the moment.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          Card(
            elevation: 2,
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
                    const Text(
                      "View Our Services",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
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
        title: const Text(
          'Our Services',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.grey),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        services.isEmpty
            ? const Center(
          child: Text(
            "No services available at the moment.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.separated(
          itemCount: services.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              elevation: 2,
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
                                  (
                                  context,
                                  error,
                                  stackTrace,
                                  ) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                service.comment ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.grey,
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
                          "No extra details provided.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Appointment: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
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
                            const Icon(
                              Icons.monetization_on_outlined,
                              color: Colors.grey,
                            ),
                            const Gap(12),
                            Text(
                              service.price ?? "Free",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
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
                          backgroundColor: AppColors.primaryColor
                              .withOpacity(0.7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          elevation: 3,
                        ),
                        child: const Text('View Details'),
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
