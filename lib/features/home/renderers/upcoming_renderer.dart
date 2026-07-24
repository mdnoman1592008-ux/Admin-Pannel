import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/widgets/glass_container.dart';

class UpcomingRenderer extends StatefulWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const UpcomingRenderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  State<UpcomingRenderer> createState() => _UpcomingRendererState();
}

class _UpcomingRendererState extends State<UpcomingRenderer> {
  final Set<String> _notifiedMovieIds = {};

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.section.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final isNotified = _notifiedMovieIds.contains(movie.id);

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: NetworkImage(movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Releasing in 4 Days',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isNotified) {
                                  _notifiedMovieIds.remove(movie.id);
                                } else {
                                  _notifiedMovieIds.add(movie.id);
                                  NotificationService.addNotification(
                                    'Reminder Set!',
                                    'We will notify you when "${movie.title}" premieres.',
                                    targetId: movie.id,
                                  );
                                }
                              });
                            },
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              borderRadius: 8,
                              child: Row(
                                children: [
                                  Icon(
                                    isNotified ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                    color: isNotified ? Colors.amber : Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isNotified ? 'Notified' : 'Remind Me',
                                    style: TextStyle(
                                      color: isNotified ? Colors.amber : Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
