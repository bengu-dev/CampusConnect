package com.campusconnect.controller;
import com.campusconnect.model.Announcement;
import com.campusconnect.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnnouncementController {
    private final AnnouncementRepository repository;

    @GetMapping
    public ResponseEntity<List<Announcement>> getAll() {
        return ResponseEntity.ok(repository.findAllByOrderByImportantDescPublishDateDesc());
    }
}
