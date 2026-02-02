class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final List<String> genres;
  final int? runtime;
  final String? summary;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    required this.genres,
    this.runtime,
    this.summary,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final show = json['show'] ?? json;
    return Movie(
      id: show['id'],
      title: show['name'] ?? 'Без названия',
      posterPath: show['image'] != null ? show['image']['medium'] : null,
      voteAverage: show['rating'] != null && show['rating']['average'] != null
          ? (show['rating']['average'] as num).toDouble()
          : 0.0,
      genres: show['genres'] != null ? List<String>.from(show['genres']) : [],
      runtime: show['runtime'],
      summary: show['summary']?.replaceAll(RegExp(r'<[^>]*>'), ''),
    );
  }
}

class MovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final List<String> genres;
  final int? runtime;
  final String overview;

  MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.genres,
    this.runtime,
    required this.overview,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      title: json['name'] ?? '',
      posterPath: json['image'] != null ? json['image']['medium'] : null,
      backdropPath: json['image'] != null ? json['image']['original'] : null,
      voteAverage: json['rating'] != null && json['rating']['average'] != null
          ? (json['rating']['average'] as num).toDouble()
          : 0.0,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      runtime: json['runtime'],
      overview: json['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
    );
  }
}
