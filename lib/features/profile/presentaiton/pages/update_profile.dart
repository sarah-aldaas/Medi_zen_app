import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String email = 'mayasha@gmail.com';
  String phone = '+1.415.110.000';
  String city = 'San Francisco, CA';
  String country = 'USA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leadingWidth: 100,
        toolbarHeight: 70,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade400,
            height: 1.0,
          ),
        ),
        title: Text(
          "editProfilePage.editProfile".tr(context),
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  child: Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'editProfilePage.yourEmail'.tr(context),
                  ),
                  enabled: false,
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: phone,
                  decoration: InputDecoration(
                    labelText: 'editProfilePage.yourPhone'.tr(context),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: city,
                  decoration: InputDecoration(
                    labelText: 'editProfilePage.city'.tr(context),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: country,
                  decoration: InputDecoration(
                    labelText: 'editProfilePage.country'.tr(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}