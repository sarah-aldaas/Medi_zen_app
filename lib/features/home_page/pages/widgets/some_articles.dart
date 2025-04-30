import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/extensions/media_query_extension.dart';

import '../../../../base/go_router/go_router.dart';
import '../../../../base/theme/app_color.dart';
import '../../../articles/pages/article_details_page.dart';
import '../../../articles/pages/mixin/article_mixin.dart';

class SomeArticles extends StatelessWidget with ArticleMixin {
  SomeArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "someArticles.title".tr(context),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouter.articles.name);
                },
                child: Text(
                  "someArticles.seeAll".tr(context),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: healthArticles.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final article = healthArticles[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ArticleDetailsPage(
                          article: article,
                          articleTitle: '',
                        ),
                  ),
                );
              },
              child: Container(
                width: context.width,
                padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  left: 15,
                  right: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(article.imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.date,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ThemeSwitcher.withTheme(
                            builder: (_, switcher, theme) {
                              return Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:
                                      theme.brightness == Brightness.light
                                          ? Colors.grey.shade200
                                          : AppColors.backGroundLogo,
                                ),
                                child: Text(
                                  article.category,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
