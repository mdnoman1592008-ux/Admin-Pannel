import 'dart:async';
import 'cms_repository.dart';
import '../models/banner_item.dart';
import '../models/category_item.dart';

class RealtimeCmsEngine {
  static final RealtimeCmsEngine _instance = RealtimeCmsEngine._internal();
  factory RealtimeCmsEngine() => _instance;
  RealtimeCmsEngine._internal();

  final _movieStreamController = StreamController<List<CmsMovieItem>>.broadcast();
  final _bannerStreamController = StreamController<List<BannerItem>>.broadcast();
  final _categoryStreamController = StreamController<List<CategoryItem>>.broadcast();

  Stream<List<CmsMovieItem>> get movieStream => _movieStreamController.stream;
  Stream<List<BannerItem>> get bannerStream => _bannerStreamController.stream;
  Stream<List<CategoryItem>> get categoryStream => _categoryStreamController.stream;

  void emitMovies(List<CmsMovieItem> movies) {
    _movieStreamController.add(movies);
  }

  void emitBanners(List<BannerItem> banners) {
    _bannerStreamController.add(banners);
  }

  void emitCategories(List<CategoryItem> categories) {
    _categoryStreamController.add(categories);
  }

  void dispose() {
    _movieStreamController.close();
    _bannerStreamController.close();
    _categoryStreamController.close();
  }
}
