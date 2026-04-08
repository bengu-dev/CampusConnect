package com.campusconnect.config;

import com.campusconnect.model.*;
import com.campusconnect.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    private final CourseRepository courseRepository;
    private final EventRepository eventRepository;
    private final CafeteriaMenuRepository cafeteriaMenuRepository;
    private final AnnouncementRepository announcementRepository;

    @Override
    public void run(String... args) {
        initCourses();
        initEvents();
        initCafeteriaMenus();
        initAnnouncements();
    }

    private void initCourses() {
        if (courseRepository.count() > 0) return;
        courseRepository.saveAll(List.of(
            Course.builder().courseName("Veri Yapıları ve Algoritmalar").courseCode("CS201")
                .teacherName("Dr. Ahmet Yılmaz").dayOfWeek("Pazartesi")
                .startTime("09:00").endTime("10:50").room("A101")
                .department("Bilgisayar Mühendisliği").targetRole(Role.STUDENT).build(),
            Course.builder().courseName("Nesne Yönelimli Programlama").courseCode("CS202")
                .teacherName("Dr. Ayşe Kaya").dayOfWeek("Salı")
                .startTime("11:00").endTime("12:50").room("B205")
                .department("Bilgisayar Mühendisliği").targetRole(Role.STUDENT).build(),
            Course.builder().courseName("Veritabanı Sistemleri").courseCode("CS301")
                .teacherName("Prof. Dr. Mehmet Demir").dayOfWeek("Çarşamba")
                .startTime("13:00").endTime("14:50").room("C310")
                .department("Bilgisayar Mühendisliği").targetRole(Role.STUDENT).build(),
            Course.builder().courseName("İşletim Sistemleri").courseCode("CS302")
                .teacherName("Dr. Fatma Çelik").dayOfWeek("Perşembe")
                .startTime("09:00").endTime("10:50").room("A202")
                .department("Bilgisayar Mühendisliği").targetRole(Role.STUDENT).build(),
            Course.builder().courseName("Yazılım Mühendisliği").courseCode("CS401")
                .teacherName("Dr. Ahmet Yılmaz").dayOfWeek("Cuma")
                .startTime("14:00").endTime("15:50").room("D401")
                .department("Bilgisayar Mühendisliği").targetRole(Role.STUDENT).build(),
            Course.builder().courseName("Veri Yapıları ve Algoritmalar").courseCode("CS201")
                .teacherName("Dr. Ahmet Yılmaz").dayOfWeek("Pazartesi")
                .startTime("09:00").endTime("10:50").room("A101")
                .department("Bilgisayar Mühendisliği").targetRole(Role.TEACHER).build(),
            Course.builder().courseName("Yazılım Mühendisliği").courseCode("CS401")
                .teacherName("Dr. Ahmet Yılmaz").dayOfWeek("Cuma")
                .startTime("14:00").endTime("15:50").room("D401")
                .department("Bilgisayar Mühendisliği").targetRole(Role.TEACHER).build(),
            Course.builder().courseName("Lineer Cebir").courseCode("MATH101")
                .teacherName("Prof. Dr. Ali Şahin").dayOfWeek("Salı")
                .startTime("08:00").endTime("09:50").room("E101")
                .department("Matematik").targetRole(Role.TEACHER).build()
        ));
    }

    private void initEvents() {
        if (eventRepository.count() > 0) return;
        LocalDate today = LocalDate.now();
        eventRepository.saveAll(List.of(
            Event.builder()
                .title("Bahar Şenliği 2024")
                .description("Üniversitemizin yıllık bahar şenliği! Konserler, eğlenceli aktiviteler ve çok daha fazlası sizleri bekliyor.")
                .eventDate(today.plusDays(5)).eventTime("10:00")
                .location("Ana Kampüs Meydanı").organizer("Öğrenci Konseyi").build(),
            Event.builder()
                .title("Kariyer Fuarı")
                .description("50+ şirketin katılımıyla gerçekleşecek kariyer fuarına CV'nizi hazırlayarak katılın.")
                .eventDate(today.plusDays(10)).eventTime("09:00")
                .location("Kongre Merkezi").organizer("Kariyer Merkezi").build(),
            Event.builder()
                .title("Yapay Zeka Konferansı")
                .description("Türkiye'nin önde gelen yapay zeka uzmanlarının katılımıyla düzenlenecek konferansa davetlisiniz.")
                .eventDate(today.plusDays(15)).eventTime("13:00")
                .location("Mühendislik Fakültesi Konferans Salonu")
                .organizer("Bilgisayar Mühendisliği Bölümü").build(),
            Event.builder()
                .title("Mezuniyet Töreni")
                .description("2023-2024 akademik yılı mezunları için düzenlenecek törenimize ailenizle birlikte davetlisiniz.")
                .eventDate(today.plusDays(30)).eventTime("14:00")
                .location("Spor Kompleksi").organizer("Rektörlük").build()
        ));
    }

    private void initAnnouncements() {
        if (announcementRepository.count() > 0) return;
        LocalDate today = LocalDate.now();
        announcementRepository.saveAll(List.of(
            Announcement.builder()
                .title("2024-2025 Bahar Yarıyılı Kayıt Tarihleri")
                .content("Bahar yarıyılı ders kayıtları 15 Ocak - 20 Ocak 2025 tarihleri arasında gerçekleştirilecektir. Ders kaydı öncesinde danışmanınızla görüşmeniz zorunludur.")
                .category("Akademik").publishDate(today).important(true).author("Öğrenci İşleri").build(),
            Announcement.builder()
                .title("Kütüphane Çalışma Saatleri Güncellendi")
                .content("Sınav dönemine özel olarak üniversite kütüphanesi hafta içi 07:00-24:00, hafta sonu 09:00-22:00 saatleri arasında hizmet verecektir.")
                .category("Genel").publishDate(today.minusDays(1)).important(false).author("Kütüphane Müdürlüğü").build(),
            Announcement.builder()
                .title("Burs Başvuruları Başladı")
                .content("2024-2025 akademik yılı burs başvuruları başlamıştır. Başvurular 28 Şubat 2025 tarihine kadar öğrenci bilgi sistemi üzerinden yapılabilir.")
                .category("Burs").publishDate(today.minusDays(2)).important(true).author("Burs Birimi").build(),
            Announcement.builder()
                .title("Kampüs Otoparkı Bakım Çalışması")
                .content("10-12 Şubat 2025 tarihleri arasında C blok otoparkı bakım çalışması nedeniyle kapalı olacaktır. Araçlarınızı A veya B blok otoparklarına park edebilirsiniz.")
                .category("Duyuru").publishDate(today.minusDays(3)).important(false).author("Teknik İşler").build(),
            Announcement.builder()
                .title("Erasmus+ 2025-2026 Başvuruları")
                .content("Erasmus+ değişim programı 2025-2026 akademik yılı başvuruları açılmıştır. Detaylı bilgi ve başvuru formu için Uluslararası İlişkiler Ofisi'ni ziyaret ediniz.")
                .category("Uluslararası").publishDate(today.minusDays(4)).important(true).author("Uluslararası İlişkiler Ofisi").build()
        ));
    }

    private void initCafeteriaMenus() {
        if (cafeteriaMenuRepository.count() > 0) return;
        LocalDate today = LocalDate.now();
        cafeteriaMenuRepository.saveAll(List.of(
            CafeteriaMenu.builder().menuDate(today)
                .soup("Mercimek Çorbası").mainDish("Tavuk Haşlama").sideDish("Pilav")
                .salad("Mevsim Salatası").dessert("Sütlaç").drinks("Ayran / Su").build(),
            CafeteriaMenu.builder().menuDate(today.plusDays(1))
                .soup("Domates Çorbası").mainDish("Köfte").sideDish("Makarna")
                .salad("Çoban Salatası").dessert("Meyve").drinks("Ayran / Su").build(),
            CafeteriaMenu.builder().menuDate(today.plusDays(2))
                .soup("Ezogelin Çorbası").mainDish("Etli Nohut").sideDish("Bulgur Pilavı")
                .salad("Mevsim Salatası").dessert("Kadayıf").drinks("Ayran / Su").build(),
            CafeteriaMenu.builder().menuDate(today.plusDays(3))
                .soup("Şehriye Çorbası").mainDish("Tavuk Izgara").sideDish("Patates Kızartması")
                .salad("Yeşil Salata").dessert("Komposto").drinks("Ayran / Su").build(),
            CafeteriaMenu.builder().menuDate(today.plusDays(4))
                .soup("Tarhana Çorbası").mainDish("Kuru Fasulye").sideDish("Pilav")
                .salad("Mevsim Salatası").dessert("Helva").drinks("Ayran / Su").build()
        ));
    }
}
