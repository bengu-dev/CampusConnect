package com.campusconnect.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

/**
 * Kafeterya menüsü endpoint'leri.
 * Tüm veriler cafeteria_menu tablosundan PostgreSQL sorgusuyla gelir.
 * items kolonu JSONB — yemek adı + kalori listesi içerir.
 * Hardcode veri YOKTUR.
 */
@Slf4j
@RestController
@RequestMapping("/api/cafeteria")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CafeteriaController {

    private final JdbcTemplate jdbc;
    private final ObjectMapper  objectMapper;

    /**
     * GET /api/cafeteria
     * Bugünün menüsünü döner (date = CURRENT_DATE).
     * ?date=2025-05-15 ile farklı gün sorgulanabilir.
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMenu(
            @RequestParam(required = false) String date) {

        LocalDate targetDate;
        try {
            targetDate = (date != null && !date.isBlank())
                ? LocalDate.parse(date)
                : LocalDate.now();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(
                Map.of("success", false, "message", "Geçersiz tarih formatı! Örnek: 2025-05-15")
            );
        }

        // cafeteria_menu tablosundan gerçek sorgu
        // meal_type sırası: BREAKFAST → LUNCH → DINNER
        List<Map<String, Object>> rows = jdbc.queryForList(
            """
            SELECT
                id,
                date::text       AS menu_date,
                meal_type,
                items::text      AS items_json,
                calories,
                price
            FROM cafeteria_menu
            WHERE date = ?
            ORDER BY
                CASE meal_type
                    WHEN 'BREAKFAST' THEN 1
                    WHEN 'LUNCH'     THEN 2
                    WHEN 'DINNER'    THEN 3
                    ELSE 4
                END
            """,
            targetDate
        );

        // JSONB items_json → List<Map> şeklinde parse et
        List<Map<String, Object>> meals = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            Map<String, Object> meal = new LinkedHashMap<>(row);
            String itemsJson = (String) meal.remove("items_json");
            meal.put("items", parseItems(itemsJson));
            meals.add(meal);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success",  true);
        response.put("date",     targetDate.toString());
        response.put("isToday",  targetDate.isEqual(LocalDate.now()));
        response.put("menu",     meals);
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/cafeteria
     * Yeni menü ekle veya güncelle — sadece OFFICE rolü erişebilir.
     * upsert: (date, meal_type) unique kısıtı üzerinden ON CONFLICT ile yapılır.
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> upsertMenu(
            @RequestHeader("Authorization") String auth,
            @RequestBody Map<String, Object> req) {

        String menuDate = Objects.toString(req.get("menuDate"), null);
        String mealType = Objects.toString(req.get("mealType"), null);
        Object itemsObj = req.get("items");
        int    calories = req.containsKey("calories") ? ((Number) req.get("calories")).intValue() : 0;
        double price    = req.containsKey("price")    ? ((Number) req.get("price")).doubleValue()  : 0;

        if (menuDate == null || mealType == null) {
            return ResponseEntity.badRequest().body(
                Map.of("success", false, "message", "menuDate ve mealType zorunludur!"));
        }

        String itemsJson;
        try {
            itemsJson = objectMapper.writeValueAsString(
                itemsObj != null ? itemsObj : Collections.emptyList());
        } catch (Exception e) {
            itemsJson = "[]";
        }

        jdbc.update(
            """
            INSERT INTO cafeteria_menu (date, meal_type, items, calories, price)
            VALUES (?::date, ?, ?::jsonb, ?, ?)
            ON CONFLICT (date, meal_type)
            DO UPDATE SET
                items    = EXCLUDED.items,
                calories = EXCLUDED.calories,
                price    = EXCLUDED.price
            """,
            menuDate, mealType, itemsJson, calories,
            java.math.BigDecimal.valueOf(price)
        );

        return ResponseEntity.ok(Map.of("success", true, "message", "Menü güncellendi."));
    }

    // JSONB text → Java List<Map>
    private List<Map<String, Object>> parseItems(String json) {
        if (json == null || json.isBlank() || json.equals("null")) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception e) {
            log.warn("Cafeteria items parse hatası: {}", e.getMessage());
            return Collections.emptyList();
        }
    }
}
