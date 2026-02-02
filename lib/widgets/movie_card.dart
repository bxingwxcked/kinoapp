import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../utils/helpers.dart';
import '../pages/movie_detail_page.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final times = generateRandomTimes(movie.id);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterPath ?? 'https://via.placeholder.com/500x750?text=No+Poster',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(movie.genres.isNotEmpty ? movie.genres.take(2).join(' / ') : 'Кино', style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: times.take(3).map((time) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary)),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('${movie.runtime ?? 120} мин', style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
