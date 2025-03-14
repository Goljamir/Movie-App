package com.example.movie_app.controller;

import com.example.movie_app.model.Movie;
import com.example.movie_app.repository.MovieRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/movies")
public class MovieController {

    private final MovieRepository movieRepository;

    public MovieController(MovieRepository movieRepository) {
        this.movieRepository = movieRepository;
    }

    // Fetch all movies
    @GetMapping
    public List<Movie> getAllMovies() {
        return movieRepository.findAll();
    }

    // Fetch single movie by ID
    @GetMapping("/{id}")
    public Optional<Movie> getMovieById(@PathVariable Long id) {
        return movieRepository.findById(id);
    }

    // Add new movie
    @PostMapping
    public Movie createMovie(@RequestBody Movie movie) {
        return movieRepository.save(movie);
    }

    // Update existing movie
    @PutMapping("/{id}")
    public Movie updateMovie(@PathVariable Long id, @RequestBody Movie updatedMovie) {
        return movieRepository.findById(id)
                .map(movie -> {
                    movie.setTitle(updatedMovie.getTitle());
                    movie.setDescription(updatedMovie.getDescription());
                    movie.setGenres(updatedMovie.getGenres());
                    movie.setReleaseDate(updatedMovie.getReleaseDate());
                    movie.setImgUrl(updatedMovie.getImgUrl());
                    return movieRepository.save(movie);
                })
                .orElseThrow(() -> new RuntimeException("Movie not found"));
    }

    // Delete movie
    @DeleteMapping("/{id}")
    public void deleteMovie(@PathVariable Long id) {
        movieRepository.deleteById(id);
    }
}
