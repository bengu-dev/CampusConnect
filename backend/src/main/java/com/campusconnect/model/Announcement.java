package com.campusconnect.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "announcements")
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class Announcement {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false) private String title;
    @Column(length = 1000) private String content;
    private String category;
    private LocalDate publishDate;
    private boolean important;
    private String author;
}
