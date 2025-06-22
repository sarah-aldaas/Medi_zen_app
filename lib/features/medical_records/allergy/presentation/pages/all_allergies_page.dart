import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/allergy_filter_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_list_item.dart';
import 'allergy_details_page.dart';

class AllAllergiesPage extends StatefulWidget {
  final AllergyFilterModel filter;

  const AllAllergiesPage({super.key, required this.filter});

  @override
  State<AllAllergiesPage> createState() => _AllAllergiesPageState();
}

class _AllAllergiesPageState extends State<AllAllergiesPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialAllergies();
  }

  @override
  void didUpdateWidget(AllAllergiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialAllergies();
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAllergies() {
    _isLoadingMore = false;
    context.read<AllergyCubit>().getAllMyAllergies(
      context: context,
      filters: widget.filter.toJson(),
      loadMore: false,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<AllergyCubit>()
          .getAllMyAllergies(filters: widget.filter.toJson(), loadMore: true,context: context)
          .then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<AllergyCubit, AllergyState>(
      listener: (context, state) {
        if (state is AllergyError) {
          ShowToast.showToastError(message: state.error);
        }
      },
      builder: (context, state) {
        if (state is AllergyLoading && !state.isLoadMore) {
          return Center(child: LoadingPage());
        }

        final allergies =
        state is AllergiesSuccess
            ? state.paginatedResponse.paginatedData?.items
            : [];
        final hasMore = state is AllergiesSuccess ? state.hasMore : false;

        if (allergies == null || allergies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  size: 64,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'allergiesPage.noAllergiesFound'.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _loadInitialAllergies,
                  icon: Icon(Icons.refresh, color: theme.primaryColor),
                  label: Text(
                    'allergiesPage.refreshList'.tr(context),
                    style: TextStyle(fontSize: 16, color: theme.primaryColor),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: allergies.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allergies.length) {
              final AllergyModel allergy = allergies[index];
              return AllergyListItem(
                allergy: allergy,
                onTap: () => _navigateToAllergyDetails(allergy.id!),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: LoadingPage()),
              );
            }
          },
        );
      },
    );
  }

  void _navigateToAllergyDetails(String allergyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllergyDetailsPage(allergyId: allergyId),
      ),
    ).then((_) {
      _loadInitialAllergies();
    });
  }
}
