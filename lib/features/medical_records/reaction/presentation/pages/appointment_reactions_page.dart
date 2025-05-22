import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_filter_model.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/reaction_details_page.dart';

import '../cubit/reaction_cubit/reaction_cubit.dart';
import '../widgets/reaction_filter_dialog.dart';
import '../widgets/reaction_list_item.dart';

class AppointmentReactionsPage extends StatefulWidget {
  final String appointmentId;
  final String allergyId;

  const AppointmentReactionsPage({super.key, required this.appointmentId, required this.allergyId});

  @override
  State<AppointmentReactionsPage> createState() => _AppointmentReactionsPageState();
}

class _AppointmentReactionsPageState extends State<AppointmentReactionsPage> {
  final ScrollController _scrollController = ScrollController();
  ReactionFilterModel _filter = ReactionFilterModel();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialReactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialReactions() {
    _isLoadingMore = false;
    context.read<ReactionCubit>().getAllReactionOfAppointment(appointmentId: widget.appointmentId, allergyId: widget.allergyId, filters: _filter.toJson());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ReactionCubit>()
          .getAllReactionOfAppointment(appointmentId: widget.appointmentId, allergyId: widget.allergyId, filters: _filter.toJson(), loadMore: true)
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ReactionFilterModel>(context: context, builder: (context) => ReactionFilterDialog(currentFilter: _filter));

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialReactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergy Reactions'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        actions: [IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilterDialog, tooltip: 'Filter Reactions')],
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final reactions = state is ReactionsOfAppointmentSuccess ? state.paginatedResponse.paginatedData?.items : [];
          final hasMore = state is ReactionsOfAppointmentSuccess ? state.hasMore : false;

          if (reactions == null || reactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No reactions recorded for this allergy', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: reactions.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < reactions.length) {
                return ReactionListItem(reaction: reactions[index], onTap: () => _navigateToReactionDetails(reactions[index].id!));
              } else {
                return  Padding(padding: EdgeInsets.all(16.0), child: Center(child: LoadingButton()));
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToReactionDetails(String reactionId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReactionDetailsPage(allergyId: widget.allergyId, reactionId: reactionId)),
    ).then((_) => _loadInitialReactions());
  }
}
