import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gap/gap.dart';
import 'package:medizen_app/base/widgets/show_toast.dart';

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
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
  @override
  void initState() {
    super.initState();
    // Fetch service details when the page loads
// <<<<<<< HEAD
//     context.read<ServiceCubit>().getSpecificServiceHealthCare(id: widget.serviceId);
// =======
    context.read<ServiceCubit>().getSpecificServiceHealthCare(
      id: widget.serviceId,
    );
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
  }

  @override
  Widget build(BuildContext context) {
// <<<<<<< HEAD
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         title:  Text('Service Details',style: TextStyle(
//           color: Theme.of(context).primaryColor,
//           fontSize: 20
//         ),),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios,color: Colors.grey,),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
// =======
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Colors.tealAccent.shade400; // لون ثانوي منعش
    final backgroundColor = Colors.white;
    final textColor = Colors.black87;
    final subTextColor = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Service Details',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24, // حجم خط أكبر للعنوان
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: subTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 3, // ظل أكثر بروزًا
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(18),
          ), // حواف أكثر دائرية
        ),
      ),
      backgroundColor: Colors.grey.shade100,
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceHealthCareError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ServiceHealthCareModelSuccess) {
// <<<<<<< HEAD
//             return _buildServiceDetails(state.healthCareServiceModel);
// =======
            return _buildServiceDetails(
              state.healthCareServiceModel,
              primaryColor,
              textColor,
              subTextColor,
            );
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
          } else if (state is ServiceHealthCareError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
// <<<<<<< HEAD
//                   Text(state.error),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<ServiceCubit>().getSpecificServiceHealthCare(id: widget.serviceId);
//                     },
//                     child: const Text('Retry'),
// =======
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
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Retry Loading'),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

// <<<<<<< HEAD
//   Widget _buildServiceDetails(HealthCareServiceModel service) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
// =======
  Widget _buildServiceDetails(
    HealthCareServiceModel service,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0), // زيادة حجم التباعد
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.photo != null)
            Center(
// <<<<<<< HEAD
//               child: Image.network(
//                 service.photo!,
//                 height: 200,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                 const Icon(Icons.medical_services, size: 100),
//               ),
//             ),
//           const SizedBox(height: 16),
//           Text(
//             service.name!,
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(service.comment!),
//           const SizedBox(height: 16),
//           const Divider(),
//           Text(
//             'Details',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           Text(service.extraDetails ?? 'No additional details'),
//           const SizedBox(height: 16),
//           const Divider(),
//           Text(
//             'Price: ${service.price}',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 16),
//           if (service.category != null) ...[
//             const Divider(),
//             Text(
//               'Category',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             Text(
//               service.category!.display,
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             Text(service.category!.description),
//           ],
//           const SizedBox(height: 16),
//           if (service.clinic != null) ...[
//             const Divider(),
//             Text(
//               'Clinic',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             Text(
//               service.clinic!.name,
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             Text(service.clinic!.description),
//             if (service.clinic!.photo != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: CircleAvatar(
//                   child: Image.network(
//                     service.clinic!.photo!,
//                     height: 100,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//           ],
//           const SizedBox(height: 16),
//           if (service.eligibilities != null && service.eligibilities!.isNotEmpty) ...[
//             const Divider(),
//             Text(
//               'Eligibility Requirements',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             ...service.eligibilities!.map((e) => Card(
//               margin: const EdgeInsets.symmetric(vertical: 4.0),
//               child: ListTile(
//                 title: Text(e.display),
//                 subtitle: Text(e.description),
//               ),
//             )),
// =======
              child: Card(
                elevation: 5, // ظل أكثر وضوحًا
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ), // حواف أكثر دائرية
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  service.photo!,
                  height: 250, // ارتفاع أكبر للصورة
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.medical_services_outlined,
                        size: 120,
                        color: subTextColor,
                      ),
                ),
              ),
            ),
          const Gap(25),
          Text(
            service.name!,
            style: TextStyle(
              fontSize: 26, // حجم خط أكبر لاسم الخدمة
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            service.comment ?? "No short description provided.",
            style: TextStyle(fontSize: 17, color: subTextColor),
          ),
          const Gap(30),
          Divider(
            thickness: 2,
            color: primaryColor.withOpacity(0.3),
          ), // فاصل بلون أساسي أخف
          const Gap(20),
          Text(
            'Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            service.extraDetails ?? 'No additional details available.',
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
                'Price: ${service.price ?? "Free"}',
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
              'Category',
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
              service.category!.description ?? "No category description.",
              style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
            ),
            const Gap(30),
          ],
          if (service.clinic != null) ...[
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text(
              'Clinic Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(10),
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
            const Gap(8),
            Text(
              service.clinic!.description ?? "No clinic description provided.",
              style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
            ),
            if (service.clinic!.photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      service.clinic!.photo!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.local_hospital_outlined,
                            size: 80,
                            color: subTextColor,
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
              'Eligibility Requirements',
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
                    e.description ?? "No description provided.",
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                ),
              ),
            ),
            const Gap(30),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
          ],
        ],
      ),
    );
  }
// <<<<<<< HEAD
// }
// =======
}
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
