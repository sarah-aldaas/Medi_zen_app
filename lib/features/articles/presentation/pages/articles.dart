import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medizen_app/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medizen_app/base/extensions/localization_extensions.dart';
import 'package:medizen_app/base/widgets/loading_page.dart';
import 'package:medizen_app/features/articles/data/model/article_filter_model.dart';
import 'package:medizen_app/features/articles/data/model/article_model.dart';
import 'package:medizen_app/features/articles/presentation/pages/article_details_notification_page.dart';
import 'package:medizen_app/features/articles/presentation/pages/my_favorite_articles.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../cubit/article_cubit/article_cubit.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final List<String> _sortOptions = [
    "articles.filters.asc",
    "articles.filters.desc",
  ];
  String? _selectedSort;
  String? _selectedCategoryId;
  String? _selectedCategoryDisplay;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchField = false;
  List<CodeModel> _categories = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCategories();
    _loadInitialArticles();
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _scrollListener,
    );
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadInitialArticles() {
    _isLoadingMore = false;

    context.read<ArticleCubit>().getAllArticles(
      context: context,
      filters: _buildFilters(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      if (!mounted) return;
      setState(() => _isLoadingMore = true);
      context
          .read<ArticleCubit>()
          .getAllArticles(

            filters: _buildFilters(),
            loadMore: true,
            context: context,
          )
          .then((_) {
            if (mounted) {

              setState(() => _isLoadingMore = false);
            }
          });
    }
  }

  void _loadCategories() async {
    final categories = await context
        .read<CodeTypesCubit>()
        .articleCategoryTypeCodes(context: context);
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  void _loadArticles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ArticleCubit>().getAllArticles(
          context: context,
          filters: _buildFilters(),
        );
      }
    });
  }

  Map<String, dynamic> _buildFilters() {
    final filter = ArticleFilter(
      searchQuery:
          _searchController.text.isNotEmpty ? _searchController.text : null,
      sort: _selectedSort != null ? _getSortField() : null,
      categoryId: _selectedCategoryId,
    );
    return filter.toJson();
  }

  String? _getSortField() {
    switch (_selectedSort) {
      case "articles.filters.asc":
        return 'asc';
      case "articles.filters.desc":
        return 'desc';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchField
            ? _buildSearchField()
            : Text("articles.title".tr(context)),
        actions: _showSearchField
            ? [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _showSearchField = false;
                _searchController.clear();
                _loadArticles();
              });
            },
          ),
        ]
            : _buildAppBarActions(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialArticles();
        },
        child: BlocConsumer<ArticleCubit, ArticleState>(
          listener: (context, state) {
            if (state is ArticleError) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              }
            }
          },
          builder: (context, state) {
            if (state is ArticleLoading && !state.isLoadMore) {
              return const Center(child: LoadingPage());
            }

            if (state is ArticleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadInitialArticles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('articles.retry'.tr(context)),
                    ),
                  ],
                ),
              );
            }


            final ArticleSuccess? currentArticlesState =
                state is ArticleSuccess
                    ? state
                    : (context.read<ArticleCubit>().state is ArticleSuccess
                        ? context.read<ArticleCubit>().state as ArticleSuccess
                        : null);

            if (currentArticlesState != null) {
              return _buildContent(currentArticlesState);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _showSearchField = !_showSearchField;
            if (_showSearchField) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {

                  _searchFocusNode.requestFocus();
                }
              });
            } else {
              _searchController.clear();
              _loadArticles();
            }
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.favorite_border),
        onPressed: () => _navigateToBookmarks(context),
      ),
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: _showFilterDialog,
      ),
    ];
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: "articles.searchHint".tr(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              _loadArticles();
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onSubmitted: (value) {
          _loadArticles();
        },
      ),
    );
  }

  Widget _buildContent(ArticleSuccess? state) {

    final articles = state?.paginatedResponse.paginatedData?.items;
    final hasMore = state?.hasMore ?? false;

    if (articles == null || articles.isEmpty) {
      return Center(
        child: Text(
          'articles.no_articles_found'.tr(context),
        ),      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics:
          const AlwaysScrollableScrollPhysics(),
      slivers: [
        // SliverPadding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   sliver: _buildSearchField(),
        // ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < articles.length) {

                return _buildArticleItem(
                  article: articles[index],
                  context: context,
                );
              } else if (hasMore) {
                return  Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child:
                        LoadingButton(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }, childCount: articles.length + (hasMore ? 1 : 0)),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];

    if (_selectedSort != null) {
      activeFilters.add(
        Chip(
          label: Text(_selectedSort!.tr(context)),
          onDeleted: () {
            setState(() {
              _selectedSort = null;
              _loadArticles();
            });
          },
        ),
      );
    }

    if (_selectedCategoryId != null) {
      activeFilters.add(
        Chip(
          label: Text(_selectedCategoryDisplay ?? ''),
          onDeleted: () {
            setState(() {
              _selectedCategoryId = null;
              _selectedCategoryDisplay = null;
              _loadArticles();
            });
          },
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      activeFilters.add(
        Chip(
          label: Text(_searchController.text),
          onDeleted: () {
            setState(() {
              _searchController.clear();
              _loadArticles();
            });
          },
        ),
      );
    }

    return SliverToBoxAdapter(
      child:
          activeFilters.isNotEmpty
              ? Wrap(spacing: 8, runSpacing: 8, children: activeFilters)
              : const SizedBox.shrink(),
    );
  }

  Widget _buildArticleItem({
    required ArticleModel article,
    required BuildContext context,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: FlexibleImage(
                    imageUrl: article.image,
                    width: 80,
                    height: 80,
                    errorWidget: const Center(
                      child: Icon(Icons.article, size: 40),
                    ),
                  ),
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
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      article.title ?? 'articles.no_title'.tr(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ??
                          '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? tempSort = _selectedSort;
        String? tempCategoryId = _selectedCategoryId;
        String? tempCategoryDisplay = _selectedCategoryDisplay;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "articles.filters.title".tr(context),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "articles.filters.sortBy".tr(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    RadioListTile<String?>(
                      title: Text("articles.filters.none".tr(context)),
                      value: null,
                      groupValue: tempSort,
                      onChanged: (value) {
                        setState(() {
                          tempSort = value;
                        });
                      },
                    ),
                    ..._sortOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option.tr(context)),
                        value: option,
                        groupValue: tempSort,
                        onChanged: (value) {
                          setState(() {
                            tempSort = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text(
                      "articles.filters.category".tr(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Gap(8),
                    DropdownButtonFormField<String>(
                      value: tempCategoryId,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "articles.filters.allCategories".tr(context),
                          ),
                        ),
                        ..._categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.display),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tempCategoryId = value;
                          tempCategoryDisplay =
                              value != null
                                  ? _categories
                                      .firstWhere((c) => c.id == value)
                                      .display
                                  : null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "articles.cancel".tr(context),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'sort': tempSort,
                      'categoryId': tempCategoryId,
                      'categoryDisplay': tempCategoryDisplay,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "articles.apply".tr(context),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      if (mounted) {

        setState(() {
          _selectedSort = result['sort'];
          _selectedCategoryId = result['categoryId'];
          _selectedCategoryDisplay = result['categoryDisplay'];
          _loadArticles();
        });
      }
    }
  }

  void _navigateToDetails(ArticleModel article, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ArticleDetailsNotificationPage(articleId: article.id!),
      ),
    ).then((value) {
      if (mounted) {
        _loadInitialArticles();
      }
    });
  }

  void _navigateToBookmarks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyFavoriteArticles(),
      ),
    ).then((value) {
      if (mounted) {
        _loadInitialArticles();
      }
    });
  }
}
