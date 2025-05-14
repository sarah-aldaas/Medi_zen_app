import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/constant/app_images.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/clinics/data/models/clinic_model.dart';
import 'package:medizen_app/features/clinics/pages/cubit/clinic_cubit/clinic_cubit.dart';
import 'package:medizen_app/features/doctor/doctor_screen.dart';
import 'package:medizen_app/features/home_page/pages/widgets/search_field.dart';

class ClinicsPage extends StatelessWidget {
  const ClinicsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ClinicCubit>()..fetchClinics(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Clinics",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const _ClinicsGridView(),
      ),
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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchFieldClinics(controller: _searchController),
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
      return  Center(child:LoadingButton(isWhite: false,));
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
                  : 'No results found for "${_searchController.text}"',
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
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.78,
          ),
          itemCount: state.clinics.length + 1,
          itemBuilder: (context, index) {
            if (index >= state.clinics.length) {
              return context.read<ClinicCubit>().hasMore
                  ?  Center(child: LoadingButton(isWhite: false,))
                  : const SizedBox.shrink();
            }
            return _buildClinicGridItem(state.clinics[index], context);
          },
        ),
      );
    }
    else if (state is ClinicError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(state.error),
        ElevatedButton(
          onPressed: () => context.read<ClinicCubit>().fetchClinics(),
          child: const Text('Retry'),
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
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Doctorscreen()),
          ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(AppAssetImages.clinic2),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: context.width / 3,
                child: Text(
                  clinic.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                      ? Colors.black12
                      : Colors.grey.shade50,
              hintText: 'searchField.title'.tr(context),
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: _opacityLevel),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.withValues(alpha: _opacityLevel),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class _ClinicsGridView extends StatelessWidget {
//   const _ClinicsGridView();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ClinicCubit, ClinicState>(
//       builder: (context, state) {
//         if (state is ClinicLoading) {
//           return Center(child: const LoadingPage());
//         } else if (state is ClinicError) {
//           return Center(child: Text(state.error));
//         } else if (state is ClinicSuccess) {
//           final clinics = state.paginatedResponse.paginatedData.items;
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 SearchField(),
//                 Gap(20),
//                 Expanded(
//                   child: GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, // 3 items per row
//                           crossAxisSpacing: 16.0,
//                           mainAxisSpacing: 16.0,
//                           childAspectRatio:
//                               0.78, // Adjust this for item proportions
//                         ),
//                     itemCount: clinics.length,
//                     itemBuilder: (context, index) {
//                       final clinic = clinics[index];
//                       return _buildClinicGridItem(clinic, context);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//         return const SizedBox(); // Initial state
//       },
//     );
//   }

//   Widget _buildClinicGridItem(ClinicModel clinic, BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => Doctorscreen()),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Image.asset(AppAssetImages.clinic2),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SizedBox(
//                 width: context.width / 3,
//                 child: Text(
//                   clinic.name,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
