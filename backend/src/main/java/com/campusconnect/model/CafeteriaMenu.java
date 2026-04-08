package com.campusconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "cafeteria_menus")
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CafeteriaMenu {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false) private LocalDate menuDate;
    private String soup;
    private String mainDish;
    private String sideDish;
    private String salad;
    private String dessert;
    private String drinks;
}
