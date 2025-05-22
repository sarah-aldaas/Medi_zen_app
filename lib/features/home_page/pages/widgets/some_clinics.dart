import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import '../../../../base/constant/app_images.dart';
import '../../../../base/go_router/go_router.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/widgets/loading_page.dart';
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
      create: (context) => serviceLocator<ClinicCubit>()..fetchClinics(),
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
    context.read<ClinicCubit>().fetchClinics();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ClinicCubit>().fetchClinics(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicsPage()));
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
      return Center(child: LoadingButton(isWhite: false));
    } else if (state is ClinicError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error),
            ElevatedButton(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(),
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
                  : 'someClinics.no_result'.tr(context) + "${_searchController.text}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else if (state is ClinicSuccess) {
      // Limit to 8 items to match original behavior
      final displayClinics = state.clinics.length > 8 ? state.clinics.sublist(0, 8) : state.clinics;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 30.0,
          mainAxisSpacing: 30,
          childAspectRatio: 0.7,
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
      onTap: () => context.pushNamed(
        AppRouter.clinicDetails.name,
        extra: {"clinicId": clinic.id},
      ),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - (2 * 16) - (3 * 20)) / 5,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(AppAssetImages.clinic2),
            ),
            const SizedBox(height: 4.0),
            Text(
              clinic.name,
              style: const TextStyle(fontSize: 12),
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
}

