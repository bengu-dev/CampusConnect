package com.campusconnect.repository;

import com.campusconnect.model.CafeteriaMenu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CafeteriaMenuRepository extends JpaRepository<CafeteriaMenu, Long> {
    Optional<CafeteriaMenu> findByMenuDate(LocalDate date);
    List<CafeteriaMenu> findByMenuDateGreaterThanEqualOrderByMenuDateAsc(LocalDate date);
}
