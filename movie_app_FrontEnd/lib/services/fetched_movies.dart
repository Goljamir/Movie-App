import 'package:movie_app/models/movie.dart';

class FetchedMovies {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final DateTime date;
  final String imgUrl;

  const FetchedMovies({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.date,
    required this.imgUrl,
  });

  factory FetchedMovies.fromJson(Map<String, dynamic> json) {
    try {
      return FetchedMovies(
        id: json['id'] ?? '',
        title: json['primaryTitle'] ?? 'Unknown Title',
        description: json['description'] ?? 'No Description',
        genres: List<String>.from(json['genres'] ?? []),
        date: DateTime.tryParse(json['releaseDate'] ?? '') ?? DateTime(2000),
        imgUrl: json['primaryImage'] ?? '',
      );
    } catch (e) {
      print('Error parsing movie: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genres': genres,
      'releaseDate': date.toIso8601String(),
      'imgUrl': imgUrl,
    };
  }

  Movie toMovie() {
    return Movie(
      title: title,
      description: description,
      genres: genres,
      releaseDate: date,
      imgUrl: imgUrl,
    );
  }
}
