import 'dart:convert';
import 'package:http/http.dart' as http;
import 'fetched_movies.dart';

class MovieService {
  final String baseUrl = 'http://localhost:8080/api/movies';

  // Method to like a movie and save it to the backend
  Future<void> likeMovie(FetchedMovies movie) async {
    final response = await http.post(
      Uri.parse('$baseUrl/like'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': movie.title,
        'description': movie.description,
        'genres': movie.genres.join(', '),
        'releaseDate': movie.date.toIso8601String(),
        'imgUrl': movie.imgUrl,
        'status': 'PUBLISHED',
      }),
    );

    if (response.statusCode == 200) {
      print('Movie liked successfully!');
    } else {
      print('Failed to like movie: ${response.statusCode}');
    }
  }

  // Method to fetch all liked movies from the backend
  Future<List<FetchedMovies>> fetchLikedMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/liked'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FetchedMovies.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load liked movies');
    }
  }
}
