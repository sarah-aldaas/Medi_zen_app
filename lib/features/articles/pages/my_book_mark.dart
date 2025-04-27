import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'mixin/article_mixin.dart';

class MyBookmarkPage extends StatelessWidget with ArticleMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('My Bookmark', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: bookmarkArticles.length,
          itemBuilder: (context, index) {
            final article = bookmarkArticles[index];
            return
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(article.imageUrl, height: 100, width: 100, fit: BoxFit.fill),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text(article.title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text(article.category, style: TextStyle(color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              Column(
              children: [
                ListTile(
                  leading: SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset(article.imageUrl, width: 200, height: 100, fit: BoxFit.fill))),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Gap(5),
                      Text(article.title, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  subtitle: Text(article.category, style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    // Navigate to article details
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
