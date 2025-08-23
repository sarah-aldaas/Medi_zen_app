import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/flexible_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../base/constant/app_images.dart';
import '../../../../base/go_router/go_router.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/theme/app_color.dart';
import '../../../clinics/data/models/clinic_model.dart';
import '../../../clinics/pages/clinics_page.dart';
import '../../../clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';

class SomeClinics extends StatefulWidget {
  const SomeClinics({super.key});

  @override
  State<SomeClinics> createState() => _SomeClinicsState();
}

class _SomeClinicsState extends State<SomeClinics> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ClinicCubit>()..fetchClinics(context: context),
      child: _ClinicsGridView(),
    );
  }
}

class _ClinicsGridView extends StatefulWidget {
  const _ClinicsGridView();

  @override
  State<_ClinicsGridView> createState() => _ClinicsGridViewState();
}

class _ClinicsGridViewState extends State<_ClinicsGridView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<ClinicCubit>().fetchClinics(context: context);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ClinicCubit>().fetchClinics(
        context: context,
        searchQuery: _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) {
        return Column(
          children: [
            Gap(20),
            SearchFieldClinics(controller: _searchController),
            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "homePage.specialties.title".tr(context),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClinicsPage()),
                      );
                    },
                    child: Text(
                      "homePage.specialties.seeAll".tr(context),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildClinicList(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClinicList(ClinicState state) {
    if (state is ClinicLoading && state.isInitialLoad) {
      return _buildShimmerLoader();
    } else if (state is ClinicError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error),
            ElevatedButton(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(context: context),
              child: Text('someClinics.retry'.tr(context)),
            ),
          ],
        ),
      );
    } else if (state is ClinicEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? state.message
                  : 'someClinics.no_result'.tr(context) +
                  "${_searchController.text}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else if (state is ClinicSuccess) {
      final displayClinics =
      state.clinics.length > 8
          ? state.clinics.sublist(0, 8)
          : state.clinics;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 30,
          childAspectRatio: 1,
        ),
        itemCount: displayClinics.length,
        itemBuilder: (context, index) {
          return _buildClinicGridItem(displayClinics[index], context);
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildClinicGridItem(ClinicModel clinic, BuildContext context) {
    return GestureDetector(
      onTap:
          () => context.pushNamed(
        AppRouter.clinicDetails.name,
        extra: {"clinicId": clinic.id},
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width /7,//- (2 * 16) - (3 * 20)) / 5,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
              SizedBox(height: 30,
                child: FlexibleImage(imageUrl:clinic.photo ,errorWidget: Center(child: SizedBox(
                     // height: 25,
                    child: Icon(Icons.local_hospital)),),width: 30,),
              )
            ),
            const SizedBox(height: 10.0),
            Text(
              clinic.name,
              style:  TextStyle(fontSize: 12,color: Theme.of(context).brightness==Brightness.dark?Colors.white:Colors.black54 ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildShimmerLoader() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 30.0,
        mainAxisSpacing: 30,
        childAspectRatio: 0.7,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - (2 * 16) - (3 * 20)) / 5,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: isDarkMode ? Colors.grey[700]! : Colors.white,
                    height: 60,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  color: isDarkMode ? Colors.grey[700]! : Colors.white,
                  height: 12,
                  width: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
