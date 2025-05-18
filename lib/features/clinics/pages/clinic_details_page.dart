import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/clinics/data/datasources/clinic_remote_datasources.dart';
import 'package:medizen_app/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:medizen_app/features/doctor/pages/cubit/doctor_cubit/doctor_cubit.dart';
import 'package:medizen_app/features/home_page/cubit/clinic.dart';
import 'package:medizen_app/features/services/data/model/health_care_services_model.dart';

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

  @override
  void initState() {
    super.initState();
    _clinicCubit = ClinicCubit(remoteDataSource: serviceLocator<ClinicRemoteDataSource>());
    _doctorCubit = DoctorCubit(remoteDataSource: serviceLocator<DoctorRemoteDataSource>());
    // Fetch both clinic details and doctors when the page loads
    _clinicCubit.getSpecificClinic(id: widget.clinicId);
    _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
  }

  @override
  void dispose() {
    _clinicCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios, color: Colors.grey)),
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: BlocBuilder<ClinicCubit, ClinicState>(
          bloc: _clinicCubit,
          builder: (context, state) {
            if (state is ClinicLoadedSuccess) {
              return Text(state.clinic.name, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20));
            }
            return Text('Clinic Details', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20));
          },
        ),
      ),
      body: BlocBuilder<ClinicCubit, ClinicState>(
        bloc: _clinicCubit,
        builder: (context, state) {
          if (state is ClinicLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ClinicError) {
            return Center(child: Text(state.error));
          }

          if (state is ClinicLoadedSuccess) {
            return _buildClinicDetails(state.clinic);
          }

          return const Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildClinicDetails(ClinicModel clinic) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(clinic.description, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Gap(20),
            _buildClinicImage(clinic),
            const Divider(),
            _buildDoctorsSection(),
            const Divider(),
            _buildServicesSection(clinic),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicImage(ClinicModel clinic) {
    return Card(
      child: Container(
        width: context.width,
        height: context.height / 3.5,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          child: Image.network(
            clinic.photo,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => Image.asset(AppAssetImages.clinic6, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      bloc: _doctorCubit,
      builder: (context, state) {
        if (state is LoadedDoctorsOfClinicSuccess) {
          return Column(
            children: [
              Row(
                children: [
                  Icon(Icons.healing, color: Theme.of(context).primaryColor),
                  const Gap(10),
                  Text(
                    "Doctors (${state.allDoctors.length})",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const Gap(10),
              if (state.allDoctors.isEmpty)
                const Text("No doctors available in this clinic")
              else
                Column(
                  children: [
                    ...state.allDoctors.map((doctor) => _buildDoctorItem(doctor)),
                    if (state.hasMore)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
                          },
                          child: const Text("Load More Doctors"),
                        ),
                      ),
                    if (_doctorCubit.isLoading) Padding(padding: EdgeInsets.all(8.0), child: LoadingButton(isWhite: false)),
                  ],
                ),
            ],
          );
        } else if (state is DoctorError) {
          return Column(
            children: [
              Text(state.error),
              TextButton(
                onPressed: () {
                  _doctorCubit.getDoctorsOfClinic(clinicId: widget.clinicId);
                },
                child: const Text("Retry"),
              ),
            ],
          );
        } else if (state is DoctorLoading) {
          return const Center(child: LoadingPage());
        }
        return Center(child: LoadingButton());
      },
    );
  }

  Widget _buildServicesSection(ClinicModel clinic) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.health_and_safety, color: Theme.of(context).primaryColor),
            const Gap(10),
            Text("Health Care Services", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          ],
        ),
        const Gap(10),
        if (clinic.healthCareServices == null || clinic.healthCareServices!.isEmpty)
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home_repair_service_outlined), Gap(10), Text("No services available")])
        else
          Column(children: clinic.healthCareServices!.map((service) => _buildServiceItem(service)).toList()),
      ],
    );
  }

  Widget _buildDoctorItem(DoctorModel doctor) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouter.doctorDetails.name, extra: {"doctorModel": doctor});
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        doctor.avatar,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(AppAssetImages.photoDoctor1, height: 100, width: 100),
                      ),
                    ),
                    SizedBox(
                      width: context.width / 1.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${doctor.fName} ${doctor.lName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Gap(5),
                                  SizedBox(width: context.width / 2.5, child: Text(doctor.text, overflow: TextOverflow.ellipsis, maxLines: 2)),
                                ],
                              ),
                              const Spacer(),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Theme.of(context).primaryColor, size: 20),
                              const Gap(10),
                              Text(doctor.telecoms!.isNotEmpty ? doctor.telecoms![0].value! : "No contact"),
                            ],
                          ),
                          const Gap(10),
                          Row(
                            children: [
                              Icon(Icons.home, color: Theme.of(context).primaryColor, size: 20),
                              const Gap(10),
                              SizedBox(width: context.width / 3, child: Text(doctor.address, overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(HealthCareServiceModel service) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).primaryColor)),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: CircleAvatar(radius: 50, backgroundImage: NetworkImage(service.photo!)),
        title: Text(service.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service.comment!),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(service.extraDetails!),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Text("Appointment required: "),
                        service.appointmentRequired!
                            ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                            : const Icon(Icons.highlight_remove, color: Colors.orange),
                      ],
                    ),
                    Row(children: [const Icon(Icons.monetization_on, color: Colors.grey), const Gap(10), Text(service.price!)]),
                  ],
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRouter.healthServiceDetails.name, extra: {"serviceId": service.id.toString()});
                  },
                  child: Container(
                    width: context.width / 2,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text("Show details", style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
