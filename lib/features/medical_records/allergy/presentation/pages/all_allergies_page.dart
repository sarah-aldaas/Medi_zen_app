import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../data/models/allergy_filter_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_filter_dialog.dart';
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
  AllergyFilterModel _filter = AllergyFilterModel();
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
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAllergies() {
    _isLoadingMore = false;
    context.read<AllergyCubit>().getAllMyAllergies(filters: widget.filter.toJson());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<AllergyCubit>().getAllMyAllergies(filters: widget.filter.toJson(), loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AllergyCubit, AllergyState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        if (state is AllergyLoading && !state.isLoadMore) {
          return const Center(child: LoadingPage());
        }

        final allergies = state is AllergiesSuccess ? state.paginatedResponse.paginatedData?.items : [];
        final hasMore = state is AllergiesSuccess ? state.hasMore : false;

        if (allergies == null || allergies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No allergies found', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: allergies.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < allergies.length) {
              return AllergyListItem(allergy: allergies[index], onTap: () => _navigateToAllergyDetails(allergies[index].id!));
            } else {
              return  Center(child:LoadingButton());
            }
          },
        );
      },
    );
  }

  void _navigateToAllergyDetails(String allergyId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AllergyDetailsPage(allergyId: allergyId))).then((value) {
      _loadInitialAllergies();
    });
  }
}
