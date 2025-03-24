import 'package:movie_app/services/fetched_movies.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import '../models/movie.dart';
import 'api_service.dart';

class MovieRepository {
  final ApiService _springApi = ApiService();
  final Dio _dio = Dio();
  final String baseUrl = 'https://imdb236.p.rapidapi.com/imdb/top250-movies';
  final Map<String, String> headers = {
    "x-rapidapi-key": "0a68472523mshe8916967f149531p1c0bfejsn0eacef32c677",
    "x-rapidapi-host": "imdb236.p.rapidapi.com",
  };
  List<FetchedMovies> _allMovies = [];
  List<Movie> _favoriteMovies = [];
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(seconds: 1);

  Future<List<FetchedMovies>> fetchTopMovies() async {
    // Return cached movies if available
    if (_allMovies.isNotEmpty) {
      return _allMovies;
    }

    // Implement rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }

    try {
      _lastRequestTime = DateTime.now();
      print('Fetching movies from $baseUrl');
      final response = await _dio.get(
        baseUrl,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        return fetchTopMovies();
      }

      if (response.statusCode != 200) {
        print('Error response: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch movies: ${response.statusCode}',
        );
      }

      final data = response.data;
      print('Data type: ${data.runtimeType}');

      if (data == null) {
        print('Response data is null');
        return [];
      }

      if (data is! List) {
        print('Response is not a list: ${data.runtimeType}');
        return [];
      }

      _allMovies = data
          .map((movieData) {
            try {
              if (movieData is! Map<String, dynamic>) {
                print('Movie data is not a map: ${movieData.runtimeType}');
                return null;
              }

              return FetchedMovies(
                id: movieData['id']?.toString() ?? '',
                title: movieData['primaryTitle']?.toString() ?? '',
                description: movieData['description']?.toString() ??
                    'No description available',
                genres: List<String>.from(movieData['genres'] ?? []),
                date: DateTime.tryParse(
                        movieData['releaseDate']?.toString() ?? '') ??
                    DateTime(2000),
                imgUrl: movieData['primaryImage']?.toString() ?? '',
              );
            } catch (e) {
              print('Error parsing movie: $e');
              print('Movie data: $movieData');
              return null;
            }
          })
          .whereType<FetchedMovies>()
          .where((movie) => movie.title.isNotEmpty && movie.imgUrl.isNotEmpty)
          .toList();

      print('Successfully parsed ${_allMovies.length} movies');
      return _allMovies;
    } on DioException catch (e) {
      print('DioException caught:');
      print('  Message: ${e.message}');
      print('  Response: ${e.response?.data}');
      print('  Status code: ${e.response?.statusCode}');
      print('  Request: ${e.requestOptions.uri}');
      print('  Headers: ${e.requestOptions.headers}');

      if (e.response?.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        return fetchTopMovies();
      }
      rethrow;
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Movie>> getFavorites() async {
    try {
      _favoriteMovies = await _springApi.getAllMovies();
      return _favoriteMovies;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<Movie> addToFavorites(FetchedMovies imdbMovie) async {
    try {
      print('Adding movie to favorites: ${imdbMovie.title}');
      final movie = Movie(
        title: imdbMovie.title,
        description: imdbMovie.description,
        genres: imdbMovie.genres,
        releaseDate: imdbMovie.date,
        imgUrl: imdbMovie.imgUrl,
      );

      print('Converting to JSON: ${movie.toJson()}');
      final createdMovie = await _springApi.createMovie(movie);
      print('Movie created successfully: ${createdMovie.title}');

      // Update local favorites list
      _favoriteMovies.add(createdMovie);
      print(
          'Updated favorites list. Total favorites: ${_favoriteMovies.length}');

      return createdMovie;
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String title) async {
    try {
      print('Removing movie from favorites: $title');
      final movieToRemove = _favoriteMovies.firstWhere((m) => m.title == title);
      if (movieToRemove.id != null) {
        await _springApi.deleteMovie(movieToRemove.id!);
        print('Movie removed successfully');

        _favoriteMovies = await _springApi.getAllMovies();
        print(
            'Updated favorites list. Total favorites: ${_favoriteMovies.length}');
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }
}
