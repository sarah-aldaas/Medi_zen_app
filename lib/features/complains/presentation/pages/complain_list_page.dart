import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/complains/data/models/complain_filter_model.dart';
import 'package:medizen_app/features/complains/data/models/complain_model.dart';
import '../cubit/complain_cubit/complain_cubit.dart';
import '../widgets/complain_filter_dialog.dart';
import 'complain_details_page.dart';

class ComplainListPage extends StatefulWidget {

  const ComplainListPage({super.key,});

  @override
  _ComplainListPageState createState() => _ComplainListPageState();
}

class _ComplainListPageState extends State<ComplainListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  ComplainFilterModel _filter = ComplainFilterModel();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialComplains();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialComplains() {
    _isLoadingMore = false;
    context.read<ComplainCubit>().getAllComplains(
      context: context,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<ComplainCubit>().getAllComplains(
        loadMore: true,
        context: context,
        filters: _filter.toJson(),
      ).then((_) => setState(() => _isLoadingMore = false));
    }
  }
  Future<void> _showFilterDialog() async {
    final result = await showDialog<ComplainFilterModel>(
      context: context,
      builder: (context) => ComplainFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialComplains();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<ComplainCubit, ComplainState>(
        listener: (context, state) {
          if (state is ComplainError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ComplainLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final complains = state is ComplainSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is ComplainSuccess ? state.hasMore : false;

          if (complains.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.report_problem, size: 64),
                  const SizedBox(height: 16),
                  Text('complains.noComplains'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialComplains,
                    child: Text('common.refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialComplains(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: complains.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < complains.length) {
                  return _buildComplainItem(complains[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplainItem(ComplainModel complain) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(complain.title ?? 'No title'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (complain.description != null)
              Text(
                complain.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              spacing: 10,
              children: [
                if (complain.status != null)
                Chip(
                  label: Text(complain.status!.display),
                  backgroundColor: _getStatusColor(complain.status!.code),
                ),
                if (complain.type != null)
                Chip(
                  label: Text(complain.type!.display),
                  backgroundColor: Colors.blue,
                ),

              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplainDetailsPage(complainId: complain.id!),
          ),
        ).then((value)=>_loadInitialComplains()),
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'complaint_new':
        return Colors.orange;
      case 'complaint_in_review':
        return Colors.blue;
      case 'complaint_resolved':
        return Colors.green;
      case 'complaint_closed':
        return Colors.grey;
      case 'complaint_rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}