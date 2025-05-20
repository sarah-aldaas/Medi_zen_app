import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';
// <<<<<<< HEAD
// import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
// import '../../../../../base/data/models/code_type_model.dart';
// =======

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
import '../../cubit/address_cubit/address_cubit.dart';
import 'app_dropdown.dart';
import 'app_text_field.dart';


class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _lineController;
  late TextEditingController _postalCodeController;
  late TextEditingController _textController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  CodeModel? _selectedUse;
  CodeModel? _selectedType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    context.read<CodeTypesCubit>().getAddressTypeCodes();
    context.read<CodeTypesCubit>().getAddressUseCodes();
  }

  void _initializeControllers() {
    _countryController = TextEditingController(text: widget.address?.country);
    _cityController = TextEditingController(text: widget.address?.city);
    _stateController = TextEditingController(text: widget.address?.state);
    _districtController = TextEditingController(text: widget.address?.district);
    _lineController = TextEditingController(text: widget.address?.line);
// <<<<<<< HEAD
//     _postalCodeController = TextEditingController(text: widget.address?.postalCode);
//     _textController = TextEditingController(text: widget.address?.text);
//     _startDateController = TextEditingController(text: widget.address?.startDate);
//     _endDateController =TextEditingController(text: widget.address?.endDate);
// =======
    _postalCodeController = TextEditingController(
      text: widget.address?.postalCode,
    );
    _textController = TextEditingController(text: widget.address?.text);
    _startDateController = TextEditingController(
      text: widget.address?.startDate,
    );
    _endDateController = TextEditingController(text: widget.address?.endDate);
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _lineController.dispose();
    _postalCodeController.dispose();
    _textController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: BlocConsumer<CodeTypesCubit, CodeTypesState>(
        listener: (context, state) {
          if (state is CodeTypesError) {
// <<<<<<< HEAD
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error: ${state.error}')),
//             );
// =======
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
          }
        },
        builder: (context, state) {
          if (state is CodeTypesSuccess) {
// <<<<<<< HEAD
//             final addressUses = state.codes
//                 ?.where((code) => code.codeTypeModel?.name == 'address_use')
//                 .toList() ??
//                 [];
//             final addressTypes = state.codes
//                 ?.where((code) => code.codeTypeModel?.name == 'address_type')
//                 .toList() ??
// =======
            final addressUses =
                state.codes
                    ?.where((code) => code.codeTypeModel?.name == 'address_use')
                    .toList() ??
                [];
            final addressTypes =
                state.codes
                    ?.where(
                      (code) => code.codeTypeModel?.name == 'address_type',
                    )
                    .toList() ??
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
                [];

            _setInitialValues(addressUses, addressTypes);

            return _buildAddressForm(addressUses, addressTypes);
          }

          if (state is CodeTypesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
// <<<<<<< HEAD
//                   Text('Failed to load address types', style: TextStyle(color: Colors.red)),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context.read<CodeTypesCubit>().fetchCodeTypes(),
// =======
                  Text(
                    'Failed to load address types',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<CodeTypesCubit>().fetchCodeTypes(),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: LoadingPage());
        },
      ),
    );
  }
//
// <<<<<<< HEAD
//   void _setInitialValues(List<CodeModel> addressUses, List<CodeModel> addressTypes) {
//     if (widget.address != null) {
//       // Try to find matching use/type, or set to null if not found
//       _selectedUse ??= addressUses.isNotEmpty
//           ? addressUses.firstWhere(
//             (use) => use.id == widget.address?.use?.id,
//         orElse: () => addressUses.first,
//       )
//           : null;
//       _selectedType ??= addressTypes.isNotEmpty
//           ? addressTypes.firstWhere(
//             (type) => type.id == widget.address?.type?.id,
//         orElse: () => addressTypes.first,
//       )
//           : null;
// =======
  void _setInitialValues(
    List<CodeModel> addressUses,
    List<CodeModel> addressTypes,
  ) {
    if (widget.address != null) {
      // Try to find matching use/type, or set to null if not found
      _selectedUse ??=
          addressUses.isNotEmpty
              ? addressUses.firstWhere(
                (use) => use.id == widget.address?.use?.id,
                orElse: () => addressUses.first,
              )
              : null;
      _selectedType ??=
          addressTypes.isNotEmpty
              ? addressTypes.firstWhere(
                (type) => type.id == widget.address?.type?.id,
                orElse: () => addressTypes.first,
              )
              : null;
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
    } else {
      // Set default to first item if available, otherwise null
      _selectedUse ??= addressUses.isNotEmpty ? addressUses.first : null;
      _selectedType ??= addressTypes.isNotEmpty ? addressTypes.first : null;
    }
  }

// <<<<<<< HEAD
//   Widget _buildAddressForm(List<CodeModel> addressUses, List<CodeModel> addressTypes) {
//
//
// =======
  Widget _buildAddressForm(
    List<CodeModel> addressUses,
    List<CodeModel> addressTypes,
  ) {
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppDropdown<CodeModel>(
              label: 'Address Use',
              items: addressUses,
              displayItem: (item) => item.display,
              value: _selectedUse,
              onChanged: (value) => setState(() => _selectedUse = value),
// <<<<<<< HEAD
//               validator: (value) => value == null ? 'Please select address use' : null,
//             ),
//             const SizedBox(height: 16),
// =======
              validator:
                  (value) => value == null ? 'Please select address use' : null,
            ),
            const SizedBox(height: 20),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
            AppDropdown<CodeModel>(
              label: 'Address Type',
              items: addressTypes,
              displayItem: (item) => item.display,
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
// <<<<<<< HEAD
//               validator: (value) => value == null ? 'Please select address type' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _countryController,
//               label: 'Country',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter country' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _cityController,
//               label: 'City',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _stateController,
//               label: 'State/Province',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter state/province' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _districtController,
//               label: 'District',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter district' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _lineController,
//               label: 'Street Address',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter street address' : null,
//             ),
//             const SizedBox(height: 16),
// =======
              validator:
                  (value) =>
                      value == null ? 'Please select address type' : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _countryController,
              label: 'Country',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter country' : null,
            ),
            const SizedBox(height: 23),
            AppTextField(
              controller: _cityController,
              label: 'City',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter city' : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _stateController,
              label: 'State/Province',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter state/province'
                          : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _districtController,
              label: 'District',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter district' : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _lineController,
              label: 'Street Address',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter street address'
                          : null,
            ),
            const SizedBox(height: 23),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
            AppTextField(
              controller: _postalCodeController,
              label: 'Postal Code',
              keyboardType: TextInputType.number,
// <<<<<<< HEAD
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter postal code' : null,
//             ),
//             const SizedBox(height: 16),
//             AppTextField(
//               controller: _textController,
//               label: 'Description',
//               validator: (value) => value?.isEmpty ?? true ? 'Please enter description' : null,
//             ),
//             const SizedBox(height: 16),
// =======
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter postal code'
                          : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _textController,
              label: 'Description',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter description'
                          : null,
            ),
            const SizedBox(height: 20),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
            AppTextField(
              controller: _startDateController,
              label: 'Start Date',
              suffixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
// <<<<<<< HEAD
//               validator: (value) => value?.isEmpty ?? true ? 'Please select start date' : null,
//             ),
//             const SizedBox(height: 16),
// =======
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please select start date'
                          : null,
            ),
            const SizedBox(height: 20),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
            AppTextField(
              controller: _endDateController,
              label: 'End Date (Optional)',
              suffixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
            ),
// <<<<<<< HEAD
//             const SizedBox(height: 32),
// =======
            const SizedBox(height: 40),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
            GestureDetector(
              child: Container(
                width: context.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
// <<<<<<< HEAD
//                   borderRadius: BorderRadius.circular(20)
//                 ),
//                 child: Center(
//                   child: Text(widget.address == null ? 'Add Address' : 'Update Address'),
//                 ),
//               ),
//               onTap:_submitForm ,
//             )
// =======
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.address == null ? 'Add Address' : 'Update Address',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              onTap: _submitForm,
            ),
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
          ],
        ),
      ),
    );
  }

// <<<<<<< HEAD
//   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
// =======
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = AddOrUpdateAddressModel(
        id: widget.address?.id,
        country: _countryController.text,
        city: _cityController.text,
        state: _stateController.text,
        district: _districtController.text,
        line: _lineController.text,
        text: _textController.text,
        postalCode: _postalCodeController.text,
// <<<<<<< HEAD
//         startDate: _startDateController.text.isEmpty ? null : _startDateController.text,
//         endDate: _endDateController.text.isEmpty ? null : _endDateController.text,
// =======
        startDate:
            _startDateController.text.isEmpty
                ? null
                : _startDateController.text,
        endDate:
            _endDateController.text.isEmpty ? null : _endDateController.text,
// >>>>>>> 03a3a97f92820df17326cce7cfc14ea9f76ceb6d
        use: _selectedUse,
        type: _selectedType,
      );

      if (widget.address == null) {
        context.read<AddressCubit>().createAddress(addressModel: address);
      } else {
        context.read<AddressCubit>().updateAddress(
          id: widget.address!.id!,
          addressModel: address,
        );
      }

      Navigator.pop(context);
    }
  }
}
