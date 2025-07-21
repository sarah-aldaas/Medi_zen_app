import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/not_found_data_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/allergy_filter_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import 'allergy_details_page.dart';

class AllAllergiesOfAppointmentPage extends StatefulWidget {
  final AllergyFilterModel filter;
  final String appointmentId;

  const AllAllergiesOfAppointmentPage({super.key, required this.filter, required this.appointmentId});

  @override
  State<AllAllergiesOfAppointmentPage> createState() => _AllAllergiesOfAppointmentPageState();
}

class _AllAllergiesOfAppointmentPageState extends State<AllAllergiesOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialAllergies();
  }

  @override
  void didUpdateWidget(AllAllergiesOfAppointmentPage oldWidget) {
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
    context.read<AllergyCubit>().getAllMyAllergiesOfAppointment(
      appointmentId: widget.appointmentId,
      context: context,
      filters: widget.filter.toJson(),
      loadMore: false,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<AllergyCubit>()
          .getAllMyAllergiesOfAppointment(appointmentId: widget.appointmentId, filters: widget.filter.toJson(), loadMore: true, context: context)
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(
      onRefresh: () async {
        _loadInitialAllergies();
      },
      color: Theme.of(context).primaryColor,
      child: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading && !state.isLoadMore) {
            return Center(child: LoadingPage());
          }

          final allergies = state is AllergiesOfAppointmentSuccess ? state.paginatedResponse.paginatedData?.items : [];
          final hasMore = state is AllergiesOfAppointmentSuccess ? state.hasMore : false;

          if (allergies == null || allergies.isEmpty) {
            return NotFoundDataPage();
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: allergies.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < allergies.length) {
                final AllergyModel allergy = allergies[index];
                return _buildAllergyItem(allergy, Theme.of(context));

              } else {
                return Padding(padding: const EdgeInsets.all(16.0), child: Center(child: LoadingPage()));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAllergyItem(AllergyModel allergy, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => AllergyDetailsPage(allergyId: allergy.id!)));
          _loadInitialAllergies();
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allergy.name ?? 'allergyPage.unknown_allergy'.tr(context),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 10),
              if (allergy.type != null)
                _buildInfoRow(icon: Icons.category, label: 'allergyPage.type_label'.tr(context), value: allergy.type!.display, theme: theme),
              const SizedBox(height: 10),
              if (allergy.clinicalStatus != null)
                _buildInfoRow(icon: Icons.healing, label: 'allergyPage.status_label'.tr(context), value: allergy.clinicalStatus!.display, theme: theme),
              const SizedBox(height: 10),
              if (allergy.lastOccurrence != null && allergy.lastOccurrence!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'allergyPage.last_occurrence_label'.tr(context),
                  value: allergy.lastOccurrence!,
                  isDate: true,
                  theme: theme,
                ),
              const SizedBox(height: 10),
              if (allergy.onSetAge != null && allergy.onSetAge!.isNotEmpty)
                _buildInfoRow(icon: Icons.cake, label: 'allergyPage.onset_age_label'.tr(context), value: allergy.onSetAge!, theme: theme),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, bool isDate = false, required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.cyan)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              isDate ? "${DateFormat('yyyy-MM-dd').format(DateTime.parse(value))}" : value,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
