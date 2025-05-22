import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
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
    _postalCodeController = TextEditingController(
      text: widget.address?.postalCode,
    );
    _textController = TextEditingController(text: widget.address?.text);
    _startDateController = TextEditingController(
      text: widget.address?.startDate,
    );
    _endDateController = TextEditingController(text: widget.address?.endDate);
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
        backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.primaryColor,
        ),
        title: Text(
          widget.address == null ? 'Add Address' : 'Edit Address',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: BlocConsumer<CodeTypesCubit, CodeTypesState>(
        listener: (context, state) {
          if (state is CodeTypesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        builder: (context, state) {
          if (state is CodeTypesSuccess) {
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
                [];

            _setInitialValues(addressUses, addressTypes);

            return _buildAddressForm(addressUses, addressTypes);
          }

          if (state is CodeTypesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load address types',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<CodeTypesCubit>().fetchCodeTypes(),
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

  void _setInitialValues(
    List<CodeModel> addressUses,
    List<CodeModel> addressTypes,
  ) {
    if (widget.address != null) {
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
    } else {
      _selectedUse ??= addressUses.isNotEmpty ? addressUses.first : null;
      _selectedType ??= addressTypes.isNotEmpty ? addressTypes.first : null;
    }
  }

  Widget _buildAddressForm(
    List<CodeModel> addressUses,
    List<CodeModel> addressTypes,
  ) {
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
              validator:
                  (value) => value == null ? 'Please select address use' : null,
            ),
            const SizedBox(height: 40),
            AppDropdown<CodeModel>(
              label: 'Address Type',
              items: addressTypes,
              displayItem: (item) => item.display,
              value: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
              validator:
                  (value) =>
                      value == null ? 'Please select address type' : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _countryController,
              label: 'Country',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter country' : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _cityController,
              label: 'City',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter city' : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _stateController,
              label: 'State/Province',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter state/province'
                          : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _districtController,
              label: 'District',
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter district' : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _lineController,
              label: 'Street Address',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter street address'
                          : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _postalCodeController,
              label: 'Postal Code',
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter postal code'
                          : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _textController,
              label: 'Description',
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please enter description'
                          : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _startDateController,
              label: 'Start Date',
              suffixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
              validator:
                  (value) =>
                      value?.isEmpty ?? true
                          ? 'Please select start date'
                          : null,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _endDateController,
              label: 'End Date (Optional)',
              suffixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              child: Container(
                width: context.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
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
        startDate:
            _startDateController.text.isEmpty
                ? null
                : _startDateController.text,
        endDate:
            _endDateController.text.isEmpty ? null : _endDateController.text,
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
