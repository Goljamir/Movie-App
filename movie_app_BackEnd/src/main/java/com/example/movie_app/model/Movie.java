package com.example.movie_app.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "movies")
public class Movie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // Auto-increment ID
    private Long id;

    private String title;
    private String description;

    @ElementCollection  // Stores genres as a separate table
    @CollectionTable(name = "movie_genres", joinColumns = @JoinColumn(name = "movie_id"))
    @Column(name = "genre")
    private List<String> genres;

    private LocalDate releaseDate;
    private String imgUrl;

    public Movie() {}

    public Movie(String title, String description, List<String> genres, LocalDate releaseDate, String imgUrl) {
        this.title = title;
        this.description = description;
        this.genres = genres;
        this.releaseDate = releaseDate;
        this.imgUrl = imgUrl;
    }

    // ✅ Getters
    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public List<String> getGenres() {
        return genres;
    }

    public LocalDate getReleaseDate() {
        return releaseDate;
    }

    public String getImgUrl() {
        return imgUrl;
    }

    // ✅ Setters
    public void setId(Long id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setGenres(List<String> genres) {
        this.genres = genres;
    }

    public void setReleaseDate(LocalDate releaseDate) {
        this.releaseDate = releaseDate;
    }

    public void setImgUrl(String imgUrl) {
        this.imgUrl = imgUrl;
    }
}
