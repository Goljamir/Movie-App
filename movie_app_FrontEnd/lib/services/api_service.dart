import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<List<Movie>> getAllMovies() async {
    try {
      print('Fetching all movies from: $baseUrl/movies');
      final response = await http.get(Uri.parse('$baseUrl/movies'));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllMovies: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Movie> createMovie(Movie movie) async {
    try {
      print('Creating movie: ${movie.title}');
      print('Request URL: $baseUrl/movies');
      print('Request body: ${json.encode(movie.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/movies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(movie.toJson()),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Movie.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create movie: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createMovie: $e');
      throw Exception('Failed to create movie: $e');
    }
  }

  Future<Movie> updateMovie(Movie movie) async {
    if (movie.id == null) throw Exception('Movie ID cannot be null');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/movies/${movie.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(movie.toJson()),
      );

      if (response.statusCode == 200) {
        return Movie.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  Future<void> deleteMovie(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/movies/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }
}
