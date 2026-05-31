-- CampusConnect — 5 Yeni Öğretmen + Dersler + Program
BEGIN;

-- Mevcut hash'i referans al (tüm kullanıcılar aynı şifre 123456)
DO $$
DECLARE v_hash TEXT;
BEGIN
    SELECT password INTO v_hash FROM users WHERE role='TEACHER' LIMIT 1;

    INSERT INTO users (first_name, last_name, email, password, role, staff_id, department) VALUES
    ('Zeynep',  'Aktaş',    'zeynep.aktas@agu.edu.tr',   v_hash, 'TEACHER', 'T006', 'Bilgisayar Mühendisliği'),
    ('Can',     'Özdemir',  'can.ozdemir@agu.edu.tr',    v_hash, 'TEACHER', 'T007', 'Elektrik-Elektronik Mühendisliği'),
    ('Deniz',   'Yıldız',   'deniz.yildiz2@agu.edu.tr',  v_hash, 'TEACHER', 'T008', 'Endüstri Mühendisliği'),
    ('Seda',    'Kara',     'seda.kara@agu.edu.tr',      v_hash, 'TEACHER', 'T009', 'İşletme'),
    ('Burak',   'Çetin',    'burak.cetin2@agu.edu.tr',   v_hash, 'TEACHER', 'T010', 'Matematik')
    ON CONFLICT (email) DO NOTHING;
END $$;

-- ─── Yeni dersler (5 öğretmen için) ──────────────────────────
INSERT INTO courses (code, name, description, credits, department, teacher_id, capacity, semester, academic_year)
VALUES
('BLM101', 'Bilgisayar Ağları',
 'TCP/IP, OSI modeli, yönlendirme ve ağ güvenliği',
 3, 'Bilgisayar Mühendisliği',
 (SELECT id FROM users WHERE email='zeynep.aktas@agu.edu.tr'), 30, 'Güz', '2025-2026'),

('BLM201', 'İşletim Sistemleri',
 'Süreç yönetimi, bellek yönetimi, dosya sistemleri',
 4, 'Bilgisayar Mühendisliği',
 (SELECT id FROM users WHERE email='zeynep.aktas@agu.edu.tr'), 25, 'Bahar', '2025-2026'),

('EEE101', 'Devre Teorisi',
 'Kirchhoff yasaları, AC/DC devre analizi, rezonans',
 4, 'Elektrik-Elektronik Mühendisliği',
 (SELECT id FROM users WHERE email='can.ozdemir@agu.edu.tr'), 40, 'Güz', '2025-2026'),

('EEE201', 'Sayısal Elektronik',
 'Lojik kapılar, flip-floplar, sayıcılar ve çarpanlar',
 3, 'Elektrik-Elektronik Mühendisliği',
 (SELECT id FROM users WHERE email='can.ozdemir@agu.edu.tr'), 35, 'Bahar', '2025-2026'),

('END101', 'Üretim Yönetimi',
 'Üretim planlama, stok kontrolü ve kalite yönetimi',
 3, 'Endüstri Mühendisliği',
 (SELECT id FROM users WHERE email='deniz.yildiz2@agu.edu.tr'), 35, 'Güz', '2025-2026'),

('ISL101', 'İşletme Yönetimi',
 'Temel işletme fonksiyonları: pazarlama, finans, insan kaynakları',
 3, 'İşletme',
 (SELECT id FROM users WHERE email='seda.kara@agu.edu.tr'), 50, 'Güz', '2025-2026'),

('ISL201', 'Finansal Muhasebe',
 'Bilanço, gelir tablosu ve temel muhasebe ilkeleri',
 3, 'İşletme',
 (SELECT id FROM users WHERE email='seda.kara@agu.edu.tr'), 45, 'Bahar', '2025-2026'),

('MAT201', 'Lineer Cebir',
 'Vektörler, matrisler, determinantlar ve öz değerler',
 4, 'Matematik',
 (SELECT id FROM users WHERE email='burak.cetin2@agu.edu.tr'), 40, 'Güz', '2025-2026'),

('MAT301', 'Sayısal Analiz',
 'İnterpolasyon, nümerik integrasyon ve diferansiyel denklemler',
 3, 'Matematik',
 (SELECT id FROM users WHERE email='burak.cetin2@agu.edu.tr'), 35, 'Bahar', '2025-2026')
ON CONFLICT (code) DO NOTHING;

-- ─── Ders programları ─────────────────────────────────────────
INSERT INTO schedule (course_id, day_of_week, start_time, end_time, classroom, building) VALUES
((SELECT id FROM courses WHERE code='BLM101'), 'TUESDAY',   '09:00', '10:50', 'C201', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='BLM201'), 'THURSDAY',  '09:00', '10:50', 'C202', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='EEE101'), 'MONDAY',    '11:00', '12:50', 'D201', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='EEE201'), 'WEDNESDAY', '11:00', '12:50', 'D202', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='END101'), 'TUESDAY',   '11:00', '12:50', 'E201', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='ISL101'), 'MONDAY',    '13:00', '14:50', 'H201', 'İktisadi ve İdari Bilimler'),
((SELECT id FROM courses WHERE code='ISL201'), 'WEDNESDAY', '13:00', '14:50', 'H202', 'İktisadi ve İdari Bilimler'),
((SELECT id FROM courses WHERE code='MAT201'), 'FRIDAY',    '09:00', '10:50', 'C103', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='MAT301'), 'THURSDAY',  '11:00', '12:50', 'C104', 'Fen-Edebiyat Fakültesi')
ON CONFLICT DO NOTHING;

-- ─── Mevcut öğrencileri yeni derslere kaydet ──────────────────
-- BLM101 (Bilgisayar Ağları) — 20 öğrenci
INSERT INTO enrollments (student_id, course_id, status) VALUES
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='zeynep.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='mehmet.yildiz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='emre.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='burak.aydin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='kaan.cetin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='osman.yildirim@agu.edu.tr'), (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='furkan.aksoy@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='ahmet.bayrak@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='ceren.yilmaz@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='deniz.celik@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='gokhan.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='hande.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='kemal.ozturk@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='leyla.cetin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='murat.gunes@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='onur.yildiz@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='pelin.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='rahim.koca@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='tolga.bayram@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BLM101'), 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- EEE101 (Devre Teorisi) — 15 öğrenci
INSERT INTO enrollments (student_id, course_id, status) VALUES
((SELECT id FROM users WHERE email='fatma.sahin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='serkan.dogan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='elif.gunes@agu.edu.tr'),     (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='nilufer.kilic@agu.edu.tr'),  (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='selma.arslan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='umit.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='vildan.yilmaz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='yusuf.ozer@agu.edu.tr'),     (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='ibrahim.aydin@agu.edu.tr'),  (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='jale.sahin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='ayse.koca@agu.edu.tr'),      (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='selin.ozkan@agu.edu.tr'),    (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='nur.aksu@agu.edu.tr'),       (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='busra.tekin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='pinar.guler@agu.edu.tr'),    (SELECT id FROM courses WHERE code='EEE101'), 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ISL101 (İşletme Yönetimi) — 12 öğrenci
INSERT INTO enrollments (student_id, course_id, status) VALUES
((SELECT id FROM users WHERE email='huseyin.demir@agu.edu.tr'),  (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='merve.kilic@agu.edu.tr'),    (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='irem.yalcin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='tarik.eren@agu.edu.tr'),     (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='ece.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='selma.arslan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='jale.sahin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='pelin.demir@agu.edu.tr'),    (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='rahim.koca@agu.edu.tr'),     (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='vildan.yilmaz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='umit.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE'),
((SELECT id FROM users WHERE email='yusuf.ozer@agu.edu.tr'),     (SELECT id FROM courses WHERE code='ISL101'), 'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

COMMIT;
