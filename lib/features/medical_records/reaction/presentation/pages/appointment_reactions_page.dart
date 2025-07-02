import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/reaction/data/models/reaction_filter_model.dart';
import 'package:medizen_app/features/medical_records/reaction/presentation/pages/reaction_details_page.dart';

import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/reaction_cubit/reaction_cubit.dart';
import '../widgets/reaction_filter_dialog.dart';
import '../widgets/reaction_list_item.dart';

class AppointmentReactionsPage extends StatefulWidget {
  final String appointmentId;
  final String allergyId;

  const AppointmentReactionsPage({
    super.key,
    required this.appointmentId,
    required this.allergyId,
  });

  @override
  State<AppointmentReactionsPage> createState() =>
      _AppointmentReactionsPageState();
}

class _AppointmentReactionsPageState extends State<AppointmentReactionsPage> {
  final ScrollController _scrollController = ScrollController();
  ReactionFilterModel _filter = ReactionFilterModel();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadReactions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadReactions() {
    _isLoadingMore = false;
    context.read<ReactionCubit>().getAllReactionOfAppointment(
      context: context,
      appointmentId: widget.appointmentId,
      allergyId: widget.allergyId,
      filters: _filter.toJson(),
      loadMore: false,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ReactionCubit>()
          .getAllReactionOfAppointment(
            context: context,
            appointmentId: widget.appointmentId,
            allergyId: widget.allergyId,
            filters: _filter.toJson(),
            loadMore: true,
          )
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ReactionFilterModel>(
      context: context,
      builder: (context) => ReactionFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadReactions();
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'reactionsPage.allergyReactions'.tr(context),
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ) ??
              TextStyle(
                color: theme.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'reactionsPage.filterReactions'.tr(context),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading && !state.isLoadMore) {
            return Center(child: LoadingPage());
          }

          final reactions =
              state is ReactionsOfAppointmentSuccess
                  ? state.paginatedResponse.paginatedData?.items
                  : [];
          final hasMore =
              state is ReactionsOfAppointmentSuccess ? state.hasMore : false;
          if (reactions == null || reactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 64,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'reactionsPage.noReactionsRecorded'.tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadReactions,
                    child: Text(
                      'reactionsPage.tapToRefresh'.tr(context),
                      style: TextStyle(fontSize: 16, color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reactions.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < reactions.length) {
                final ReactionModel reaction = reactions[index];
                return ReactionListItem(
                  reaction: reaction,
                  onTap: () => _navigateToReactionDetails(reaction.id!),
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
      ),
    );
  }

  void _navigateToReactionDetails(String reactionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReactionDetailsPage(
              allergyId: widget.allergyId,
              reactionId: reactionId,
            ),
      ),
    ).then((_) => _loadReactions());
  }
}
