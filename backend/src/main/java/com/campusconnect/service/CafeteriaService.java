package com.campusconnect.service;

import com.campusconnect.dto.CafeteriaItemDto;
import com.campusconnect.dto.CafeteriaMenuDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class CafeteriaService {

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    // ── Belirli bir günün menüsü ───────────────────────────────────────────────

    public List<CafeteriaMenuDto> getMenuByDate(LocalDate date) {
        return jdbc.query(
            """
            SELECT id, menu_date::text, meal_type, items::text, calories, price
            FROM cafeteria_menu
            WHERE menu_date = ?
            ORDER BY CASE meal_type
                WHEN 'BREAKFAST' THEN 1
                WHEN 'LUNCH'     THEN 2
                WHEN 'DINNER'    THEN 3
                ELSE 4 END
            """,
            (rs, row) -> {
                List<CafeteriaItemDto> items = parseItems(rs.getString("items"));
                return CafeteriaMenuDto.builder()
                    .id(rs.getLong("id"))
                    .menuDate(rs.getString("menu_date"))
                    .mealType(rs.getString("meal_type"))
                    .items(items)
                    .totalCalories(rs.getInt("calories"))
                    .price(rs.getBigDecimal("price"))
                    .build();
            },
            date
        );
    }

    // ── Bugünün menüsü ────────────────────────────────────────────────────────

    public List<CafeteriaMenuDto> getTodayMenu() {
        return getMenuByDate(LocalDate.now());
    }

    // ── Menü oluştur / güncelle (upsert) ─────────────────────────────────────

    public CafeteriaMenuDto upsertMenu(java.util.Map<String, Object> req) {
        String menuDate  = req.getOrDefault("menuDate",  "").toString();
        String mealType  = req.getOrDefault("mealType",  "LUNCH").toString();
        Object itemsObj  = req.get("items");
        int    calories  = req.containsKey("calories") ? (int) req.get("calories") : 0;
        double price     = req.containsKey("price")    ? Double.parseDouble(req.get("price").toString()) : 0;

        String itemsJson;
        try {
            itemsJson = objectMapper.writeValueAsString(itemsObj != null ? itemsObj : java.util.List.of());
        } catch (Exception e) { itemsJson = "[]"; }

        jdbc.update(
            """
            INSERT INTO cafeteria_menu (menu_date, meal_type, items, calories, price)
            VALUES (?::date, ?, ?::jsonb, ?, ?)
            ON CONFLICT (menu_date, meal_type)
            DO UPDATE SET items = EXCLUDED.items, calories = EXCLUDED.calories, price = EXCLUDED.price
            """,
            menuDate, mealType, itemsJson, calories, java.math.BigDecimal.valueOf(price)
        );

        var list = getMenuByDate(java.time.LocalDate.parse(menuDate));
        return list.stream().filter(m -> m.getMealType().equals(mealType)).findFirst()
            .orElse(null);
    }

    // ── JSON parse yardımcısı ─────────────────────────────────────────────────

    private List<CafeteriaItemDto> parseItems(String json) {
        if (json == null || json.isBlank()) return Collections.emptyList();
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception e) {
            log.warn("Cafeteria items JSON parse hatası: {}", e.getMessage());
            return Collections.emptyList();
        }
    }
}
