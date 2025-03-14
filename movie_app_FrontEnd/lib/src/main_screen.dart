import 'package:flutter/material.dart';
import 'package:movie_app/services/fetched_movies.dart';
import 'package:movie_app/services/movie_repository.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/search_bar.dart';
import 'package:movie_app/widgets/filter_dropdowns.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final MovieRepository _repository = MovieRepository();
  late TabController _tabController;
  List<FetchedMovies> _movies = [];
  List<Movie> _favorites = [];
  bool _isLoading = true;
  String _error = '';
  String _homeSearchQuery = '';
  String _favoritesSearchQuery = '';
  String? _homeSelectedGenre;
  String? _homeSelectedYear;
  String? _favoritesSelectedGenre;
  String? _favoritesSelectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMovies();
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final movies = await _repository.fetchTopMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load movies: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _repository.getFavorites();
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(FetchedMovies movie) async {
    try {
      final isFavorite = _favorites.any((fav) => fav.title == movie.title);

      if (isFavorite) {
        await _repository.removeFromFavorites(movie.title);
        setState(() {
          _favorites.removeWhere((fav) => fav.title == movie.title);
        });
      } else {
        final newMovie = await _repository.addToFavorites(movie);
        setState(() {
          _favorites.add(newMovie);
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  List<String> _getUniqueGenres(List<dynamic> movies) {
    final genres = <String>{};
    for (var movie in movies) {
      if (movie is FetchedMovies || movie is Movie) {
        genres.addAll(movie.genres);
      }
    }
    return genres.toList()..sort();
  }

  List<String> _getUniqueYears(List<dynamic> movies) {
    final years = movies
        .map((movie) {
          if (movie is FetchedMovies) {
            return movie.date.year.toString();
          } else if (movie is Movie) {
            return movie.releaseDate.year.toString();
          }
          return '';
        })
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<FetchedMovies> get _filteredMovies {
    return _movies.where((movie) {
      final matchesSearch = _homeSearchQuery.isEmpty ||
          movie.title.toLowerCase().contains(_homeSearchQuery.toLowerCase()) ||
          movie.description
              .toLowerCase()
              .contains(_homeSearchQuery.toLowerCase());
      final matchesGenre = _homeSelectedGenre == null ||
          _homeSelectedGenre == 'All' ||
          movie.genres.contains(_homeSelectedGenre);
      final matchesYear = _homeSelectedYear == null ||
          _homeSelectedYear == 'All' ||
          movie.date.year.toString() == _homeSelectedYear;
      return matchesSearch && matchesGenre && matchesYear;
    }).toList();
  }

  List<Movie> get _filteredFavorites {
    return _favorites.where((movie) {
      final matchesSearch = _favoritesSearchQuery.isEmpty ||
          movie.title
              .toLowerCase()
              .contains(_favoritesSearchQuery.toLowerCase()) ||
          movie.description
              .toLowerCase()
              .contains(_favoritesSearchQuery.toLowerCase());
      final matchesGenre = _favoritesSelectedGenre == null ||
          _favoritesSelectedGenre == 'All' ||
          movie.genres.contains(_favoritesSelectedGenre);
      final matchesYear = _favoritesSelectedYear == null ||
          _favoritesSelectedYear == 'All' ||
          movie.releaseDate.year.toString() == _favoritesSelectedYear;
      return matchesSearch && matchesGenre && matchesYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Home Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MovieSearchBar(
                  onChanged: (query) {
                    setState(() {
                      _homeSearchQuery = query;
                    });
                  },
                  hintText: 'Search movies...',
                ),
              ),
              if (_movies.isNotEmpty)
                FilterDropdowns(
                  allGenres: _getUniqueGenres(_movies),
                  allYears: _getUniqueYears(_movies),
                  selectedGenre: _homeSelectedGenre,
                  selectedYear: _homeSelectedYear,
                  onGenreChanged: (value) {
                    setState(() {
                      _homeSelectedGenre = value;
                    });
                  },
                  onYearChanged: (value) {
                    setState(() {
                      _homeSelectedYear = value;
                    });
                  },
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(child: Text(_error))
                        : ListView.builder(
                            itemCount: _filteredMovies.length,
                            itemBuilder: (context, index) {
                              final movie = _filteredMovies[index];
                              final isFavorite = _favorites
                                  .any((fav) => fav.title == movie.title);
                              return MovieCard(
                                movie: movie,
                                isFavorite: isFavorite,
                                onToggleFavorite: () => _toggleFavorite(movie),
                              );
                            },
                          ),
              ),
            ],
          ),
          // Favorites Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MovieSearchBar(
                  onChanged: (query) {
                    setState(() {
                      _favoritesSearchQuery = query;
                    });
                  },
                  hintText: 'Search favorites...',
                ),
              ),
              if (_favorites.isNotEmpty)
                FilterDropdowns(
                  allGenres: _getUniqueGenres(_favorites),
                  allYears: _getUniqueYears(_favorites),
                  selectedGenre: _favoritesSelectedGenre,
                  selectedYear: _favoritesSelectedYear,
                  onGenreChanged: (value) {
                    setState(() {
                      _favoritesSelectedGenre = value;
                    });
                  },
                  onYearChanged: (value) {
                    setState(() {
                      _favoritesSelectedYear = value;
                    });
                  },
                ),
              Expanded(
                child: _favorites.isEmpty
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
                                _toggleFavorite(fetchedMovie),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
