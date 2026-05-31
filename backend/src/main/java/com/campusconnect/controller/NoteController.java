package com.campusconnect.controller;

import com.campusconnect.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Kişisel not endpoint'leri.
 * Her kullanıcı yalnızca kendi notlarını görebilir / düzenleyebilir.
 * Kategori: PERSONAL | WORK | SOCIAL
 */
@RestController
@RequestMapping("/api/notes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NoteController {

    private final JdbcTemplate jdbc;

    /* ── GET /api/notes ─────────────────────────────────────────── */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getNotes() {
        UserPrincipal me = UserPrincipal.current();

        List<Map<String, Object>> notes = jdbc.queryForList(
            """
            SELECT id, title, content, category, color, created_at, updated_at
            FROM notes
            WHERE user_id = ?
            ORDER BY updated_at DESC
            """,
            me.getUserId()
        );

        return ResponseEntity.ok(Map.of("success", true, "notes", notes));
    }

    /* ── POST /api/notes ────────────────────────────────────────── */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createNote(@RequestBody Map<String, Object> req) {
        UserPrincipal me = UserPrincipal.current();

        String title    = Objects.toString(req.get("title"),    null);
        String content  = Objects.toString(req.get("content"),  "");
        String category = Objects.toString(req.get("category"), "PERSONAL");
        String color    = Objects.toString(req.get("color"),    "#6366F1");

        if (title == null || title.isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Başlık zorunludur!"));

        if (!Set.of("PERSONAL", "WORK", "SOCIAL").contains(category))
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Geçersiz kategori!"));

        try {
            Long newId = jdbc.queryForObject(
                """
                INSERT INTO notes (user_id, title, content, category, color, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, NOW(), NOW())
                RETURNING id
                """,
                Long.class,
                me.getUserId(), title.trim(), content.trim(), category, color
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "success", true,
                "message", "Not oluşturuldu!",
                "id", newId
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Not oluşturulamadı: " + e.getMessage()));
        }
    }

    /* ── PUT /api/notes/{id} ────────────────────────────────────── */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateNote(
            @PathVariable Long id,
            @RequestBody Map<String, Object> req) {
        UserPrincipal me = UserPrincipal.current();

        String title    = Objects.toString(req.get("title"),    null);
        String content  = Objects.toString(req.get("content"),  "");
        String category = Objects.toString(req.get("category"), "PERSONAL");
        String color    = Objects.toString(req.get("color"),    "#6366F1");

        if (title == null || title.isBlank())
            return ResponseEntity.badRequest()
                .body(Map.of("success", false, "message", "Başlık zorunludur!"));

        int rows = jdbc.update(
            """
            UPDATE notes
            SET title = ?, content = ?, category = ?, color = ?, updated_at = NOW()
            WHERE id = ? AND user_id = ?
            """,
            title.trim(), content.trim(), category, color, id, me.getUserId()
        );

        if (rows == 0)
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("success", false, "message", "Not bulunamadı!"));

        return ResponseEntity.ok(Map.of("success", true, "message", "Not güncellendi!"));
    }

    /* ── DELETE /api/notes/{id} ─────────────────────────────────── */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteNote(@PathVariable Long id) {
        UserPrincipal me = UserPrincipal.current();

        int rows = jdbc.update(
            "DELETE FROM notes WHERE id = ? AND user_id = ?",
            id, me.getUserId()
        );

        if (rows == 0)
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("success", false, "message", "Not bulunamadı!"));

        return ResponseEntity.ok(Map.of("success", true, "message", "Not silindi!"));
    }
}
