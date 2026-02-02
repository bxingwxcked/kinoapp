import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/schedule?country=US'),
    );

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<MovieDetail> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shows/$movieId'),
    );

    if (response.statusCode == 200) {
      return MovieDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
