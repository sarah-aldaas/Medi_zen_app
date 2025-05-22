import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';

import '../../data/models/allergy_filter_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_filter_dialog.dart';
import '../widgets/allergy_list_item.dart';
import 'allergy_details_page.dart';

class AppointmentAllergiesPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentAllergiesPage({super.key, required this.appointmentId});

  @override
  State<AppointmentAllergiesPage> createState() => _AppointmentAllergiesPageState();
}

class _AppointmentAllergiesPageState extends State<AppointmentAllergiesPage> {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAllergies() {
    _isLoadingMore = false;
    context.read<AllergyCubit>().getAllMyAllergiesOfAppointment(
      appointmentId: widget.appointmentId,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<AllergyCubit>().getAllMyAllergiesOfAppointment(
        appointmentId: widget.appointmentId,
        filters: _filter.toJson(),
        loadMore: true,
      ).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AllergyFilterModel>(
      context: context,
      builder: (context) => AllergyFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialAllergies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Allergies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Allergies',
          ),
        ],
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final allergies = state is AllergiesOfAppointmentSuccess ? state.paginatedResponse.paginatedData?.items : [];
          final hasMore = state is AllergiesOfAppointmentSuccess ? state.hasMore : false;

          if (allergies == null || allergies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No allergies recorded for this appointment',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: allergies.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < allergies.length) {
                return AllergyListItem(
                  allergy: allergies[index],
                  onTap: () => _navigateToAllergyDetails(allergies[index].id!),
                );
              } else {
                return  Center(child: LoadingButton());
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToAllergyDetails(String allergyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllergyDetailsPage(allergyId: allergyId),
      ),
    ).then((value){
      _loadInitialAllergies();
    });
  }
}