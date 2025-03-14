import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/fetched_movies.dart';
import 'movie_card.dart';

class MovieList extends StatelessWidget {
  final List<Movie> movies;
  final List<Movie> favoriteDataList;
  final Function(Movie) onToggleFavorite;
  final String tabName;

  const MovieList({
    super.key,
    required this.movies,
    required this.favoriteDataList,
    required this.onToggleFavorite,
    required this.tabName,
  });

  @override
  Widget build(BuildContext context) {
    return movies.isEmpty
        ? Center(child: Text("No $tabName found"))
        : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final isFavorite = favoriteDataList
                  .any((favMovie) => favMovie.title == movie.title);

              return MovieCard(
                movie: FetchedMovies(
                  id: movie.id?.toString() ?? '',
                  title: movie.title,
                  description: movie.description,
                  genres: movie.genres,
                  date: movie.releaseDate,
                  imgUrl: movie.imgUrl,
                ),
                isFavorite: isFavorite,
                onToggleFavorite: () => onToggleFavorite(movie),
              );
            },
          );
  }
}
