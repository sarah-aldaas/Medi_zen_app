import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/medical_records/conditions/data/models/conditions_model.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../../articles/data/model/ai_model.dart';
import '../../../../articles/data/model/article_model.dart';
import '../../../../articles/presentation/cubit/article_cubit/article_cubit.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class ConditionDetailsPage extends StatefulWidget {
  final String conditionId;

  const ConditionDetailsPage({super.key, required this.conditionId});

  @override
  State<ConditionDetailsPage> createState() => _ConditionDetailsPageState();
}

class _ConditionDetailsPageState extends State<ConditionDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConditionsCubit>().getConditionDetails(
      conditionId: widget.conditionId,
      context: context,
    );
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
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ConditionDetailsSuccess) {
            return _buildConditionDetails(state.condition);
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
                        () =>
                            context.read<ConditionsCubit>().getConditionDetails(
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
                        condition.clinicalStatus!.display,
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
                color: AppColors.primaryColor,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed:
                      () => _showConditionArticles(context, condition.id!),
                  icon: const Icon(Icons.article),
                  tooltip: 'View articles about this condition',
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
                        ? IconButton(
                          onPressed:
                              () =>
                                  _showAiModelSelection(context, condition.id!),
                          icon: const Icon(Icons.note_add),
                          tooltip: 'Generate AI article',
                        )
                        : StreamBuilder<String>(
                          stream: _getCooldownStream(
                            lastGenerationTime,
                            generationCount,
                          ),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  snapshot.data ?? 'Calculating...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                  },
                ),
              ],
            ),
            BlocBuilder<ArticleCubit, ArticleState>(
              builder: (context, state) {
                if (state is ArticleGenerateLoading) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
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
            title: Text('conditionDetails.loading_articles'.tr(context)),
            content: BlocConsumer<ArticleCubit, ArticleState>(
              listener: (context, state) {
                if (state is ArticleConditionSuccess) {
                  Navigator.pop(context);
                  _showArticleDialog(context, state.article);
                } else if (state is ArticleError) {
                  Navigator.pop(context);
                  ShowToast.showToastError(message: state.error);
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
            title:
                article != null
                    ? Text(
                      article.title ?? 'conditionDetails.articles'.tr(context),
                    )
                    : SizedBox.shrink(),
            content:
                article == null
                    ? Text(
                      'conditionDetails.can_not_generate'.tr(context),
                      // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    )
                    : SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: SingleChildScrollView(
                        child: Text(
                          article.content ??
                              'conditionDetails.No_content'.tr(context),
                          // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
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
              iconColor: Colors.blueAccent,
            ),

            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_user,
                label: 'conditionDetails.verification'.tr(context),
                value: condition.verificationStatus!.display,
                iconColor: Colors.green,
              ),

            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.insights,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
                iconColor: Colors.orange,
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
                age: condition.onSetAge,
                color: Colors.purple,
              ),

            if (condition.abatementDate != null)
              _buildTimelineItem(
                icon: Icons.check_circle_outline,
                title: 'conditionDetails.abatementDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.abatementDate!)),
                age: condition.abatementAge,
                color: Colors.teal,
              ),

            if (condition.recordDate != null)
              _buildTimelineItem(
                icon: Icons.assignment,
                title: 'conditionDetails.recordedDate'.tr(context),
                date: DateFormat(
                  'MMM d, y',
                ).format(DateTime.parse(condition.recordDate!)),
                color: Colors.indigo,
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
              leading: const Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 28,
              ),
              title: Text(
                condition.bodySite!.display,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle:
                  condition.bodySite!.description != null
                      ? Text(
                        condition.bodySite!.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      )
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
                iconColor: Colors.blueAccent,
              ),

            if (condition.verificationStatus != null)
              _buildDetailRow(
                icon: Icons.verified_outlined,
                label: 'conditionDetails.verificationStatus'.tr(context),
                value: condition.verificationStatus!.display,
                iconColor: Colors.deepOrange,
              ),

            if (condition.stage != null)
              _buildDetailRow(
                icon: Icons.bar_chart,
                label: 'conditionDetails.stage'.tr(context),
                value: condition.stage!.display,
                iconColor: Colors.greenAccent,
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
                  (encounter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event_note,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      title: Text(
                        encounter.reason ??
                            'conditionDetails.unknownReason'.tr(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        encounter.actualStartDate != null
                            ? DateFormat(
                              'MMM d, y, hh:mm a',
                            ).format(DateTime.parse(encounter.actualStartDate!))
                            : 'conditionDetails.noDateProvided'.tr(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        ShowToast.showToastInfo(
                          message: "conditionDetails.encounterDetailsToast".tr(
                            context,
                          ),
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
                color: Colors.blueGrey,
              ),

            if (condition.note != null)
              _buildNoteItem(
                icon: Icons.note_alt,
                title: 'conditionDetails.notesLabel'.tr(context),
                content: condition.note!,
                color: Colors.deepOrange,
              ),

            if (condition.extraNote != null)
              _buildNoteItem(
                icon: Icons.bookmark_add,
                title: 'conditionDetails.additionalNotes'.tr(context),
                content: condition.extraNote!,
                color: Colors.teal,
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
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
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
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (age != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'conditionDetails.yearsAge'.tr(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
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
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
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
