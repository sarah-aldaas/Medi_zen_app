// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:medizen_app/base/extensions/localization_extensions.dart';
// import 'package:medizen_app/base/extensions/media_query_extension.dart';
//
// import '../../../../base/go_router/go_router.dart';
// import '../../../../base/theme/app_color.dart';
// import '../../../articles/presentation/pages/article_details_page.dart';
// import '../../../articles/presentation/pages/mixin/article_mixin.dart';
//
// class SomeArticles extends StatelessWidget with ArticleMixin {
//   SomeArticles({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "someArticles.title".tr(context),
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               TextButton(
//                 onPressed: () {
//                   context.pushNamed(AppRouter.articles.name);
//                 },
//                 child: Text(
//                   "someArticles.seeAll".tr(context),
//                   style: TextStyle(color: Theme.of(context).primaryColor),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ListView.separated(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: healthArticles.length,
//           separatorBuilder: (context, index) => SizedBox(height: 8),
//           itemBuilder: (context, index) {
//             final article = healthArticles[index];
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => ArticleDetailsPage(
//                           article: article,
//                           articleTitle: '',
//                         ),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: context.width,
//                 padding: EdgeInsets.only(
//                   top: 5,
//                   bottom: 5,
//                   left: 15,
//                   right: 15,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 100,
//                       height: 100,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.asset(article.imageUrl, fit: BoxFit.fill),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             article.date,
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           Text(
//                             article.title,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           ThemeSwitcher.withTheme(
//                             builder: (_, switcher, theme) {
//                               return Container(
//                                 padding: EdgeInsets.all(5),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                   color:
//                                       theme.brightness == Brightness.light
//                                           ? Colors.grey.shade200
//                                           : AppColors.backGroundLogo,
//                                 ),
//                                 child: Text(
//                                   article.category,
//                                   style: TextStyle(
//                                     color: Theme.of(context).primaryColor,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';
import 'package:medizen_app/features/articles/presentation/pages/article_details_page.dart';
import 'package:medizen_app/base/go_router/go_router.dart';
import 'package:medizen_app/features/articles/presentation/cubit/article_cubit/article_cubit.dart';

class SimpleArticlesPage extends StatefulWidget {
  const SimpleArticlesPage({super.key});

  @override
  State<SimpleArticlesPage> createState() => _SimpleArticlesPageState();
}

class _SimpleArticlesPageState extends State<SimpleArticlesPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialArticles();
  }

  void _loadInitialArticles() {
    context.read<ArticleCubit>().getAllArticles(perPage: 5, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("articles.title".tr(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  context.pushNamed(AppRouter.articles.name);
                },
                child: Text("See all", style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
        ),
        BlocConsumer<ArticleCubit, ArticleState>(
          listener: (context, state) {
            if (state is ArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state is ArticleLoading) {
              return Center(child: LoadingButton());
            }

            if (state is ArticleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(state.error), ElevatedButton(onPressed: _loadInitialArticles, child: Text("Retry".tr(context)))],
                ),
              );
            }

            final articles = (state is ArticleSuccess) ? state.paginatedResponse.paginatedData?.items ?? [] : [];

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return _buildArticleItem(article: articles[index], context: context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticleItem({required ArticleModel article, required BuildContext context}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetails(article, context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child:
                      article.image != null && article.image!.isNotEmpty
                          ? Image.network(article.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.article))
                          : Icon(Icons.article, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      Text(
                        article.category!.display,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                        // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      article.title ?? 'No title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      // textDirection: article.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(ArticleModel article, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailsPage(article: article)));
  }
}
