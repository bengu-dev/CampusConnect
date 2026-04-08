package com.campusconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "events")
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class Event {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false) private String title;
    @Column(columnDefinition = "TEXT") private String description;
    private LocalDate eventDate;
    private String eventTime;
    private String location;
    private String organizer;
}
