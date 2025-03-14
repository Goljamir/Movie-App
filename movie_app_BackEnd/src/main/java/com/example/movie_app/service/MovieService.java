package com.example.movie_app.service;


import com.example.movie_app.model.Movie;
import com.example.movie_app.repository.MovieRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MovieService {
    @Autowired
    private MovieRepository movieRepository;

    public Movie saveMovie(Movie movie){
        return movieRepository.save(movie);
    }

    public List<Movie> getAllMovies(){
        return movieRepository.findAll();
    }
}
