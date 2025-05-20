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
      child:_ClinicsGridView(),
    );
  }
}

class _ClinicsGridView extends StatefulWidget {
  const _ClinicsGridView();


  @override
  State<_ClinicsGridView> createState() => _ClinicsGridViewState();
}

class _ClinicsGridViewState extends State<_ClinicsGridView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    context.read<ClinicCubit>().fetchClinics();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<ClinicCubit>().fetchClinics(loadMore: true).then((_) {
        _isLoadingMore = false;
      });
    }
  }

  Timer? _searchDebounce;

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
              Text("homePage.specialties.title".tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClinicsPage()));
                },
                child: Text("homePage.specialties.seeAll".tr(context), style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),

            SizedBox(
                height: context.height/3.2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildClinicList(state),
                )),
          ],
        );
      },
    );
  }

  Widget _buildClinicList(ClinicState state) {
    if (state is ClinicLoading && state.isInitialLoad) {
      return Center(child: LoadingButton(isWhite: false));
    } else if (state is ClinicError) {
      return Center(child: Text(state.error));
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
                  : 'someClinics.no_result'.tr(context)+"${_searchController.text}",

              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else if (state is ClinicSuccess) {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {

          if (scrollNotification is ScrollEndNotification &&
              _scrollController.position.extentAfter == 0) {
            context.read<ClinicCubit>().fetchClinics(loadMore: true);
          }
          return false;
        },
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 30.0,
            mainAxisSpacing: 30,
            childAspectRatio: 0.7,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            if (index >= state.clinics.length) {
              return context.read<ClinicCubit>().hasMore
                  ? Center(child: LoadingButton(isWhite: false))
                  : const SizedBox.shrink();
            }
            return _buildClinicGridItem(state.clinics[index], context);
          },
        ),
      );
    } else if (state is ClinicError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error),
            ElevatedButton(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(),
              child:  Text('someClinics.retry'.tr(context)),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildClinicGridItem(ClinicModel clinic, BuildContext context) {
    return GestureDetector(
                      onTap:
                          () =>
                          context.pushNamed(
                            AppRouter.clinicDetails.name,
                            extra: {"clinicId": clinic.id},
                          ),
                      child: SizedBox(
                        width: (MediaQuery
                            .of(context)
                            .size
                            .width - (2 * 16) - (3 * 20)) / 5,
                        child: Column(
                          children: [
                            // Image.network(listClinics[index].photo),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(AppAssetImages.clinic2)),
                            const SizedBox(height: 4.0), Text(clinic.name, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow
                                .ellipsis,)
                          ],
                        ),
                      ),
                    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
