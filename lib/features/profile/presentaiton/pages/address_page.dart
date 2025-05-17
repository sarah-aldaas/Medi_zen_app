import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/base/theme/app_color.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key, required this.addressModel});

  final AddressModel addressModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Address',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.whiteColor,
        shadowColor: AppColors.lightGrey,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 1,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressInfoRow(context, 'Country', addressModel.country),
                _buildAddressInfoRow(context, 'City', addressModel.city),
                _buildAddressInfoRow(context, 'State', addressModel.state),
                _buildAddressInfoRow(
                  context,
                  'District',
                  addressModel.district,
                ),
                _buildAddressInfoRow(context, 'Line ', addressModel.line),
                _buildAddressInfoRow(
                  context,
                  'Postal Code',
                  addressModel.postalCode,
                ),

                _buildAddressInfoRow(
                  context,
                  'Usage Type',
                  addressModel.use?.display,
                ),
                _buildAddressInfoRow(
                  context,
                  'Address Type',
                  addressModel.type?.display,
                ),
                const Gap(12),
                Text(
                  'Full Description:',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  addressModel.text ?? 'No description available.',
                  style: theme.textTheme.bodyLarge,
                ),
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  height: context.height / 3.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                      image: AssetImage("assets/images/map.jpg"),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Could not load map'));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressInfoRow(
    BuildContext context,
    String label,
    String? value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
