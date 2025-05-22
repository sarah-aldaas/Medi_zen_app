import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../data/models/encounter_filter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/encounter_filter_dialog.dart';
import '../widgets/encounter_list_item.dart';
import 'encounter_details_page.dart';


class AllEncountersPage extends StatefulWidget {
  final EncounterFilterModel filter;

  const AllEncountersPage({super.key, required this.filter});

  @override
  State<AllEncountersPage> createState() => _AllEncountersPageState();
}

class _AllEncountersPageState extends State<AllEncountersPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialEncounters();
  }

  @override
  void didUpdateWidget(AllEncountersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _loadInitialEncounters();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialEncounters() {
    _isLoadingMore = false;
    context.read<EncounterCubit>().getAllMyEncounter(filters: widget.filter.toJson());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<EncounterCubit>().getAllMyEncounter(filters: widget.filter.toJson(), loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EncounterCubit, EncounterState>(
      listener: (context, state) {
        if (state is EncounterError) {
          // Handle error if needed
        }
      },
      builder: (context, state) {
        if (state is EncounterLoading && !state.isLoadMore) {
          return const Center(child: LoadingPage());
        }

        final encounters = state is EncountersSuccess ? state.paginatedResponse.paginatedData?.items : [];
        final hasMore = state is EncountersSuccess ? state.hasMore : false;

        if (encounters == null || encounters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No encounters found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: encounters.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < encounters.length) {
              return EncounterListItem(
                encounter: encounters[index],
                onTap: () => _navigateToEncounterDetails(encounters[index].id!),
              );
            } else {
              return  Center(child: LoadingButton());
            }
          },
        );
      },
    );
  }

  void _navigateToEncounterDetails(String encounterId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncounterDetailsPage(encounterId: encounterId),
      ),
    ).then((value) {
      _loadInitialEncounters();
    });
  }
}
