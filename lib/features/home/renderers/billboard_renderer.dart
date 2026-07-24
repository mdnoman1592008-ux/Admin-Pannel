import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/glass_container.dart';

class BillboardRenderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const BillboardRenderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final featured = movies.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: GestureDetector(
        onTap: () => onSelectMovie(featured),
        child: Container(
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(featured.backdropUrl.isNotEmpty ? featured.backdropUrl : featured.posterUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent, Colors.black54],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              section.title.toUpperCase(),
                              style: const TextStyle(color: Color(0xFF6C5CE7), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              featured.title,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => onSelectMovie(featured),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                        label: const Text('Watch', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
