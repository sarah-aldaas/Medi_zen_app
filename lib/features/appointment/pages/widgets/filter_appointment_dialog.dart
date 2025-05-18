import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/features/doctor/data/model/doctor_model.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../data/models/appointment_filter.dart';

class AppointmentFilterDialog extends StatefulWidget {
  final AppointmentFilter currentFilter;

  const AppointmentFilterDialog({required this.currentFilter, super.key});

  @override
  _AppointmentFilterDialogState createState() => _AppointmentFilterDialogState();
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
    context.read<CodeTypesCubit>().getAppointmentTypeCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                const Text(
                  "Filter Appointments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    // Appointment Types - Now using Radio buttons
                    const Text(
                      "Appointment Type",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> appointmentTypes = [];
                        if (state is CodeTypesSuccess) {
                          appointmentTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'type_appointment').toList() ?? [];
                        }
                        if (state is CodeTypesLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (appointmentTypes.isEmpty) {
                          return const Text("No appointment types available", style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Types"),
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
                                title: Text(type.display, style: const TextStyle(fontSize: 14)),
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
                    const SizedBox(height: 16),
                    // Statuses - Now using Radio buttons
                    const Text(
                      "Status",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<int?>(
                          title: const Text("All Statuses"),
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
                          title: const Text("Booked", style: TextStyle(fontSize: 14)),
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
                          title: const Text("Completed", style: TextStyle(fontSize: 14)),
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
                          title: const Text("Cancelled", style: TextStyle(fontSize: 14)),
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
                    const SizedBox(height: 16),
                    // Start Date
                    const Text(
                      "Start Date",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedStartDate != null
                            ? DateFormat('MMM d, y').format(_selectedStartDate!)
                            : "Select start date",
                        style: TextStyle(color: _selectedStartDate != null ? Colors.black : Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
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
                            // Ensure end date is after start date
                            if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
                              _selectedEndDate = null;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // End Date
                    const Text(
                      "End Date",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedEndDate != null
                            ? DateFormat('MMM d, y').format(_selectedEndDate!)
                            : "Select end date",
                        style: TextStyle(color: _selectedEndDate != null ? Colors.black : Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
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
                    // Doctor
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
                    const SizedBox(height: 16),
                    // Sort Order
                    const Text(
                      "Sort Order",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Default")),
                        DropdownMenuItem(value: 'asc', child: Text("Oldest First")),
                        DropdownMenuItem(value: 'desc', child: Text("Newest First")),
                      ],
                      onChanged: (value) => setState(() {
                        _selectedSort = value;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  child: const Text("Clear Filters", style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AppointmentFilter(
                            typeId: _selectedTypeId != null ? int.tryParse(_selectedTypeId!) : null,
                            statusId: _selectedStatusId,
                            // doctorId: _filter.doctorId,
                            startDate: _selectedStartDate,
                            endDate: _selectedEndDate,
                            sort: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text("Apply"),
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
    // Implement your doctor fetching logic here
    return [];
  }
}