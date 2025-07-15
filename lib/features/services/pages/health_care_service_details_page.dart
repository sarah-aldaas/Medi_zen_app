import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

import '../../../../base/widgets/flexible_image.dart';
import '../../../base/theme/app_color.dart';
import '../data/model/health_care_services_model.dart';
import 'cubits/service_cubit/service_cubit.dart';

class HealthCareServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const HealthCareServiceDetailsPage({super.key, required this.serviceId});

  @override
  State<HealthCareServiceDetailsPage> createState() =>
      _HealthCareServiceDetailsPageState();
}

class _HealthCareServiceDetailsPageState
    extends State<HealthCareServiceDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().getSpecificServiceHealthCare(
      id: widget.serviceId,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;

    final Color secondaryColor = theme.colorScheme.secondary;

    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final Color subTextColor =
        theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;

    final Color appBarBackgroundColor =
        theme.appBarTheme.backgroundColor ?? Colors.white;

    final Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: Text(
          'healthCareServicesPage.serviceDetails'.tr(context),
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ) ??
              TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceHealthCareError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ServiceHealthCareModelSuccess) {
            return _buildServiceDetails(context, state.healthCareServiceModel);
          } else if (state is ServiceHealthCareError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServiceCubit>().getSpecificServiceHealthCare(
                        id: widget.serviceId,
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: theme.textTheme.labelLarge?.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ),
                    child: Text(
                      'healthCareServicesPage.retryLoading'.tr(context),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildServiceDetails(
    BuildContext context,
    HealthCareServiceModel service,
  ) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final Color subTextColor =
        theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;
    final Color cardColor = theme.cardTheme.color ?? Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.photo != null && service.photo!.isNotEmpty)
            Center(
              child: Card(
                elevation: 5,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlexibleImage(
                  imageUrl: service.photo!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  errorWidget: Icon(
                    Icons.medical_services_outlined,
                    size: 120,
                    color: theme.iconTheme.color?.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Card(
                elevation: 5,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 120,
                    color: theme.iconTheme.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          const Gap(25),
          Text(
            service.name!,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            service.comment ??
                "healthCareServicesPage.noShortDescription".tr(context),
            style: TextStyle(fontSize: 17, color: subTextColor),
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text(
            'healthCareServicesPage.details'.tr(context),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            service.extraDetails ??
                'healthCareServicesPage.noAdditionalDetails'.tr(context),
            style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: primaryColor, size: 26),
              const Gap(10),
              Text(
                '${'healthCareServicesPage.price'.tr(context)}: \$${service.price ?? 'healthCareServicesPage.free'.tr(context)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Gap(30),
          if (service.category != null) ...[
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text(
              'healthCareServicesPage.category'.tr(context),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(10),
            Text(
              service.category!.display,
              style: TextStyle(
                fontSize: 19,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Text(
              service.category!.description ??
                  "healthCareServicesPage.noCategoryDescription".tr(context),
              style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
            ),
            const Gap(30),
          ],
          if (service.clinic != null) ...[
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text(
              'healthCareServicesPage.clinicInformation'.tr(context),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      color: primaryColor,
                      size: 26,
                    ),
                    const Gap(10),
                    Text(
                      service.clinic!.name,
                      style: TextStyle(
                        fontSize: 19,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    context.pushNamed(
                      AppRouter.clinicDetails.name,
                      extra: {"clinicId": service.clinic!.id},
                    );
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              service.clinic!.description ??
                  "healthCareServicesPage.noClinicDescription".tr(context),
              style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
            ),
            if (service.clinic!.photo != null &&
                service.clinic!.photo!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Card(
                    elevation: 3,
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlexibleImage(
                      imageUrl: service.clinic!.photo!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                      errorWidget: Icon(
                        Icons.local_hospital_outlined,
                        size: 80,
                        color: theme.iconTheme.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Card(
                    elevation: 3,
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_hospital_outlined,
                        size: 80,
                        color: theme.iconTheme.color?.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            const Gap(30),
          ],
          if (service.eligibilities != null &&
              service.eligibilities!.isNotEmpty) ...[
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text(
              'healthCareServicesPage.eligibilityRequirements'.tr(context),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(10),
            ...service.eligibilities!.map(
              (e) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: primaryColor,
                    size: 28,
                  ),
                  title: Text(
                    e.display,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    e.description ??
                        "healthCareServicesPage.noEligibilityDescription".tr(
                          context,
                        ),
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                ),
              ),
            ),
            const Gap(30),
          ],
        ],
      ),
    );
  }
}
