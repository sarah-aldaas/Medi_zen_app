import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  int _selectedTab = 0; // 0 for FAQ, 1 for Contact Us

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Help Center',style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 0;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _selectedTab == 0 ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  child: Text('FAQ'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _selectedTab == 1 ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  child: Text('Contact us'),
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
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    // Clear search
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildFaqItem(
              title: 'What is Medical?',
              content:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
            _buildFaqItem(title: 'How to use Medical?'),
            _buildFaqItem(title: 'How do I cancel an appointment?'),
            _buildFaqItem(title: 'How do I save the recording?'),
            _buildFaqItem(title: 'How do I exit the app?'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
      ],
    );
  }

  Widget _buildContactUsContent() {
    // Implement contact us content here
    return Center(
      child: Text('Contact Us Content'),
    );
  }
}