import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../../../../base/widgets/not_found_data_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/encounter_filter_model.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
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
    context.read<EncounterCubit>().getAllMyEncounter(
      context: context,
      filters: widget.filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      final currentState = context.read<EncounterCubit>().state;
      if (currentState is EncountersSuccess && currentState.hasMore) {
        setState(() => _isLoadingMore = true);
        context
            .read<EncounterCubit>()
            .getAllMyEncounter(
              filters: widget.filter.toJson(),
              loadMore: true,
              context: context,
            )
            .then((_) {
              setState(() => _isLoadingMore = false);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        Theme.of(context)
            .colorScheme
            .secondary; // Or a specific color like Colors.tealAccent[400]

    return BlocConsumer<EncounterCubit, EncounterState>(
      listener: (context, state) {
        if (state is EncounterError) {
          ShowToast.showToastError(
            message: 'encountersPge.errorLoading'.tr(context),
          );
        }
      },
      builder: (context, state) {
        if (state is EncounterLoading && !state.isLoadMore) {
          return const Center(child: LoadingPage());
        }

        final List<EncounterModel> encounters =
            state is EncountersSuccess
                ? state.paginatedResponse.paginatedData?.items
                        ?.cast<EncounterModel>() ??
                    []
                : [];
        final bool hasMore = state is EncountersSuccess ? state.hasMore : false;

        if (encounters.isEmpty) {
          return NotFoundDataPage();
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadInitialEncounters();
          },
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: encounters.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < encounters.length) {
                return EncounterListItem(
                  encounter: encounters[index],
                  onTap: () => _navigateToEncounterDetails(encounters[index].id!),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(color: accentColor),
                );
              }
            },
          ),
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
    ).then((_) {
      _loadInitialEncounters();
    });
  }
}
