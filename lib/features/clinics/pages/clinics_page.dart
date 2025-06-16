import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/clinics/data/models/clinic_model.dart';
import 'package:medizen_app/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';

class ClinicsPage extends StatefulWidget {
  const ClinicsPage({Key? key}) : super(key: key);

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

bool isVisible = false;

class _ClinicsPageState extends State<ClinicsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ClinicCubit>()..fetchClinics(context: context),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },

            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            "clinicsPage.appBarTitle".tr(context),
            style: TextStyle(

              color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },

              icon: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
        body: _ClinicsGridView(isVisible: isVisible),

      ),
    );
  }
}

class _ClinicsGridView extends StatefulWidget {
  const _ClinicsGridView({required this.isVisible});

  final bool isVisible;

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
    context.read<ClinicCubit>().fetchClinics(context: context);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<ClinicCubit>().fetchClinics(loadMore: true,context: context).then((_) {
        _isLoadingMore = false;
      });
    }
  }

  Timer? _searchDebounce;

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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Visibility(
                visible: widget.isVisible,
                child: SearchFieldClinics(controller: _searchController),
              ),
              const Gap(20),
              Expanded(child: _buildClinicList(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClinicList(ClinicState state) {
    if (state is ClinicLoading && state.isInitialLoad) {
      return Center(child: LoadingButton(isWhite: false));
    } else if (state is ClinicError) {
      return Center(
        child: Text(
          state.error,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      );
    } else if (state is ClinicEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 50,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? state.message
                  : 'No results found for "${_searchController.text}"'.tr(
                context,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    } else if (state is ClinicSuccess) {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              _scrollController.position.extentAfter == 0) {
            context.read<ClinicCubit>().fetchClinics(loadMore: true,context: context);
          }
          return false;
        },
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.9,
          ),
          itemCount: state.clinics.length + 1,
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
            Text(
              state.error,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            ElevatedButton(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(context: context),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildClinicGridItem(ClinicModel clinic, BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap:
            () => context.pushNamed(
          AppRouter.clinicDetails.name,
          extra: {"clinicId": clinic.id},
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: const DecorationImage(
                        image: AssetImage(
                          AppAssetImages.clinic1,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                clinic.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

class SearchFieldClinics extends StatelessWidget {
  final TextEditingController controller;

  final double _opacityLevel = 0.6;

  const SearchFieldClinics({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ThemeSwitcher.withTheme(
        builder: (_, switcher, theme) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor:
              theme.brightness == Brightness.dark
                  ? AppColors.powderLight.withOpacity(
                0.1,
              )
                  : Colors.grey.shade50,
              hintText: 'searchField.title'.tr(context),
              hintStyle: TextStyle(

                color:
                theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(_opacityLevel)
                    : Colors.grey.withOpacity(_opacityLevel),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              prefixIcon: Icon(
                Icons.search,

                color:
                theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(_opacityLevel)
                    : Colors.grey.withOpacity(_opacityLevel),
              ),
            ),
          );
        },
      ),
    );
  }
}
