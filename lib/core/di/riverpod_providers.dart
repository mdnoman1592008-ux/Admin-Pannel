import 'package:flutter/foundation.dart';
import '../services/movie_repository.dart';
import '../services/storage_service.dart';
import '../models/movie.dart';
import '../models/admin_config.dart';

class CatalogStateNotifier extends ChangeNotifier {
  final MovieRepository _repository = MovieRepository();
  List<Movie> _trendingMovies = [];
  bool _isLoading = false;

  List<Movie> get trendingMovies => _trendingMovies;
  bool get isLoading => _isLoading;

  CatalogStateNotifier() {
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    notifyListeners();
    _trendingMovies = await _repository.getTrending();
    _isLoading = false;
    notifyListeners();
  }
}

class AdminConfigNotifier extends ChangeNotifier {
  AdminConfig _config = const AdminConfig();

  AdminConfig get config => _config;

  void toggleMaintenance(bool value) {
    _config = AdminConfig(
      isMaintenanceMode: value,
      maintenanceNotice: _config.maintenanceNotice,
      remoteBannerMessage: _config.remoteBannerMessage,
      isRemoteBannerActive: _config.isRemoteBannerActive,
    );
    notifyListeners();
  }
}
