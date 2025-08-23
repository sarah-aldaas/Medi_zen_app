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
    const String svgString = '''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M20.9525 10.4616C19.712 9.08283 17.9626 8.17095 16 8.02165V5H14V8.13723C11.902 8.54591 10.1197 9.83753 9.05552 11.6096L6.5 10.1342L5.5 11.8662L8.26322 13.4616C8.09162 14.0881 8 14.7476 8 15.4286C8 17.4437 8.24257 19.4021 8.7001 21.2763L5.74115 22.0691L6.25879 24.001L9.25381 23.1985C10.1227 25.8074 11.4173 28.2218 13.055 30.3593L10.2929 33.1214L11.7072 34.5356L14.3403 31.9025C15.8901 33.6166 17.6783 35.111 19.6525 36.3337L18.1339 38.9639L19.866 39.9639L21.3944 37.3166C24.0239 38.662 26.9279 39.5476 30 39.8671V43H32V39.9935C32.19 39.9978 32.3804 40 32.5714 40C34.8687 40 36.9225 38.9572 38.2851 37.3191L40.9641 38.8658L41.9641 37.1338L39.3465 35.6225C39.7663 34.6917 40 33.6589 40 32.5714C40 29.8398 38.5256 27.4525 36.3292 26.162L37.8661 23.5L36.134 22.5L34.4672 25.387C33.862 25.2277 33.2266 25.1429 32.5714 25.1429C30.2491 25.1429 28.1171 24.3279 26.4458 22.9685L28.7071 20.7072L27.2928 19.293L25.0316 21.5542C23.6721 19.8829 22.8571 17.7509 22.8571 15.4286C22.8571 14.2508 22.583 13.137 22.0951 12.1475L24.5354 9.70718L23.1212 8.29297L20.9525 10.4616ZM15 15C14.4477 15 14 15.4477 14 16C14 16.5523 14.4477 17 15 17C15.5523 17 16 16.5523 16 16C16 15.4477 15.5523 15 15 15ZM12 16C12 14.3431 13.3431 13 15 13C16.6569 13 18 14.3431 18 16C18 17.6569 16.6569 19 15 19C13.3431 19 12 17.6569 12 16ZM24 29C23.4477 29 23 29.4477 23 30C23 30.5523 23.4477 31 24 31C24.5523 31 25 30.5523 25 30C25 29.4477 24.5523 29 24 29ZM21 30C21 28.3431 22.3431 27 24 27C25.6569 27 27 28.3431 27 30C27 31.6569 25.6569 33 24 33C22.3431 33 21 31.6569 21 30ZM17 26C18.1046 26 19 25.1046 19 24C19 22.8954 18.1046 22 17 22C15.8954 22 15 22.8954 15 24C15 25.1046 15.8954 26 17 26ZM34 32C34 33.1046 33.1046 34 32 34C30.8954 34 30 33.1046 30 32C30 30.8954 30.8954 30 32 30C33.1046 30 34 30.8954 34 32Z" fill="currentColor"/>
</svg>
''';
    return GestureDetector(
      onTap:
          () => context.pushNamed(
        AppRouter.clinicDetails.name,
        extra: {"clinicId": clinic.id},
      ),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - (2 * 16) - (3 * 20)) / 5,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
              SizedBox(height: 50,
                child: FlexibleImage(imageUrl:clinic.photo ,errorWidget: Center(child: SizedBox(
                     // height: 25,
                    child: Icon(Icons.local_hospital)),),width: 30,),
              )
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
