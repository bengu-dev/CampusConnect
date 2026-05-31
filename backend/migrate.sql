-- ═══════════════════════════════════════════════════════════════
-- CAMPUSCONNECT — FULL SCHEMA MIGRATION + DATA
-- ═══════════════════════════════════════════════════════════════
BEGIN;

-- ─── Fix existing users ───────────────────────────────────────
UPDATE users SET first_name='Bengü',  last_name='Gedik',   student_id='S2026001', department='Yazılım Mühendisliği' WHERE email='bengu@agu.edu.tr';
UPDATE users SET first_name='Ahmet',  last_name='Yılmaz',  staff_id='T001',        department='Yazılım Mühendisliği' WHERE email='ahmet@agu.edu.tr';

-- ─── New teachers ────────────────────────────────────────────
INSERT INTO users (first_name, last_name, email, password, role, staff_id, department) VALUES
('Mehmet', 'Kaya',   'mehmet.kaya@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'TEACHER', 'T002', 'Matematik'),
('Ayşe',   'Demir',  'ayse.demir@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'TEACHER', 'T003', 'Yazılım Mühendisliği'),
('Fatma',  'Çelik',  'fatma.celik@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'TEACHER', 'T004', 'Fizik'),
('Mustafa','Şahin',  'mustafa.sahin@agu.edu.tr',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'TEACHER', 'T005', 'Yabancı Diller')
ON CONFLICT (email) DO NOTHING;

-- ─── OFFICE user ─────────────────────────────────────────────
INSERT INTO users (first_name, last_name, email, password, role, employee_id, department, position) VALUES
('Öğrenci', 'İşleri', 'ogrenci.isleri@agu.edu.tr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'OFFICE', 'E001', 'Öğrenci İşleri', 'Müdür')
ON CONFLICT (email) DO NOTHING;

-- ─── 20 students ─────────────────────────────────────────────
INSERT INTO users (first_name, last_name, email, password, role, student_id, department) VALUES
('Ali',     'Kaya',      'ali.kaya@agu.edu.tr',       '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026002', 'Yazılım Mühendisliği'),
('Zeynep',  'Arslan',    'zeynep.arslan@agu.edu.tr',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026003', 'Bilgisayar Mühendisliği'),
('Mehmet',  'Yıldız',    'mehmet.yildiz@agu.edu.tr',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026004', 'Yazılım Mühendisliği'),
('Fatma',   'Şahin',     'fatma.sahin@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026005', 'Elektrik-Elektronik Mühendisliği'),
('Emre',    'Çelik',     'emre.celik@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026006', 'Bilgisayar Mühendisliği'),
('Ayşe',    'Koca',      'ayse.koca@agu.edu.tr',      '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026007', 'Yazılım Mühendisliği'),
('Hüseyin', 'Demir',     'huseyin.demir@agu.edu.tr',  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026008', 'İşletme'),
('Selin',   'Özkan',     'selin.ozkan@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026009', 'Yazılım Mühendisliği'),
('Burak',   'Aydın',     'burak.aydin@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026010', 'Bilgisayar Mühendisliği'),
('Elif',    'Güneş',     'elif.gunes@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026011', 'Elektrik-Elektronik Mühendisliği'),
('Kaan',    'Çetin',     'kaan.cetin@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026012', 'Yazılım Mühendisliği'),
('Merve',   'Kılıç',     'merve.kilic@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026013', 'İşletme'),
('Osman',   'Yıldırım',  'osman.yildirim@agu.edu.tr', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026014', 'Bilgisayar Mühendisliği'),
('Nur',     'Aksu',      'nur.aksu@agu.edu.tr',       '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026015', 'Yazılım Mühendisliği'),
('Tarık',   'Eren',      'tarik.eren@agu.edu.tr',     '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026016', 'Endüstri Mühendisliği'),
('Pınar',   'Güler',     'pinar.guler@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026017', 'Endüstri Mühendisliği'),
('Serkan',  'Doğan',     'serkan.dogan@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026018', 'Elektrik-Elektronik Mühendisliği'),
('Büşra',   'Tekin',     'busra.tekin@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026019', 'Yazılım Mühendisliği'),
('Furkan',  'Aksoy',     'furkan.aksoy@agu.edu.tr',   '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026020', 'Bilgisayar Mühendisliği'),
('İrem',    'Yalçın',    'irem.yalcin@agu.edu.tr',    '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i', 'STUDENT', 'S2026021', 'İşletme')
ON CONFLICT (email) DO NOTHING;

-- ─── Drop old wrong-schema tables ────────────────────────────
DROP TABLE IF EXISTS cafeteria_menus    CASCADE;
DROP TABLE IF EXISTS events             CASCADE;
DROP TABLE IF EXISTS announcements      CASCADE;
DROP TABLE IF EXISTS courses            CASCADE;

-- ─── Create correct tables ────────────────────────────────────
CREATE TABLE courses (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(20)  NOT NULL UNIQUE,
    name          VARCHAR(200) NOT NULL,
    description   TEXT,
    credits       INTEGER      NOT NULL DEFAULT 3,
    department    VARCHAR(100),
    teacher_id    BIGINT REFERENCES users(id) ON DELETE SET NULL,
    capacity      INTEGER   DEFAULT 30,
    semester      VARCHAR(20),
    academic_year VARCHAR(10),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE enrollments (
    id          BIGSERIAL PRIMARY KEY,
    student_id  BIGINT NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    course_id   BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade       VARCHAR(5),
    status      VARCHAR(20) DEFAULT 'ACTIVE'
                CHECK (status IN ('ACTIVE','DROPPED','COMPLETED')),
    UNIQUE (student_id, course_id)
);

CREATE TABLE schedule (
    id          BIGSERIAL PRIMARY KEY,
    course_id   BIGINT      NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    day_of_week VARCHAR(10) NOT NULL
                CHECK (day_of_week IN ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY')),
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL,
    classroom   VARCHAR(50),
    building    VARCHAR(100)
);

CREATE TABLE announcements (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(300) NOT NULL,
    content     TEXT         NOT NULL,
    author_id   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    target_role VARCHAR(20)  CHECK (target_role IN ('STUDENT','TEACHER','OFFICE','ALL')),
    is_active   BOOLEAN   DEFAULT TRUE,
    is_pinned   BOOLEAN   DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at  TIMESTAMP
);

CREATE TABLE events (
    id             BIGSERIAL PRIMARY KEY,
    title          VARCHAR(300) NOT NULL,
    description    TEXT,
    location       VARCHAR(200),
    start_datetime TIMESTAMP,
    end_datetime   TIMESTAMP,
    organizer_id   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    event_type     VARCHAR(50),
    is_active      BOOLEAN   DEFAULT TRUE,
    capacity       INTEGER   DEFAULT 100,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_participants (
    id        BIGSERIAL PRIMARY KEY,
    event_id  BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id   BIGINT NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (event_id, user_id)
);

CREATE TABLE cafeteria_menu (
    id         BIGSERIAL PRIMARY KEY,
    date       DATE        NOT NULL,
    meal_type  VARCHAR(20) NOT NULL CHECK (meal_type IN ('BREAKFAST','LUNCH','DINNER')),
    items      JSONB,
    calories   INTEGER,
    price      DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (date, meal_type)
);

CREATE TABLE notifications (
    id             BIGSERIAL PRIMARY KEY,
    user_id        BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title          VARCHAR(300) NOT NULL,
    body           TEXT         NOT NULL,
    type           VARCHAR(50),
    is_read        BOOLEAN   DEFAULT FALSE,
    reference_id   BIGINT,
    reference_type VARCHAR(50),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS device_tokens (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token  TEXT   NOT NULL,
    platform   VARCHAR(20) DEFAULT 'ANDROID',
    updated_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (fcm_token)
);

-- ─── Indexes ──────────────────────────────────────────────────
CREATE INDEX idx_courses_teacher      ON courses(teacher_id);
CREATE INDEX idx_enrollments_student  ON enrollments(student_id);
CREATE INDEX idx_enrollments_course   ON enrollments(course_id);
CREATE INDEX idx_schedule_course      ON schedule(course_id);
CREATE INDEX idx_announcements_active ON announcements(is_active);
CREATE INDEX idx_announcements_role   ON announcements(target_role);
CREATE INDEX idx_events_start         ON events(start_datetime);
CREATE INDEX idx_cafeteria_date       ON cafeteria_menu(date);
CREATE INDEX idx_notifications_user   ON notifications(user_id);

-- ─── Views ───────────────────────────────────────────────────
CREATE OR REPLACE VIEW student_transcript AS
SELECT e.student_id,
       u.first_name || ' ' || u.last_name AS student_name,
       u.student_id                        AS student_number,
       c.code                              AS course_code,
       c.name                              AS course_name,
       c.credits,
       c.department,
       c.semester,
       c.academic_year,
       e.grade,
       e.grade                             AS letter_grade,
       e.status                            AS enrollment_status,
       e.enrolled_at
FROM enrollments e
JOIN users   u ON u.id = e.student_id
JOIN courses c ON c.id = e.course_id
WHERE u.role = 'STUDENT';

CREATE OR REPLACE VIEW teacher_courses AS
SELECT c.id                                 AS course_id,
       c.teacher_id,
       t.first_name || ' ' || t.last_name  AS teacher_name,
       c.code                               AS course_code,
       c.name                               AS course_name,
       c.credits,
       c.department,
       c.capacity,
       c.semester,
       c.academic_year,
       COUNT(e.id) FILTER (WHERE e.status = 'ACTIVE') AS enrolled_count,
       c.capacity - COUNT(e.id) FILTER (WHERE e.status = 'ACTIVE') AS available_seats
FROM courses c
JOIN users t ON t.id = c.teacher_id
LEFT JOIN enrollments e ON e.course_id = c.id
WHERE t.role = 'TEACHER'
GROUP BY c.id, t.first_name, t.last_name;

CREATE OR REPLACE VIEW recent_announcements AS
SELECT a.id, a.title, a.content, a.target_role, a.is_pinned,
       a.created_at, a.expires_at,
       u.first_name || ' ' || u.last_name AS author_name
FROM announcements a
LEFT JOIN users u ON u.id = a.author_id
WHERE a.is_active = TRUE
  AND (a.expires_at IS NULL OR a.expires_at > CURRENT_TIMESTAMP)
  AND a.created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY a.is_pinned DESC, a.created_at DESC;

CREATE OR REPLACE VIEW upcoming_events AS
SELECT e.id, e.title, e.description, e.location,
       e.start_datetime, e.end_datetime, e.event_type, e.capacity,
       u.first_name || ' ' || u.last_name AS organizer_name
FROM events e
LEFT JOIN users u ON u.id = e.organizer_id
WHERE e.is_active = TRUE
  AND e.start_datetime BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '30 days'
ORDER BY e.start_datetime ASC;

-- ─── Trigger: enrollment → notification ──────────────────────
CREATE OR REPLACE FUNCTION fn_notify_on_enrollment()
RETURNS TRIGGER AS $$
DECLARE v_name TEXT; v_code TEXT;
BEGIN
    SELECT name, code INTO v_name, v_code FROM courses WHERE id = NEW.course_id;
    INSERT INTO notifications (user_id, title, body, type, is_read, reference_id, reference_type)
    VALUES (NEW.student_id, 'Ders Kaydı Onaylandı',
            v_name || ' (' || v_code || ') dersine kaydoldunuz.',
            'ENROLLMENT', FALSE, NEW.id, 'ENROLLMENT');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enrollment_notification ON enrollments;
CREATE TRIGGER trg_enrollment_notification
    AFTER INSERT ON enrollments
    FOR EACH ROW EXECUTE FUNCTION fn_notify_on_enrollment();

-- ─── Courses (16) ────────────────────────────────────────────
INSERT INTO courses (code, name, description, credits, department, teacher_id, capacity, semester, academic_year) VALUES
('BIL101', 'Programlamaya Giriş',              'Temel programlama: Python ve algoritmik düşünme',             3, 'Yazılım Mühendisliği',                  (SELECT id FROM users WHERE email='ahmet@agu.edu.tr'),           35, 'Güz',   '2025-2026'),
('BIL102', 'Programlama Dilleri',              'C, C++, Python karşılaştırmalı inceleme',                     3, 'Yazılım Mühendisliği',                  (SELECT id FROM users WHERE email='ayse.demir@agu.edu.tr'),      35, 'Bahar', '2025-2026'),
('BIL201', 'Veri Yapıları ve Algoritmalar',    'Linked list, tree, graph ve temel algoritmalar',              4, 'Yazılım Mühendisliği',                  (SELECT id FROM users WHERE email='ahmet@agu.edu.tr'),           30, 'Bahar', '2025-2026'),
('BIL202', 'Nesne Yönelimli Programlama',      'Java ile OOP: encapsulation, inheritance, polymorphism',      3, 'Yazılım Mühendisliği',                  (SELECT id FROM users WHERE email='ayse.demir@agu.edu.tr'),      35, 'Bahar', '2025-2026'),
('MAT101', 'Matematik I',                      'Analitik geometri, limit ve türev',                           4, 'Matematik',                             (SELECT id FROM users WHERE email='mehmet.kaya@agu.edu.tr'),     50, 'Güz',   '2025-2026'),
('MAT102', 'Matematik II',                     'İntegral, diferansiyel denklemler',                           4, 'Matematik',                             (SELECT id FROM users WHERE email='mehmet.kaya@agu.edu.tr'),     50, 'Bahar', '2025-2026'),
('FIZ101', 'Fizik I',                          'Mekanik, Newton yasaları, enerji',                            4, 'Fizik',                                 (SELECT id FROM users WHERE email='fatma.celik@agu.edu.tr'),     45, 'Güz',   '2025-2026'),
('FIZ102', 'Fizik II',                         'Elektrik, manyetizma, dalgalar',                              4, 'Fizik',                                 (SELECT id FROM users WHERE email='fatma.celik@agu.edu.tr'),     45, 'Bahar', '2025-2026'),
('ING101', 'İngilizce I',                      'Temel İngilizce dil becerileri',                              2, 'Yabancı Diller',                        (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   30, 'Güz',   '2025-2026'),
('ING102', 'İngilizce II',                     'Orta düzey: akademik yazım ve konuşma',                       2, 'Yabancı Diller',                        (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   30, 'Bahar', '2025-2026'),
('IST101', 'İstatistik',                       'Olasılık ve istatistiksel analizler',                         3, 'Matematik',                             (SELECT id FROM users WHERE email='fatma.celik@agu.edu.tr'),     40, 'Bahar', '2025-2026'),
('TUR101', 'Türk Dili I',                      'Dil bilgisi ve yazılı anlatım',                               2, 'Türk Dili',                             (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   60, 'Güz',   '2025-2026'),
('TUR102', 'Türk Dili II',                     'Akademik yazım ve sözlü anlatım',                             2, 'Türk Dili',                             (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   60, 'Bahar', '2025-2026'),
('AIIT101','Atatürk İlkeleri ve İnkılap Tarihi I',  'Osmanlı dönemi ve Kurtuluş Savaşı',                2, 'Atatürk İlkeleri',                      (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   60, 'Güz',   '2025-2026'),
('AIIT102','Atatürk İlkeleri ve İnkılap Tarihi II', 'Kemalist ilkeler ve Cumhuriyetin gelişimi',        2, 'Atatürk İlkeleri',                      (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'),   60, 'Bahar', '2025-2026'),
('IKT101', 'İktisat',                          'Mikro ve makroekonomi temelleri',                             3, 'İşletme',                               (SELECT id FROM users WHERE email='ayse.demir@agu.edu.tr'),      45, 'Güz',   '2025-2026')
ON CONFLICT (code) DO NOTHING;

-- ─── Schedule ─────────────────────────────────────────────────
INSERT INTO schedule (course_id, day_of_week, start_time, end_time, classroom, building) VALUES
((SELECT id FROM courses WHERE code='BIL101'),  'MONDAY',    '09:00', '10:50', 'A101', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='BIL102'),  'TUESDAY',   '09:00', '10:50', 'A102', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='BIL201'),  'WEDNESDAY', '09:00', '10:50', 'B201', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='BIL202'),  'THURSDAY',  '09:00', '10:50', 'B202', 'Mühendislik Fakültesi'),
((SELECT id FROM courses WHERE code='MAT101'),  'MONDAY',    '11:00', '12:50', 'C101', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='MAT102'),  'TUESDAY',   '11:00', '12:50', 'C102', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='FIZ101'),  'WEDNESDAY', '11:00', '12:50', 'D101', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='FIZ102'),  'THURSDAY',  '11:00', '12:50', 'D102', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='ING101'),  'FRIDAY',    '09:00', '10:50', 'E101', 'Yabancı Diller MYO'),
((SELECT id FROM courses WHERE code='ING102'),  'MONDAY',    '13:00', '14:50', 'E102', 'Yabancı Diller MYO'),
((SELECT id FROM courses WHERE code='IST101'),  'TUESDAY',   '13:00', '14:50', 'C103', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='TUR101'),  'WEDNESDAY', '13:00', '14:50', 'F101', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='TUR102'),  'THURSDAY',  '13:00', '14:50', 'F102', 'Fen-Edebiyat Fakültesi'),
((SELECT id FROM courses WHERE code='AIIT101'), 'FRIDAY',    '11:00', '12:50', 'G101', 'Merkez Bina'),
((SELECT id FROM courses WHERE code='AIIT102'), 'MONDAY',    '15:00', '16:50', 'G102', 'Merkez Bina'),
((SELECT id FROM courses WHERE code='IKT101'),  'TUESDAY',   '15:00', '16:50', 'H101', 'İktisadi ve İdari Bilimler');

-- ─── Enrollments: Bengü (id=1) — trigger auto-creates notifications ──
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
(1, (SELECT id FROM courses WHERE code='BIL101'),  'BB',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='MAT101'),  'CB',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='FIZ101'),  'CB',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='ING101'),  'AA',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='TUR101'),  'AA',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='AIIT101'), 'BA',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='IKT101'),  'BB',   'COMPLETED'),
(1, (SELECT id FROM courses WHERE code='BIL201'),  NULL,   'ACTIVE'),
(1, (SELECT id FROM courses WHERE code='MAT102'),  NULL,   'ACTIVE'),
(1, (SELECT id FROM courses WHERE code='FIZ102'),  NULL,   'ACTIVE'),
(1, (SELECT id FROM courses WHERE code='ING102'),  NULL,   'ACTIVE'),
(1, (SELECT id FROM courses WHERE code='TUR102'),  NULL,   'ACTIVE'),
(1, (SELECT id FROM courses WHERE code='AIIT102'), NULL,   'ACTIVE')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ─── Enrollments: Other students (teacher panel demo) ─────────
INSERT INTO enrollments (student_id, course_id, grade, status) VALUES
-- Ali Kaya → BIL101, BIL201, MAT101, ING101
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL101'),  'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='MAT101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='ING101'),  'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='ali.kaya@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Zeynep Arslan
((SELECT id FROM users WHERE email='zeynep.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='zeynep.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='MAT101'),  'CC', 'COMPLETED'),
((SELECT id FROM users WHERE email='zeynep.arslan@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Mehmet Yıldız
((SELECT id FROM users WHERE email='mehmet.yildiz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL101'),  'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='mehmet.yildiz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='mehmet.yildiz@agu.edu.tr'),  (SELECT id FROM courses WHERE code='MAT102'),  NULL, 'ACTIVE'),
-- Emre Çelik
((SELECT id FROM users WHERE email='emre.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL101'),  'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='emre.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='MAT101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='emre.celik@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Ayşe Koca
((SELECT id FROM users WHERE email='ayse.koca@agu.edu.tr'),      (SELECT id FROM courses WHERE code='BIL101'),  'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='ayse.koca@agu.edu.tr'),      (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Selin Özkan
((SELECT id FROM users WHERE email='selin.ozkan@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='selin.ozkan@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Kaan Çetin
((SELECT id FROM users WHERE email='kaan.cetin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL101'),  'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='kaan.cetin@agu.edu.tr'),     (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Büşra Tekin
((SELECT id FROM users WHERE email='busra.tekin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='busra.tekin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Nur Aksu → BIL101
((SELECT id FROM users WHERE email='nur.aksu@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL101'),  'AA', 'COMPLETED'),
((SELECT id FROM users WHERE email='nur.aksu@agu.edu.tr'),       (SELECT id FROM courses WHERE code='BIL201'),  NULL, 'ACTIVE'),
-- Furkan Aksoy → BIL101
((SELECT id FROM users WHERE email='furkan.aksoy@agu.edu.tr'),   (SELECT id FROM courses WHERE code='BIL101'),  'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='furkan.aksoy@agu.edu.tr'),   (SELECT id FROM courses WHERE code='MAT101'),  'CC', 'COMPLETED'),
-- MAT101 extras (Mehmet Kaya's course)
((SELECT id FROM users WHERE email='fatma.sahin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='MAT101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='huseyin.demir@agu.edu.tr'),  (SELECT id FROM courses WHERE code='MAT101'),  'CC', 'COMPLETED'),
((SELECT id FROM users WHERE email='elif.gunes@agu.edu.tr'),     (SELECT id FROM courses WHERE code='MAT101'),  'CB', 'COMPLETED'),
((SELECT id FROM users WHERE email='tarik.eren@agu.edu.tr'),     (SELECT id FROM courses WHERE code='MAT101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='pinar.guler@agu.edu.tr'),    (SELECT id FROM courses WHERE code='MAT102'),  NULL, 'ACTIVE'),
((SELECT id FROM users WHERE email='serkan.dogan@agu.edu.tr'),   (SELECT id FROM courses WHERE code='FIZ101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='merve.kilic@agu.edu.tr'),    (SELECT id FROM courses WHERE code='IKT101'),  'BA', 'COMPLETED'),
((SELECT id FROM users WHERE email='irem.yalcin@agu.edu.tr'),    (SELECT id FROM courses WHERE code='IKT101'),  'BB', 'COMPLETED'),
((SELECT id FROM users WHERE email='osman.yildirim@agu.edu.tr'), (SELECT id FROM courses WHERE code='BIL101'),  'DD', 'COMPLETED')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- ─── Announcements (10) ───────────────────────────────────────
INSERT INTO announcements (title, content, author_id, target_role, is_active, is_pinned, created_at) VALUES
('2025-2026 Bahar Yarıyılı Kayıt Tarihleri',
 'Bahar yarıyılı ders kayıtları 10-15 Ocak 2026 arasında yapılacaktır. Kayıt öncesi danışmanınızla görüşün.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'ALL', TRUE, TRUE,  NOW() - INTERVAL '25 days'),

('Kütüphane Uzatılmış Çalışma Saatleri',
 'Final dönemine özel: hafta içi 07:00-24:00, hafta sonu 09:00-22:00.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'ALL', TRUE, FALSE, NOW() - INTERVAL '20 days'),

('2026 Burs Başvuruları Başladı',
 'Akademik başarı bursu başvuruları açıldı. Son tarih: 30 Haziran 2026. Burs Birimi''ni ziyaret edin.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'STUDENT', TRUE, TRUE,  NOW() - INTERVAL '15 days'),

('Kampüs Otoparkı Bakım Çalışması',
 '2-5 Haziran 2026 tarihleri arasında B blok otoparkı kapalı. Alternatif: A ve C otoparklar.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'ALL', TRUE, FALSE, NOW() - INTERVAL '10 days'),

('Erasmus+ 2026-2027 Başvuruları Açıldı',
 'Erasmus+ değişim programı başvuruları açıldı. Detay için Uluslararası İlişkiler Ofisi''ni ziyaret edin.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '5 days'),

('BIL201 Dönem Projesi Konuları',
 'Veri Yapıları dönem projesi konuları güncellendi. Grup başvuruları Cuma gününe kadar yapılmalıdır.',
 (SELECT id FROM users WHERE email='ahmet@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '18 days'),

('MAT102 Ara Sınav Tarihi Değişti',
 'Matematik II ara sınavı 15 Haziran''a ertelendi. Yer: C-101 Amfisi.',
 (SELECT id FROM users WHERE email='mehmet.kaya@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '12 days'),

('Fizik Laboratuvar Raporu Formatı',
 'Fizik lab raporları yeni formata göre hazırlanmalı. Şablon öğrenci sistemine yüklendi. İlk teslim: 6 Haziran.',
 (SELECT id FROM users WHERE email='fatma.celik@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '8 days'),

('İngilizce Hazırlık Programı 2026-2027',
 'Yeni yıl hazırlık kaydı başladı. Seviye belirleme sınavı 20 Haziran''da. Yabancı Diller MYO''ya başvurun.',
 (SELECT id FROM users WHERE email='mustafa.sahin@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '3 days'),

('Dönem Sonu Görüşme Saatleri',
 'Tüm öğretim üyeleri dönem sonu için 2 saat ek görüşme saati ekleyecektir. Randevu için öğretmeninizle iletişime geçin.',
 (SELECT id FROM users WHERE email='ahmet@agu.edu.tr'), 'STUDENT', TRUE, FALSE, NOW() - INTERVAL '1 day');

-- ─── Events (5) ──────────────────────────────────────────────
INSERT INTO events (title, description, location, start_datetime, end_datetime, organizer_id, event_type, is_active, capacity) VALUES
('Kariyer Günleri 2026',
 '60+ şirketle yüz yüze tanışma, staj ve iş fırsatları için katılın!',
 'Kongre ve Kültür Merkezi',
 '2026-06-02 09:00:00', '2026-06-02 17:00:00',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'CAREER', TRUE, 400),

('Bahar Spor Şenliği',
 'Fakülteler arası futbol, basketbol ve voleybol turnuvaları.',
 'Kampüs Spor Tesisleri',
 '2026-06-05 10:00:00', '2026-06-07 18:00:00',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'SPORTS', TRUE, 500),

('Yapay Zeka Sempozyumu',
 'LLM, robotik ve otonom sistemler üzerine akademisyen ve sektör sunumları. Sertifika verilecektir.',
 'Mühendislik Fakültesi A-101',
 '2026-06-10 09:00:00', '2026-06-10 18:00:00',
 (SELECT id FROM users WHERE email='ahmet@agu.edu.tr'), 'ACADEMIC', TRUE, 200),

('Mezuniyet Töreni 2025-2026',
 'Mezunlarımız ailelerini de davet ederek diplomalarını alacak.',
 'Büyük Amfi Tiyatro',
 '2026-06-25 14:00:00', '2026-06-25 18:00:00',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'CEREMONY', TRUE, 800),

('24 Saatlik Yazılım Hackathonu',
 'Bireysel veya 3 kişilik takım. Toplam ödül: 10.000 TL. Kayıt: Öğrenci İşleri.',
 'Bilgisayar Lab Blok B — B201',
 '2026-06-14 18:00:00', '2026-06-15 18:00:00',
 (SELECT id FROM users WHERE email='ayse.demir@agu.edu.tr'), 'TECH', TRUE, 90);

-- ─── Cafeteria menu — current week 26-30 May 2026 ─────────────
INSERT INTO cafeteria_menu (date, meal_type, items, calories, price) VALUES
-- Pazartesi 26 Mayıs
('2026-05-26','BREAKFAST','[{"name":"Menemen","calories":220},{"name":"Beyaz Peynir","calories":80},{"name":"Zeytin","calories":60},{"name":"Çay","calories":5}]',365,10.00),
('2026-05-26','LUNCH','[{"name":"Mercimek Çorbası","calories":150},{"name":"Tavuk Izgara","calories":280},{"name":"Bulgur Pilavı","calories":200},{"name":"Mevsim Salatası","calories":45},{"name":"Ayran","calories":60}]',735,25.00),
('2026-05-26','DINNER','[{"name":"Domates Çorbası","calories":120},{"name":"Köfte","calories":300},{"name":"Makarna","calories":250},{"name":"Yoğurt","calories":60}]',730,20.00),
-- Salı 27 Mayıs
('2026-05-27','BREAKFAST','[{"name":"Omlet","calories":250},{"name":"Kaşar Peyniri","calories":90},{"name":"Domates","calories":20},{"name":"Çay","calories":5}]',365,10.00),
('2026-05-27','LUNCH','[{"name":"Ezogelin Çorbası","calories":160},{"name":"Etli Nohut","calories":320},{"name":"Pilav","calories":200},{"name":"Komposto","calories":80}]',760,25.00),
('2026-05-27','DINNER','[{"name":"Yayla Çorbası","calories":130},{"name":"Fırın Tavuk","calories":280},{"name":"Bulgur","calories":180},{"name":"Cacık","calories":60}]',650,20.00),
-- Çarşamba 28 Mayıs
('2026-05-28','BREAKFAST','[{"name":"Sahanda Yumurta","calories":200},{"name":"Tulum Peyniri","calories":100},{"name":"Bal","calories":60},{"name":"Çay","calories":5}]',365,10.00),
('2026-05-28','LUNCH','[{"name":"Tarhana Çorbası","calories":140},{"name":"Kuru Fasulye","calories":300},{"name":"Pirinç Pilavı","calories":200},{"name":"Turşu","calories":20}]',660,25.00),
('2026-05-28','DINNER','[{"name":"Şehriye Çorbası","calories":110},{"name":"Sebzeli Güveç","calories":260},{"name":"Makarna","calories":250},{"name":"Meyve","calories":70}]',690,20.00),
-- Perşembe 29 Mayıs
('2026-05-29','BREAKFAST','[{"name":"Peynirli Börek","calories":280},{"name":"Zeytin","calories":60},{"name":"Domates","calories":20},{"name":"Çay","calories":5}]',365,10.00),
('2026-05-29','LUNCH','[{"name":"Soğan Çorbası","calories":120},{"name":"Izgara Köfte","calories":320},{"name":"Patates Kızartması","calories":300},{"name":"Mevsim Salatası","calories":45}]',785,25.00),
('2026-05-29','DINNER','[{"name":"Mercimek Çorbası","calories":150},{"name":"Tavuk Haşlama","calories":240},{"name":"Pilav","calories":200},{"name":"Ayran","calories":60}]',650,20.00),
-- Cuma 30 Mayıs
('2026-05-30','BREAKFAST','[{"name":"Menemen","calories":220},{"name":"Beyaz Peynir","calories":80},{"name":"Zeytin","calories":60},{"name":"Çay","calories":5}]',365,10.00),
('2026-05-30','LUNCH','[{"name":"Balık Çorbası","calories":130},{"name":"Balık","calories":280},{"name":"Pilav","calories":200},{"name":"Limon","calories":10}]',620,25.00),
('2026-05-30','DINNER','[{"name":"Işkın Çorbası","calories":100},{"name":"Sebzeli Tavuk","calories":280},{"name":"Bulgur","calories":180},{"name":"Yoğurt","calories":60}]',620,20.00)
ON CONFLICT (date, meal_type) DO NOTHING;

-- ─── Extra notifications for Bengü (announcement type) ────────
INSERT INTO notifications (user_id, title, body, type, is_read, reference_type, created_at) VALUES
(1, 'Yeni Duyuru', 'Burs başvuruları başladı! Son tarih 30 Haziran 2026.', 'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '15 days'),
(1, 'Yeni Duyuru', 'Erasmus+ 2026-2027 başvuruları açıldı!',               'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '5 days'),
(1, 'Yeni Duyuru', 'Kariyer Günleri 2026 — 2 Haziran kayıt başladı.',      'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '2 days'),
(1, 'Sistem Bildirimi', 'Dönem sonu notlarınız güncellendi. Transkriptinizi inceleyebilirsiniz.', 'SYSTEM', TRUE, 'SYSTEM', NOW() - INTERVAL '7 days'),
(1, 'Hatırlatma', 'Güz dönemi not itiraz süresi bu hafta sona eriyor.', 'REMINDER', FALSE, 'SYSTEM', NOW() - INTERVAL '1 day');

COMMIT;
