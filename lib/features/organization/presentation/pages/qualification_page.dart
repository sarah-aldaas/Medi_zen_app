import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/not_found_data_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';
import 'package:medizen_app/features/organization/data/models/qualification_organization_model.dart';
import 'package:medizen_app/features/organization/presentation/cubit/organization_cubit/organization_cubit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../main.dart';

class QualificationPage extends StatefulWidget {
  const QualificationPage({super.key});

  @override
  State<QualificationPage> createState() => _QualificationPageState();
}

class _QualificationPageState extends State<QualificationPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadComplete = {};
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialQualification();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialQualification() {
    _isLoadingMore = false;
    context.read<OrganizationCubit>().getAllQualification(
      context: context,
      loadMore: false,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<OrganizationCubit>()
          .getAllQualification(loadMore: true, context: context)
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> downloadAndViewPdf(String pdfUrl, String qualificationId) async {
    try {
      if (!Uri.parse(pdfUrl).isAbsolute) {
        throw Exception('Invalid PDF URL');
      }

      setState(() {
        _downloadProgress[qualificationId] = 0.0;
        _downloadComplete[qualificationId] = false;
      });

      if (Platform.isAndroid) {
        await checkAndRequestPermissions();
      }

      Directory directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory() ??
            await getTemporaryDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/qualification_$qualificationId.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress[qualificationId] = received / total;
            });
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (!await file.exists() || (await file.length()) == 0) {
        throw Exception('Downloaded file is invalid or empty');
      }

      setState(() {
        _downloadComplete[qualificationId] = true;
      });

      final result = await OpenFilex.open(filePath, type: 'application/pdf');
      if (result.type != ResultType.done) {
        throw Exception('Failed to open PDF: ${result.message}');
      }
    } catch (e, stackTrace) {
      print('Error downloading/opening PDF: $e\n$stackTrace');
      ShowToast.showToastError(message: 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _downloadProgress.remove(qualificationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qualification.qualificationOrganization'.tr(context),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),

        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialQualification();
        },
        color: Theme.of(context).primaryColor,
        child: BlocConsumer<OrganizationCubit, OrganizationState>(
          listener: (context, state) {
            if (state is QualificationOrganizationError) {
              ShowToast.showToastError(message: state.error);
            }
          },
          builder: (context, state) {
            if (state is QualificationOrganizationLoading &&
                !state.isLoadMore) {
              return Center(child: LoadingPage());
            }

            final qualification =
                state is QualificationOrganizationSuccess
                    ? state.paginatedResponse.paginatedData?.items
                    : [];
            final hasMore =
                state is QualificationOrganizationSuccess
                    ? state.hasMore
                    : false;

            if (qualification == null || qualification.isEmpty) {
              return NotFoundDataPage();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadInitialQualification();
              },
              color: Theme.of(context).primaryColor,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: qualification.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < qualification.length) {
                    final qualificationItem = qualification[index];
                    return _buildQualificationItem(
                      qualificationItem,
                      Theme.of(context),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: LoadingPage()),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQualificationItem(
    QualificationsOrganizationModel qualification,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  qualification.issuer.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (qualification.pdf != null && qualification.pdf!.isNotEmpty)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_downloadProgress.containsKey(qualification.id))
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: _downloadProgress[qualification.id],
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed:
                            _downloadProgress.containsKey(qualification.id)
                                ? null
                                : () => downloadAndViewPdf(
                                  qualification.pdf!,
                                  qualification.id!,
                                ),
                        icon: Icon(
                          _downloadComplete[qualification.id] == true
                              ? Icons.check_circle
                              : Icons.picture_as_pdf,
                          color:
                              _downloadComplete[qualification.id] == true
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Qualification.start'.tr(context),
              value: qualification.startDate.toString(),
              theme: theme,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Qualification.end'.tr(context),
              value: qualification.endDate.toString(),
              theme: theme,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Qualification.type'.tr(context),
              value: qualification.type!.display.toString(),
              theme: theme,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  required ThemeData theme,
  int maxLines = 3,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
