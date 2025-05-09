import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';
import 'package:medizen_app/features/profile/data/models/address_model.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key, required this.addressModel});

  final AddressModel? addressModel;

  @override
  Widget build(BuildContext context) {
    return addressModel!= null?Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).primaryColor)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Text("Country: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.country ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("City: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.city ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("State: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.state ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("District: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.district ?? ""}"),
                      ],
                    ),
                  ],
                ),
                Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Line: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.line ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Postal Code: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.postalCode ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Type: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.type!.display ?? ""}"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Use: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        Text("${addressModel!.use!.display ?? ""}"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text("Text: ", style: TextStyle(color: Theme.of(context).primaryColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                Text("${addressModel!.text ?? ""}"),
              ],
            ),
          ),

          Gap(20),
          SizedBox(
            width: context.width,
            height: context.height / 3.5,
            child: ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              child: Image(image: AssetImage("assets/images/map.jpg"), fit: BoxFit.fill),
            ),
          ),
        ],
      ),
    ):Container();
  }
}
