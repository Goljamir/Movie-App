class Movie {
  final int? id;
  final String title;
  final String description;
  final List<String> genres;
  final DateTime releaseDate;
  final String imgUrl;

  Movie({
    this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.releaseDate,
    required this.imgUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      genres: List<String>.from(json['genres'] ?? []),
      releaseDate: DateTime.parse(json['releaseDate']),
      imgUrl: json['imgUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'genres': genres,
      'releaseDate': releaseDate.toIso8601String().split('T')[0],
      'imgUrl': imgUrl,
    };
  }
}
