import 'package:flutter/material.dart';
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _generalNotifications = true;
  bool _sound = false;
  bool _vibrate = true;
  bool _specialOffers = false;
  bool _promoDiscounts = false;
  bool _payments = true;
  bool _cashback = false;
  bool _appUpdates = true;
  bool _newServiceAvailable = false;
  bool _newTipsAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.grey,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Notification', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            title: const Text('General Notification'),
            value: _generalNotifications,
            onChanged: (bool value) {
              setState(() {
                _generalNotifications = value;
              });
            },
            secondary: Icon(
              Icons.notifications_active,
              size: 20, // Smaller icon size
              color: _generalNotifications ? Theme.of(context).primaryColor : null, // Primary color when selected
            ),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            splashRadius: 5,
            title: const Text('Sound'),
            value: _sound,
            onChanged: (bool value) {
              setState(() {
                _sound = value;
              });
            },
            secondary: Icon(Icons.volume_up, size: 20, color: _sound ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            title: const Text('Vibrate'),
            value: _vibrate,
            onChanged: (bool value) {
              setState(() {
                _vibrate = value;
              });
            },
            secondary: Icon(Icons.vibration, size: 20, color: _vibrate ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            title: const Text('Special Offers'),
            value: _specialOffers,
            onChanged: (bool value) {
              setState(() {
                _specialOffers = value;
              });
            },
            secondary: Icon(Icons.local_offer, size: 20, color: _specialOffers ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            title: const Text('Promo & Discount'),
            value: _promoDiscounts,
            onChanged: (bool value) {
              setState(() {
                _promoDiscounts = value;
              });
            },
            secondary: Icon(Icons.discount, size: 20, color: _promoDiscounts ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            title: const Text('Payments'),
            value: _payments,
            onChanged: (bool value) {
              setState(() {
                _payments = value;
              });
            },
            secondary: Icon(Icons.payment, color: _payments ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            title: const Text('Cashback'),
            value: _cashback,
            onChanged: (bool value) {
              setState(() {
                _cashback = value;
              });
            },
            secondary: Icon(Icons.monetization_on, size: 20, color: _cashback ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            title: const Text('App Updates'),
            value: _appUpdates,
            onChanged: (bool value) {
              setState(() {
                _appUpdates = value;
              });
            },
            secondary: Icon(Icons.system_update, size: 20, color: _appUpdates ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            title: const Text('New Service Available'),
            value: _newServiceAvailable,
            onChanged: (bool value) {
              setState(() {
                _newServiceAvailable = value;
              });
            },
            secondary: Icon(Icons.new_releases, size: 20, color: _newServiceAvailable ? Theme.of(context).primaryColor : null),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,

            title: const Text('New Tips Available'),
            value: _newTipsAvailable,
            onChanged: (bool value) {
              setState(() {
                _newTipsAvailable = value;
              });
            },
            secondary: Icon(Icons.lightbulb_outline, size: 20, color: _newTipsAvailable ? Theme.of(context).primaryColor : null),
          ),
        ],
      ),
    );
  }
}
