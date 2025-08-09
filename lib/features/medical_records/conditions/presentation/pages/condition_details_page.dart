import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_model.dart';
import 'package:medizen_app/features/medical_records/encounter/presentation/pages/encounter_details_page.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../../articles/data/model/ai_model.dart';
import '../../../../articles/data/model/article_model.dart';
import '../../../../articles/presentation/cubit/article_cubit/article_cubit.dart';
import '../../../diagnostic_report/presentation/pages/diagnostic_report_list_page.dart';
import '../../../medication_request/presentation/pages/my_medication_requests_page.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class ConditionDetailsPage extends StatefulWidget {
  final String conditionId;

  const ConditionDetailsPage({super.key, required this.conditionId});

  @override
  State<ConditionDetailsPage> createState() => _ConditionDetailsPageState();
}

class _ConditionDetailsPageState extends State<ConditionDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConditionDetails();
  }

  void _loadConditionDetails() {
    context.read<ConditionsCubit>().getConditionDetails(
      conditionId: widget.conditionId,
      context: context,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<String> _getCooldownStream(
    DateTime? lastGenerationTime,
    int generationCount,
  ) async* {
    while (true) {
      if (lastGenerationTime == null) {
        yield "Ready to generate";
        return;
      }
      final now = DateTime.now();
      final difference = now.difference(lastGenerationTime);
      String message;

      if (generationCount <= 3) {
        final remainingMinutes = 30 - difference.inMinutes;
        if (remainingMinutes <= 0) {
          yield "Ready to generate";
          return;
        }
        final seconds = 60 - (difference.inSeconds % 60);
        message = "$remainingMinutes:${seconds.toString().padLeft(2, '0')} min";
      } else if (generationCount <= 5) {
        final remainingHours = 2 - difference.inHours;
        if (remainingHours <= 0) {
          yield "Ready to generate";
          return;
        }
        final minutes = 60 - (difference.inMinutes % 60);
        message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
      } else {
        final remainingHours = 4 - difference.inHours;
        if (remainingHours <= 0) {
          yield "Ready to generate";
          return;
        }
        final minutes = 60 - (difference.inMinutes % 60);
        message = "$remainingHours:${minutes.toString().padLeft(2, '0')} hr";
      }

      yield message;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "conditionDetails.title".tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.info_outline),
              text: "conditionDetails.details".tr(context),
            ),
            Tab(
              icon: Icon(Icons.medication),
              text: "conditionDetails.medicationRequest".tr(context),
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: "conditionDetails.diagnosticReports".tr(context),
            ),
          ],
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadConditionDetails();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<ConditionsCubit, ConditionsState>(
          listener: (context, state) {
            if (state is ConditionsError) {
              ShowToast.showToastError(message: state.error);
            }
          },
          builder: (context, state) {
            if (state is ConditionDetailsSuccess) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildConditionDetails(state.condition),
                  // <<<<<<< HEAD
                  //
                  //                   MyMedicationRequestsPage(conditionId: state.condition.id!),
                  //
                  // =======
                  MyMedicationRequestsPage(conditionId: state.condition.id!),
                  // >>>>>>> c804e45c3224c511626af6e9cbcb1dd2e908ee6d
                  DiagnosticReportListPage(conditionId: state.condition.id!),
                ],
              );
            } else if (state is ConditionsLoading) {
              return const Center(child: LoadingPage());
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 20),
                    Text(
                      'conditionDetails.failedToLoad'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          () => context
                              .read<ConditionsCubit>()
                              .getConditionDetails(
                                conditionId: widget.conditionId,
                                context: context,
                              ),
                      icon: const Icon(Icons.refresh),
                      label: Text("conditionDetails.retry".tr(context)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildConditionDetails(ConditionsModel condition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, condition),
          const SizedBox(height: 16),
          _buildMainDetailsCard(context, condition),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'conditionDetails.articles'.tr(context)),
          _buildArticlesSection(context, condition),
          if (condition.onSetDate != null ||
              condition.abatementDate != null ||
              condition.recordDate != null) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.timeline'.tr(context),
            ),
            _buildTimelineSection(context, condition),
            const SizedBox(height: 16),
          ],
          if (condition.bodySite != null) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.bodySite'.tr(context),
            ),
            _buildBodySiteSection(context, condition),
            const SizedBox(height: 16),
          ],
          _buildSectionHeader(
            context,
            'conditionDetails.clinicalInformation'.tr(context),
          ),
          _buildClinicalInfoSection(context, condition),
          const SizedBox(height: 16),
          if (condition.encounters != null &&
              condition.encounters!.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.relatedEncounters'.tr(context),
            ),
            _buildEncountersSection(context, condition),
            const SizedBox(height: 16),
          ],
          if (condition.serviceRequests != null &&
              condition.serviceRequests!.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'conditionDetails.relatedServiceRequests'.tr(context),
            ),
            _buildServiceRequestsSection(context, condition),
            const SizedBox(height: 16),
          ],
          if (condition.note != null ||
              condition.summary != null ||
              condition.extraNote != null) ...[
            _buildSectionHeader(context, 'conditionDetails.notes'.tr(context)),
            _buildNotesSection(context, condition),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.titel,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 50,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.healthIssue ??
                        'conditionDetails.unknownCondition'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (condition.clinicalStatus != null)
                    Chip(
                      backgroundColor: _getStatusColor(
                        condition.clinicalStatus!.code,
                      ),
                      label: Text(
                        _getStatusTranslation(
                          condition.clinicalStatus!.display,
                          context,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'conditionDetails.articles'.tr(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildArticleActionButton(
                  context: context,
                  icon: Icons.article,
                  label: 'conditionDetails.showArticles'.tr(context),
                  onPressed:
                      () => _showConditionArticles(context, condition.id!),
                ),
                BlocBuilder<ArticleCubit, ArticleState>(
                  builder: (context, state) {
                    final cubit = context.read<ArticleCubit>();
                    final lastGenerationTime = cubit.lastGenerationTime;
                    final generationCount = cubit.generationCount;
                    final canGenerate = _checkGenerationCooldown(
                      lastGenerationTime,
                      generationCount,
                    );

                    return canGenerate
                        ? _buildArticleActionButton(
                          context: context,
                          icon: Icons.note_add,
                          label: 'conditionDetails.generateArticle'.tr(context),
                          onPressed:
                              () =>
                                  _showAiModelSelection(context, condition.id!),
                        )
                        : _buildCooldownTimer(
                          context,
                          lastGenerationTime,
                          generationCount,
                        );
                  },
                ),
              ],
            ),
            BlocBuilder<ArticleCubit, ArticleState>(
              builder: (context, state) {
                if (state is ArticleGenerateLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCooldownTimer(
    BuildContext context,
    DateTime? lastGenerationTime,
    int generationCount,
  ) {
    return StreamBuilder<String>(
      stream: _getCooldownStream(lastGenerationTime, generationCount),
      builder: (context, snapshot) {
        return Tooltip(
          message: 'conditionDetails.generationCooldown'.tr(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  snapshot.data ?? 'Calculating...',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAiModelSelection(BuildContext context, String conditionId) {
    final cubit = context.read<ArticleCubit>();
    final lastGenerationTime = cubit.lastGenerationTime;
    final generationCount = cubit.generationCount;

    if (!_checkGenerationCooldown(lastGenerationTime, generationCount)) {
      _showCooldownMessage(context, lastGenerationTime, generationCount);
      return;
    }

    String selectedLanguage = 'en';
    AiModel? selectedModel;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'conditionDetails.select_AI_model'.tr(context),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'conditionDetails.select_language'.tr(context),
                        style: TextStyle(
                          color: AppColors.titel,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: Text('conditionDetails.english'.tr(context)),
                            selected: selectedLanguage == 'en',
                            onSelected:
                                (_) => setState(() => selectedLanguage = 'en'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('conditionDetails.arabic'.tr(context)),
                            selected: selectedLanguage == 'ar',
                            onSelected:
                                (_) => setState(() => selectedLanguage = 'ar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'conditionDetails.select_model'.tr(context),
                        style: TextStyle(
                          color: AppColors.titel,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...listModels.map((model) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 6,
                          ),
                          color:
                              selectedModel == model
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : null,
                          child: ListTile(
                            title: Text(model.nameModel),
                            onTap: () => setState(() => selectedModel = model),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'conditionDetails.close'.tr(context),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      selectedModel != null
                          ? () {
                            Navigator.pop(context);
                            _generateAiArticle(
                              context,
                              conditionId,
                              selectedModel!.apiModel,
                              selectedLanguage,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('conditionDetails.generate'.tr(context)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _checkGenerationCooldown(
    DateTime? lastGenerationTime,
    int generationCount,
  ) {
    if (lastGenerationTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastGenerationTime);

    if (generationCount <= 3) {
      return difference.inMinutes >= 30;
    } else if (generationCount <= 5) {
      return difference.inHours >= 2;
    } else {
      return difference.inHours >= 4;
    }
  }

  void _showCooldownMessage(
    BuildContext context,
    DateTime? lastGenerationTime,
    int generationCount,
  ) {
    String message;
    final now = DateTime.now();
    final difference = now.difference(lastGenerationTime!);

    if (generationCount <= 3) {
      final remaining = 30 - difference.inMinutes;
      message = 'cooldown_message_minutes'.tr(context);
    } else if (generationCount <= 5) {
      final remaining = 2 - difference.inHours;
      message = 'cooldown_message_hours'.tr(context);
    } else {
      final remaining = 4 - difference.inHours;
      message = 'cooldown_message_hours'.tr(context);
    }

    ShowToast.showToastError(message: message);
  }

  void _generateAiArticle(
    BuildContext context,
    String conditionId,
    String? apiModel,
    String language,
  ) {
    final cubit = context.read<ArticleCubit>();
    cubit
        .generateAiArticle(
          conditionId: conditionId,
          apiModel: apiModel ?? '',
          language: language,
          context: context,
        )
        .then((_) {
          if (mounted) {
            if (cubit.state is ArticleGenerateSuccess) {
              ShowToast.showToastSuccess(
                message: 'article generated successfully',
              );
            }
            if (cubit.state is ArticleError) {
              ShowToast.showToastError(message: 'article can');
            }
          }
        });
  }

  void _showConditionArticles(BuildContext context, String conditionId) {
    final cubit = context.read<ArticleCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text('conditionDetails.loading_articles'.tr(context)),
            content: BlocConsumer<ArticleCubit, ArticleState>(
              listener: (context, state) {
                if (state is ArticleConditionSuccess) {
                  Navigator.pop(context);
                  _showArticleDialog(context, state.article);
                } else if (state is ArticleError) {
                  Navigator.pop(context);
                  _showArticleDialog(context, null);
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingButton(),
                    SizedBox(height: 16),
                    Text('conditionDetails.fetching_articles'.tr(context)),
                  ],
                );
              },
            ),
          ),
    );

    cubit.getArticleOfCondition(conditionId: conditionId, context: context);
  }

  void _showArticleDialog(BuildContext context, ArticleModel? article) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title:
                article != null
                    ? Text(
                      article.title ?? 'conditionDetails.articles'.tr(context),
                    )
                    : Text('conditionDetails.noArticlesFound'.tr(context)),
            content:
                article == null
                    ? Text('conditionDetails.noArticlesAvailable'.tr(context))
                    : SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: SingleChildScrollView(
                        child: Text(
                          article.content ??
                              'conditionDetails.No_content'.tr(context),
                        ),
                      ),
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'conditionDetails.close'.tr(context),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMainDetailsCard(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'conditionDetails.overview'.tr(context),
            ),
            const Divider(height: 10, thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_month,
              label: 'conditionDetails.type'.tr(context),
              value:
                  condition.isChronic != null
                      ? (condition.isChronic!
                          ? 'conditionDetails.chronic'.tr(context)
                          : 'conditionDetails.acute'.tr(context))
                      : 'conditionDetails.notSpecified'.tr(context),
            ),
            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_user,
                label: 'conditionDetails.verification'.tr(context),
                value: condition.verificationStatus!.display,
              ),
            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.insights,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.onSetDate != null)
              _buildTimelineItem(
                icon: Icons.history,
                title: 'conditionDetails.onsetDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.onSetDate!)),
                age: condition.onSetAge?.toString(),
              ),
            if (condition.abatementDate != null)
              _buildTimelineItem(
                icon: Icons.check_circle_outline,
                title: 'conditionDetails.abatementDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.abatementDate!)),
                age: condition.abatementAge?.toString(),
              ),
            if (condition.recordDate != null)
              _buildTimelineItem(
                icon: Icons.assignment,
                title: 'conditionDetails.recordedDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.recordDate!)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodySiteSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Tooltip(
                message:
                    condition.bodySite?.description ??
                    condition.bodySite!.display,
                child: Icon(
                  Icons.emoji_people,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              title: Text(condition.bodySite!.display),
              subtitle:
                  condition.bodySite?.description != null
                      ? Text(condition.bodySite!.description!)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInfoSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.clinicalStatus != null)
              _buildDetailRow(
                icon: Icons.local_hospital,
                label: 'conditionDetails.clinicalStatus'.tr(context),
                value: condition.clinicalStatus!.display,
              ),
            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_outlined,
                label: 'conditionDetails.verificationStatus'.tr(context),
                value: condition.verificationStatus!.display,
              ),
            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.bar_chart,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncountersSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...condition.encounters!
                .map(
                  (encounter) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EncounterDetailsPage(
                                encounterId: encounter.id!,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.event_note,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        title: Text(
                          encounter.reason ??
                              'conditionDetails.unknownReason'.tr(context),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          encounter.actualStartDate != null
                              ? DateFormat('MMM d, y, hh:mm a').format(
                                DateTime.parse(encounter.actualStartDate!),
                              )
                              : 'conditionDetails.noDateProvided'.tr(context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRequestsSection(
    BuildContext context,
    ConditionsModel condition,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...condition.serviceRequests!
                .map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.medical_services,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                      title: Text(
                        request.healthCareService?.name ??
                            'conditionDetails.unknownService'.tr(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        request.serviceRequestStatus?.display ??
                            'conditionDetails.unknownStatus'.tr(context),
                        style: TextStyle(
                          color: _getStatusColor(
                            request.serviceRequestStatus?.code,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        ShowToast.showToastInfo(
                          message: "conditionDetails.serviceRequestDetailsToast"
                              .tr(context),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ConditionsModel condition) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.summary != null)
              _buildNoteItem(
                icon: Icons.summarize,
                title: 'conditionDetails.summary'.tr(context),
                content: condition.summary!,
              ),
            if (condition.note != null)
              _buildNoteItem(
                icon: Icons.note_alt,
                title: 'conditionDetails.notesLabel'.tr(context),
                content: condition.note!,
              ),
            if (condition.extraNote != null)
              _buildNoteItem(
                icon: Icons.bookmark_add,
                title: 'conditionDetails.additionalNotes'.tr(context),
                content: condition.extraNote!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: value,
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.titel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String date,
    String? age,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(date, style: Theme.of(context).textTheme.bodyLarge),

                    if (age != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '($age ${'conditionDetails.yearsAge'.tr(context)})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusTranslation(String? statusCode, BuildContext context) {
    switch (statusCode) {
      case 'active':
        return 'active'.tr(context);
      case 'in-progress':
        return 'in_progress'.tr(context);
      case 'recurrence':
        return 'recurrence'.tr(context);
      case 'relapse':
        return 'relapse'.tr(context);
      case 'inactive':
        return 'inactive'.tr(context);
      case 'remission':
        return 'remission'.tr(context);
      case 'resolved':
        return 'resolved'.tr(context);
      case 'completed':
        return 'completed'.tr(context);
      case 'entered-in-error':
        return 'entered_in_error'.tr(context);
      default:
        return 'unknown'.tr(context);
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
      case 'in-progress':
        return Colors.blue;
      case 'recurrence':
      case 'relapse':
        return Colors.orange;
      case 'inactive':
      case 'remission':
      case 'resolved':
        return AppColors.secondaryColor;
      case 'completed':
        return Colors.purple;
      case 'entered-in-error':
        return AppColors.red;
      default:
        return Colors.grey;
    }
  }
}
