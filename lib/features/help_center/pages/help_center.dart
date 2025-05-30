import 'package:flutter/material.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "helpCenter.title".tr(context),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _selectedTab = 0),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _selectedTab == 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                  ),
                  child: Text("helpCenter.tabs.faq".tr(context)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _selectedTab = 1),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _selectedTab == 1
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                  ),
                  child: Text("helpCenter.tabs.contactUs".tr(context)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildFaqContent() : _buildContactUsContent(),
    );
  }

  Widget _buildFaqContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: "helpCenter.search.hint".tr(context),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: "helpCenter.search.clear".tr(context),
                  onPressed: () {
                    // Clear search
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildFaqItem(
              title: "helpCenter.faqItems.whatIsMedical".tr(context),
              content: "helpCenter.faqItems.content".tr(context),
            ),
            _buildFaqItem(title: "helpCenter.faqItems.howToUse".tr(context)),
            _buildFaqItem(
              title: "helpCenter.faqItems.cancelAppointment".tr(context),
            ),
            _buildFaqItem(
              title: "helpCenter.faqItems.saveRecording".tr(context),
            ),
            _buildFaqItem(title: "helpCenter.faqItems.exitApp".tr(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String title, String? content}) {
    return ExpansionTile(
      title: Text(title),
      children: <Widget>[
        if (content != null)
          Padding(padding: const EdgeInsets.all(16.0), child: Text(content)),
      ],
    );
  }

  Widget _buildContactUsContent() {
    return Center(child: Text("helpCenter.contactUs.title".tr(context)));
  }
}
