import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:heyp/infrastructure/core/pref_manager.dart';
import 'package:heyp/presentation/components/post_exploregrid_item.dart';
import 'package:heyp/presentation/components/post_gridFooter.dart';
import 'package:heyp/presentation/components/post_grid_item.dart';
import 'package:heyp/presentation/routes/routes.dart';
import 'package:heyp/presentation/utils/app_utils.dart';
import 'package:heyp/presentation/utils/constants.dart';

import '../../../application/feed/feed_bloc.dart';
import '../../../domain/entities/feed.dart';
import '../../../injection.dart';
import '../../components/no_internet.dart';
import '../../components/no_posts_widget.dart';
import '../../components/post_list_item.dart';
import '../../components/post_list_shimmer.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin<ExplorePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  ScrollController _scrollController = ScrollController();
  FeedBloc _feedBloc;

  List<Feed> _feeds = [];
  int _offset = 0;
  bool _hasReachedEndOfResults = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initScrollListener();
  }

  Future<bool> _refresh() {
    _feeds.clear();
    _offset = 0;
    _hasReachedEndOfResults = false;
    _feedBloc.add(FeedEvent.getFeeds(_offset));
    _loading = true;
    return Future.value(true);
  }

  void _initScrollListener() {
    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize =
            0.9 * _scrollController.position.maxScrollExtent;

        if (!_loading &&
            !_hasReachedEndOfResults &&
            _scrollController.position.pixels > triggerFetchMoreSize) {
          _feedBloc.add(FeedEvent.getFeeds(_offset));
          _loading = true;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: BlocProvider(
        create: (context) =>
            _feedBloc = getIt<FeedBloc>()..add(FeedEvent.getFeeds(_offset)),
        child: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            return state.allFeedsFailureOrSuccess.fold(
              () => PostListShimmer(),
              (either) => either.fold(
                (failure) => NoInternet(
                  msg: failure.map(
                    serverError: (_) => null,
                    apiFailure: (e) => e.msg,
                  ),
                  onPressed: _refresh,
                ),
                (success) => success.feeds.isEmpty
                    ? _noFeeds()
                    : _feedsList(success.feeds),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _noFeeds() {
    return NoPostsWidget(
      onPressed: _refresh,
      message: 'no_posts_so_far_try_again_later'.tr(),
    );
  }

  Widget _feedsList(List<Feed> feeds) {
//    return ListView.separated(
//      controller: _scrollController,
//      physics: AlwaysScrollableScrollPhysics(),
//      separatorBuilder: (context, index) => SizedBox(
//        height: 10,
//      ),
//      itemCount: feeds.length,
//      itemBuilder: (context, index) {
//        return PostListItem(
//          feed: feeds[index],
//        );
//      },
//    );

//    return GridView.count(
//        scrollDirection: Axis.vertical,
//        physics: NeverScrollableScrollPhysics(),
//        // Create a grid with 2 columns. If you change the scrollDirection to
//        // horizontal, this produces 2 rows.
//        crossAxisCount: 2,
//        shrinkWrap: true,
//        // Generate 100 widgets that display their index in the List.
//        children: List.generate(feeds.length, (index) {
//          return PostGridItem(
//            feed: feeds[index],
//          );
//        }));
  return StaggeredGridView.countBuilder(
    crossAxisCount: 3,
    physics: BouncingScrollPhysics(),
    itemCount: feeds.length,
    itemBuilder: (BuildContext context, int index) => PostExploreGridItem(
      feed:feeds[index],
    ),
    staggeredTileBuilder: (int index){
      int remain = index % 18;
      if (remain == 1 || remain == 9) {
        return StaggeredTile.count(2, 2);
      }
      return StaggeredTile.count(1, 1);
    },
    mainAxisSpacing: 3,
    crossAxisSpacing: 3,
//    staggeredTileBuilder: (int index) =>
//    new StaggeredTile.count(2, index.isEven ? 3 : 2),
//    mainAxisSpacing: 4.0,
//    crossAxisSpacing: 4.0,
  );
  }

  @override
  bool get wantKeepAlive => true;
}
