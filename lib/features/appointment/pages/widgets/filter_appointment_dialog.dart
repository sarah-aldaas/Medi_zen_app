import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../data/models/appointment_filter.dart';

class AppointmentFilterDialog extends StatefulWidget {
  final AppointmentFilter currentFilter;

  const AppointmentFilterDialog({required this.currentFilter, super.key});

  @override
  _AppointmentFilterDialogState createState() =>
      _AppointmentFilterDialogState();
}

class _AppointmentFilterDialogState extends State<AppointmentFilterDialog> {
  late AppointmentFilter _filter;
  String? _selectedTypeId;
  int? _selectedStatusId;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;

    _selectedTypeId = _filter.typeId?.toString();
    _selectedStatusId = _filter.statusId;
    _selectedStartDate = _filter.startDate;
    _selectedEndDate = _filter.endDate;
    _selectedSort = _filter.sort;
    context.read<CodeTypesCubit>().getAppointmentTypeCodes(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "filterAppointments.title".tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "filterAppointments.appointmentType".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> appointmentTypes = [];
                        if (state is CodeTypesSuccess) {
                          appointmentTypes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'type_appointment',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodeTypesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (appointmentTypes.isEmpty) {
                          return Text(
                            "filterAppointments.noAppointmentTypes".tr(context),
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "filterAppointments.allTypes".tr(context),
                              ),
                              value: null,
                              groupValue: _selectedTypeId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTypeId = value;
                                });
                              },
                            ),
                            ...appointmentTypes.map((type) {
                              return RadioListTile<String>(
                                title: Text(
                                  type.display ?? 'N/A',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: type.id,
                                groupValue: _selectedTypeId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedTypeId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "filterAppointments.status".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        RadioListTile<int?>(
                          title: Text(
                            "filterAppointments.allStatuses".tr(context),
                          ),
                          value: null,
                          groupValue: _selectedStatusId,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedStatusId = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(
                            "filterAppointments.booked".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: 81,
                          groupValue: _selectedStatusId,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedStatusId = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(
                            "filterAppointments.completed".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: 83,
                          groupValue: _selectedStatusId,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedStatusId = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(
                            "filterAppointments.cancelled".tr(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: 82,
                          groupValue: _selectedStatusId,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedStatusId = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Start Date
                    Text(
                      "filterAppointments.startDate".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedStartDate != null
                            ? DateFormat('MMM d, y').format(_selectedStartDate!)
                            : "filterAppointments.selectStartDate".tr(context),
                        style: TextStyle(
                          color:
                          _selectedStartDate != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedStartDate = picked;

                            if (_selectedEndDate != null &&
                                _selectedEndDate!.isBefore(picked)) {
                              _selectedEndDate = null;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // End Date
                    Text(
                      "filterAppointments.endDate".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedEndDate != null
                            ? DateFormat('MMM d, y').format(_selectedEndDate!)
                            : "filterAppointments.selectEndDate".tr(context),
                        style: TextStyle(
                          color:
                          _selectedEndDate != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                          _selectedEndDate ??
                              (_selectedStartDate ?? DateTime.now()),
                          firstDate: _selectedStartDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedEndDate = picked;
                          });
                        }
                      },
                    ),
                    // const SizedBox(height: 16),
                    // Doctor (Commented out in original code, leaving as is)
                    // const Text(
                    //   "Doctor",
                    //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // ),
                    // const SizedBox(height: 8),
                    // FutureBuilder<List<DoctorModel>>(
                    //   future: _fetchDoctors(),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       return const Center(child: CircularProgressIndicator());
                    //     }
                    //     if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    //       return const Text("No doctors available", style: TextStyle(color: Colors.grey));
                    //     }
                    //     return DropdownButtonFormField<int>(
                    //       value: _filter.doctorId,
                    //       decoration: InputDecoration(
                    //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    //         contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    //       ),
                    //       items: [
                    //         const DropdownMenuItem(value: null, child: Text("All Doctors")),
                    //         ...snapshot.data!.map((doctor) => DropdownMenuItem(
                    //           value: doctor.id,
                    //           child: Text("${doctor.fName} ${doctor.lName}"),
                    //         )),
                    //       ],
                    //       onChanged: (value) => setState(() {
                    //         _filter = _filter.copyWith(doctorId: value);
                    //       }),
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    // Sort Order
                    Text(
                      "filterAppointments.sortOrder".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "filterAppointments.defaultSort".tr(context),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'asc',
                          child: Text(
                            "filterAppointments.oldestFirst".tr(context),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'desc',
                          child: Text(
                            "filterAppointments.newestFirst".tr(context),
                          ),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() {
                        _selectedSort = value;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypeId = null;
                      _selectedStatusId = null;
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                      _selectedSort = null;
                      _filter = AppointmentFilter();
                    });
                  },
                  child: Text(
                    "filterAppointments.clearFilters".tr(context),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("filterAppointments.cancel".tr(context)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AppointmentFilter(
                            typeId:
                            _selectedTypeId != null
                                ? int.tryParse(_selectedTypeId!)
                                : null,
                            statusId: _selectedStatusId,
                            startDate: _selectedStartDate,
                            endDate: _selectedEndDate,
                            sort: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text("filterAppointments.apply".tr(context)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DoctorModel>> _fetchDoctors() async {
    return [];
  }
}
