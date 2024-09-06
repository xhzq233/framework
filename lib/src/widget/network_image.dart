/// EcsMerchantApp - network_image
/// Created by xhz on 8/21/24

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// todo
final CacheManager _imageCacheManager = CacheManager(Config(
  'image_cache',
  maxNrOfCacheObjects: 500,
  stalePeriod: const Duration(days: 999),
));

class NNImage extends StatelessWidget {
  static Widget defaultErrorWidgetBuilder(BuildContext context, String url, dynamic error) =>
      const Icon(CupertinoIcons.exclamationmark_circle);

  static Widget defaultPlaceHolderWidgetBuilder(BuildContext context, String url) => const CircularProgressIndicator();

  NNImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    BoxFit? fit,
    ImageWidgetBuilder? imageBuilder,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 500),
    Duration? fadeOutDuration = const Duration(milliseconds: 1000),
    Duration? placeholderFadeInDuration,
    String? cacheKey,
  }) : _image = CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          fadeInDuration: fadeInDuration,
          fadeOutDuration: fadeOutDuration,
          placeholderFadeInDuration: placeholderFadeInDuration,
          cacheKey: cacheKey,
          imageBuilder: imageBuilder,
          cacheManager: _imageCacheManager,
        );

  final String imageUrl;
  final double? width;
  final double? height;
  final CachedNetworkImage _image;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return SizedBox(width: width, height: height);
    }
    return _image;
  }
}

class NNImageProvider extends CachedNetworkImageProvider {
  NNImageProvider(
    super.url, {
    super.maxWidth,
    super.maxHeight,
    super.cacheKey,
    super.errorListener,
  }) : super(cacheManager: _imageCacheManager);
}
