-- CampusConnect — Ahmet Hoca Veri Güncelleme
-- BIL101 ve BIL201 doldurma, BIL301 yeni ders, öğretmen programı
BEGIN;

-- ─── 20 yeni öğrenci ekle (S2026022–S2026041) ────────────────
INSERT INTO users (first_name, last_name, email, password, role, student_id, department) VALUES
('Ahmet',    'Bayrak',    'ahmet.bayrak@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026022', 'Yazılım Mühendisliği'),
('Ceren',    'Yılmaz',    'ceren.yilmaz@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026023', 'Bilgisayar Mühendisliği'),
('Deniz',    'Çelik',     'deniz.celik@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026024', 'Yazılım Mühendisliği'),
('Ece',      'Kaya',      'ece.kaya@agu.edu.tr',        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026025', 'Matematik'),
('Gökhan',   'Arslan',    'gokhan.arslan@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026026', 'Yazılım Mühendisliği'),
('Hande',    'Demir',     'hande.demir@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026027', 'Bilgisayar Mühendisliği'),
('İbrahim',  'Aydın',     'ibrahim.aydin@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026028', 'Yazılım Mühendisliği'),
('Jale',     'Şahin',     'jale.sahin@agu.edu.tr',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026029', 'Endüstri Mühendisliği'),
('Kemal',    'Öztürk',    'kemal.ozturk@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026030', 'Yazılım Mühendisliği'),
('Leyla',    'Çetin',     'leyla.cetin@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026031', 'Bilgisayar Mühendisliği'),
('Murat',    'Güneş',     'murat.gunes@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026032', 'Yazılım Mühendisliği'),
('Nilüfer',  'Kılıç',     'nilufer.kilic@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026033', 'Elektrik-Elektronik Mühendisliği'),
('Onur',     'Yıldız',    'onur.yildiz@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026034', 'Yazılım Mühendisliği'),
('Pelin',    'Demir',     'pelin.demir@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026035', 'Bilgisayar Mühendisliği'),
('Rahim',    'Koca',      'rahim.koca@agu.edu.tr',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026036', 'Yazılım Mühendisliği'),
('Selma',    'Arslan',    'selma.arslan@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026037', 'Matematik'),
('Tolga',    'Bayram',    'tolga.bayram@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026038', 'Yazılım Mühendisliği'),
('Ümit',     'Çelik',     'umit.celik@agu.edu.tr',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026039', 'Bilgisayar Mühendisliği'),
('Vildan',   'Yılmaz',    'vildan.yilmaz@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026040', 'Yazılım Mühendisliği'),
('Yusuf',    'Özer',      'yusuf.ozer@agu.edu.tr',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026041', 'Yazılım Mühendisliği')
ON CONFLICT (email) DO NOTHING;

-- ─── Yeni ders: Algoritma Analizi (BIL301) — Ahmet Hoca ──────
INSERT INTO courses (code, name, description, credits, department, teacher_id, capacity, semester, academic_year)
VALUES (
    'BIL301',
    'Algoritma Analizi',
    'Algoritma karmaşıklığı, sıralama, arama ve graf algoritmaları',
    3,
    'Yazılım Mühendisliği',
    (SELECT id FROM users WHERE email = 'ahmet@agu.edu.tr'),
    30,
    'Güz',
    '2025-2026'
)
ON CONFLICT (code) DO NOTHING;

-- ─── BIL301 ders programı: Cuma 11:00-12:50 ──────────────────
INSERT INTO schedule (course_id, day_of_week, start_time, end_time, classroom, building)
VALUES (
    (SELECT id FROM courses WHERE code = 'BIL301'),
    'FRIDAY', '11:00', '12:50', 'B301', 'Mühendislik Fakültesi'
)
ON CONFLICT DO NOTHING;

-- ─── BIL101: Mevcut kayıtsız öğrencileri ekle ────────────────
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
-- Mevcut öğrencilerden kayıtsız olanlar
((SELECT id FROM users WHERE email='fatma.sahin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'CC', 'COMPLETED'),
((SELECT id FROM users WHERE email='huseyin.demir@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'), 'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='burak.aydin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='elif.gunes@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='merve.kilic@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='tarik.eren@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL101'), 'CC', 'COMPLETED'),
((SELECT id FROM users WHERE email='pinar.guler@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='serkan.dogan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='irem.yalcin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
-- Yeni öğrenciler — BIL101
((SELECT id FROM users WHERE email='ahmet.bayrak@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL101'), 'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='ceren.yilmaz@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='deniz.celik@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='ece.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL101'), 'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='gokhan.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'), 'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='hande.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='ibrahim.aydin@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='jale.sahin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL101'), 'CC', 'COMPLETED'),
((SELECT id FROM users WHERE email='kemal.ozturk@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL101'), 'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='leyla.cetin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='murat.gunes@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='nilufer.kilic@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'), 'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='onur.yildiz@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'), 'BA', 'COMPLETED')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ─── BIL201: Eksik öğrencileri ekle (30 kapasiteye ulaş) ─────
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
((SELECT id FROM users WHERE email='fatma.sahin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='huseyin.demir@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='burak.aydin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='elif.gunes@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='merve.kilic@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='osman.yildirim@agu.edu.tr'), (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='tarik.eren@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='pinar.guler@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='serkan.dogan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='irem.yalcin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='furkan.aksoy@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ahmet.bayrak@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ceren.yilmaz@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='deniz.celik@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ece.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='gokhan.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='hande.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ibrahim.aydin@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='kemal.ozturk@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='leyla.cetin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'), NULL, 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ─── BIL301: 30 öğrenci kaydet ───────────────────────────────
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
((SELECT id FROM users WHERE email='bengu@agu.edu.tr'),          (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='zeynep.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='mehmet.yildiz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='fatma.sahin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='emre.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ayse.koca@agu.edu.tr'),      (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='huseyin.demir@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='selin.ozkan@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='burak.aydin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='elif.gunes@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='kaan.cetin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='merve.kilic@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='osman.yildirim@agu.edu.tr'), (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='nur.aksu@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='tarik.eren@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='pinar.guler@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='serkan.dogan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='busra.tekin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='furkan.aksoy@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='irem.yalcin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ahmet.bayrak@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ceren.yilmaz@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='deniz.celik@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='gokhan.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='hande.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='ibrahim.aydin@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='kemal.ozturk@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='leyla.cetin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='murat.gunes@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL301'), NULL, 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ─── Bildirim düzeltme: BIL101 notification body güncelle ────
UPDATE notifications n
SET body = c.name || ' (' || c.code || ') dersine kaydoldunuz.'
FROM enrollments e
JOIN courses c ON c.id = e.course_id
WHERE n.reference_id = e.id
  AND n.type = 'ENROLLMENT'
  AND c.code IN ('BIL101', 'BIL201', 'BIL301');

COMMIT;
