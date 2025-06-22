import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/services/di/injection_container_common.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/medical_records/service_request/presentation/pages/service_request_details_page.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';
import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_filter.dart';
import '../../data/data_source/service_request_remote_data_source.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';

class ServiceRequestsPage extends StatefulWidget {
  final ServiceRequestFilter filter;

  const ServiceRequestsPage({super.key, required this.filter});

  @override
  State<ServiceRequestsPage> createState() => _ServiceRequestsPageState();
}

class _ServiceRequestsPageState extends State<ServiceRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialRequests() {
    setState(() => _isLoadingMore = false);
    context.read<ServiceRequestCubit>().getServiceRequests(filters: widget.filter.toJson(), context: context);
  }

  @override
  void didUpdateWidget(ServiceRequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialRequests();
      _scrollController.jumpTo(0.0);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<ServiceRequestCubit>().getServiceRequests(context: context, filters: widget.filter.toJson(), loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
        builder: (context, state) {
          if (state is ServiceRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          if (state is ServiceRequestError) {
            return Center(child: Text(state.message));
          }

          if (state is ServiceRequestLoaded) {
            final requests = state.paginatedResponse!.paginatedData!.items;
            final hasMore = state.hasMore;

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No service requests found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: requests.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < requests.length) {
                  return _buildRequestItem(context, requests[index]);
                } else {
                  return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: LoadingPage()));
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, ServiceRequestModel request) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider(
                    create:
                        (context) =>
                            ServiceRequestCubit(networkInfo: serviceLocator(), remoteDataSource: serviceLocator<ServiceRequestRemoteDataSource>())
                              ..getServiceRequestDetails(request.id!, context),
                    child: ServiceRequestDetailsPage(serviceId: request.id!),
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.healthCareService?.name ?? 'Unknown Service',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(color: _getStatusColor(request.serviceRequestStatus?.code), borderRadius: BorderRadius.circular(12.0)),
                    child: Text(request.serviceRequestStatus?.display ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Order Details
              if (request.orderDetails != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Details:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(request.orderDetails!),
                    const SizedBox(height: 8.0),
                  ],
                ),

              // Reason
              if (request.reason != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(request.reason!),
                    const SizedBox(height: 8.0),
                  ],
                ),

              // Category and Priority
              Row(
                children: [
                  if (request.serviceRequestCategory != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(request.serviceRequestCategory!.display, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  if (request.serviceRequestPriority != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priority:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(request.serviceRequestPriority!.display, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  if (request.serviceRequestBodySite != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Body site:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(request.serviceRequestBodySite!.display, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Doctor and Date
              if (request.encounter?.appointment?.doctor != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doctor:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}',
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),

              if (request.encounter?.actualStartDate != null)
                Text('Date: ${_formatDate(DateTime.parse(request.encounter!.actualStartDate!))}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'on-hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medizen_app/base/services/di/injection_container_common.dart';
// import 'package:medizen_app/base/widgets/loading_page.dart';
// import 'package:medizen_app/features/medical_records/service_request/presentation/pages/service_request_details_page.dart';
// import 'package:medizen_app/features/medical_records/service_request/data/models/service_request_model.dart';
// import '../../data/data_source/service_request_remote_data_source.dart';
// import '../cubit/service_request_cubit/service_request_cubit.dart';
//
// class ServiceRequestsPage extends StatefulWidget {
//   const ServiceRequestsPage({super.key});
//
//   @override
//   State<ServiceRequestsPage> createState() => _ServiceRequestsPageState();
// }
//
// class _ServiceRequestsPageState extends State<ServiceRequestsPage> {
//   @override
//   void initState() {
//     context.read<ServiceRequestCubit>().getServiceRequests();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
//         builder: (context, state) {
//           if (state is ServiceRequestLoading && !state.isLoadMore) {
//             return const Center(child: LoadingPage());
//           }
//
//           if (state is ServiceRequestError) {
//             return Center(child: Text(state.message));
//           }
//
//           if (state is ServiceRequestLoaded) {
//             final requests = state.paginatedResponse!.paginatedData!.items;
//
//             return ListView.builder(
//               itemCount: requests.length + (state.hasMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index < requests.length) {
//                   return _buildRequestItem(context, requests[index]);
//                 } else {
//                   context.read<ServiceRequestCubit>().getServiceRequests(loadMore: true);
//                   return const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: LoadingPage()),
//                   );
//                 }
//               },
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   Widget _buildRequestItem(BuildContext context, ServiceRequestModel request) {
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BlocProvider(
//                 create: (context) => ServiceRequestCubit(
//                   remoteDataSource: serviceLocator<ServiceRequestRemoteDataSource>(),
//                 )..getServiceRequestDetails(request.id!),
//                 child: ServiceRequestDetailsPage(serviceId: request.id!),
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Service Name and Status
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     request.healthCareService?.name ?? 'Unknown Service',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8.0, vertical: 4.0),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(request.serviceRequestStatus?.code),
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: Text(
//                       request.serviceRequestStatus?.display ?? 'Unknown',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8.0),
//
//               // Order Details
//               if (request.orderDetails != null)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Order Details:',
//                       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(request.orderDetails!),
//                     const SizedBox(height: 8.0),
//                   ],
//                 ),
//
//               // Reason
//               if (request.reason != null)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Reason:',
//                       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(request.reason!),
//                     const SizedBox(height: 8.0),
//                   ],
//                 ),
//
//               // Category and Priority
//               Row(
//                 children: [
//                   if (request.serviceRequestCategory != null)
//                     Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Category:',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .labelMedium
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(request.serviceRequestCategory!.display,style: TextStyle(color: Colors.grey),),
//                           ]),
//                     ),
//                   if (request.serviceRequestPriority != null)
//                     Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Priority:',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .labelMedium
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(request.serviceRequestPriority!.display,style: TextStyle(color: Colors.grey)),
//                           ]),
//                     ),
//                   if (request.serviceRequestBodySite != null)
//                     Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Body site:',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .labelMedium
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(request.serviceRequestBodySite!.display,style: TextStyle(color: Colors.grey)),
//                           ]),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8.0),
//
//               // Doctor and Date
//               if (request.encounter?.appointment?.doctor != null)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Doctor:',
//                       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                         '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}'),
//                     const SizedBox(height: 8.0),
//                   ],
//                 ),
//
//               if (request.encounter?.actualStartDate != null)
//                 Text(
//                   'Date: ${request.encounter!.actualStartDate!}',
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor(String? statusCode) {
//     switch (statusCode) {
//       case 'completed':
//         return Colors.green;
//       case 'in-progress':
//         return Colors.blue;
//       case 'cancelled':
//         return Colors.red;
//       case 'on-hold':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
