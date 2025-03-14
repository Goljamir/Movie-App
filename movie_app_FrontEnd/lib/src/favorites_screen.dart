import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/fetched_movies.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/search_bar.dart';
import 'package:movie_app/widgets/filter_dropdowns.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Movie> favorites;
  final Function(FetchedMovies) onToggleFavorite;
  final String? selectedGenre;
  final String? selectedYear;
  final List<String> allGenres;
  final List<String> allYears;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    this.selectedGenre,
    this.selectedYear,
    required this.allGenres,
    required this.allYears,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  List<Movie> _filteredFavorites = [];
  String? _currentGenre;
  String? _currentYear;

  @override
  void initState() {
    super.initState();
    _currentGenre = widget.selectedGenre;
    _currentYear = widget.selectedYear;
    _applyFilters();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGenre != widget.selectedGenre) {
      _currentGenre = widget.selectedGenre;
    }
    if (oldWidget.selectedYear != widget.selectedYear) {
      _currentYear = widget.selectedYear;
    }
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredFavorites = widget.favorites.where((movie) {
        final matchesSearch =
            movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                movie.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
        final matchesGenre = _currentGenre == null ||
            _currentGenre == 'All' ||
            movie.genres.contains(_currentGenre);
        final matchesYear = _currentYear == null ||
            _currentYear == 'All' ||
            movie.releaseDate.year.toString() == _currentYear;
        return matchesSearch && matchesGenre && matchesYear;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MovieSearchBar(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
                _applyFilters();
              });
            },
            hintText: 'Search favorites...',
          ),
        ),
        if (widget.favorites.isNotEmpty)
          FilterDropdowns(
            allGenres: widget.allGenres,
            allYears: widget.allYears,
            selectedGenre: _currentGenre,
            selectedYear: _currentYear,
            onGenreChanged: (String? value) {
              setState(() {
                _currentGenre = value;
                _applyFilters();
              });
            },
            onYearChanged: (String? value) {
              setState(() {
                _currentYear = value;
                _applyFilters();
              });
            },
          ),
        Expanded(
          child: _filteredFavorites.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite movies yet',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredFavorites[index];
                    final fetchedMovie = FetchedMovies(
                      id: movie.id?.toString() ?? '',
                      title: movie.title,
                      description: movie.description,
                      genres: movie.genres,
                      date: movie.releaseDate,
                      imgUrl: movie.imgUrl,
                    );
                    return MovieCard(
                      movie: fetchedMovie,
                      isFavorite: true,
                      onToggleFavorite: () =>
                          widget.onToggleFavorite(fetchedMovie),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
