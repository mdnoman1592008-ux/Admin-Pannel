import 'package:flutter/material.dart';
import '../features/player/dailymotion_player_view.dart' as feature_player;
import '../models/movie.dart';
import '../models/episode.dart';

class DailymotionPlayerView extends StatelessWidget {
  final Movie movie;
  final Episode? selectedEpisode;
  final VoidCallback onClose;
  final Function(Episode)? onSelectEpisode;

  const DailymotionPlayerView({
    super.key,
    required this.movie,
    this.selectedEpisode,
    required this.onClose,
    this.onSelectEpisode,
  });

  @override
  Widget build(BuildContext context) {
    return feature_player.DailymotionPlayerView(
      movie: movie,
      selectedEpisode: selectedEpisode,
      onClose: onClose,
      onSelectEpisode: onSelectEpisode,
    );
  }
}
