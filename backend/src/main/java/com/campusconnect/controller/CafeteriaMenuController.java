package com.campusconnect.controller;

import com.campusconnect.model.CafeteriaMenu;
import com.campusconnect.service.CafeteriaMenuService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cafeteria")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CafeteriaMenuController {
    private final CafeteriaMenuService cafeteriaMenuService;

    @GetMapping
    public ResponseEntity<List<CafeteriaMenu>> getWeeklyMenu() {
        return ResponseEntity.ok(cafeteriaMenuService.getWeeklyMenu());
    }

    @GetMapping("/today")
    public ResponseEntity<?> getTodayMenu() {
        return cafeteriaMenuService.getTodayMenu()
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.ok(Map.of("message", "Bugün için menü bulunamadı.")));
    }
}
