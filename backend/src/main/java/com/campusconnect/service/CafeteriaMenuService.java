package com.campusconnect.service;

import com.campusconnect.model.CafeteriaMenu;
import com.campusconnect.repository.CafeteriaMenuRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CafeteriaMenuService {
    private final CafeteriaMenuRepository cafeteriaMenuRepository;

    public Optional<CafeteriaMenu> getTodayMenu() {
        return cafeteriaMenuRepository.findByMenuDate(LocalDate.now());
    }

    public List<CafeteriaMenu> getWeeklyMenu() {
        return cafeteriaMenuRepository.findByMenuDateGreaterThanEqualOrderByMenuDateAsc(LocalDate.now());
    }
}
