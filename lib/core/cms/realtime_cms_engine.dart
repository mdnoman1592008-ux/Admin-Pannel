import 'dart:async';
import 'cms_repository.dart';

class RealtimeCmsEngine {
  static final RealtimeCmsEngine _instance = RealtimeCmsEngine._internal();
  factory RealtimeCmsEngine() => _instance;
  RealtimeCmsEngine._internal();

  final _movieStreamController = StreamController<List<CmsMovieItem>>.broadcast();
  final _categoryStreamController = StreamController<List<String>>.broadcast();

  Stream<List<CmsMovieItem>> get movieStream => _movieStreamController.stream;
  Stream<List<String>> get categoryStream => _categoryStreamController.stream;

  void emitMovies(List<CmsMovieItem> movies) {
    _movieStreamController.add(movies);
  }

  void emitCategories(List<String> categories) {
    _categoryStreamController.add(categories);
  }

  void dispose() {
    _movieStreamController.close();
    _categoryStreamController.close();
  }
}
