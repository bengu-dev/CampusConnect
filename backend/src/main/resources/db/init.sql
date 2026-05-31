-- CampusConnect Database Schema — Week 1 Lock
-- Bu dosya Docker container ilk başlatıldığında otomatik çalışır.
-- Tablo değişiklikleri için migration script'i kullanın.

-- ─────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL PRIMARY KEY,
    first_name  VARCHAR(100)  NOT NULL,
    last_name   VARCHAR(100)  NOT NULL,
    email       VARCHAR(255)  NOT NULL UNIQUE,
    password    VARCHAR(255)  NOT NULL,
    role        VARCHAR(20)   NOT NULL CHECK (role IN ('STUDENT', 'TEACHER', 'OFFICE')),
    student_id  VARCHAR(50),
    staff_id    VARCHAR(50),
    employee_id VARCHAR(50),
    department  VARCHAR(100),
    position    VARCHAR(100),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- COURSES
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(20)  NOT NULL UNIQUE,
    name          VARCHAR(200) NOT NULL,
    description   TEXT,
    credits       INTEGER      NOT NULL DEFAULT 3,
    department    VARCHAR(100),
    teacher_id    BIGINT REFERENCES users(id) ON DELETE SET NULL,
    capacity      INTEGER      DEFAULT 30,
    semester      VARCHAR(20),
    academic_year VARCHAR(10),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- ENROLLMENTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS enrollments (
    id          BIGSERIAL PRIMARY KEY,
    student_id  BIGINT    NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    course_id   BIGINT    NOT NULL REFERENCES courses(id)  ON DELETE CASCADE,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade       VARCHAR(5),
    status      VARCHAR(20) DEFAULT 'ACTIVE'
                            CHECK (status IN ('ACTIVE', 'DROPPED', 'COMPLETED')),
    UNIQUE (student_id, course_id)
);

-- ─────────────────────────────────────────────
-- SCHEDULE
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS schedule (
    id           BIGSERIAL PRIMARY KEY,
    course_id    BIGINT      NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    day_of_week  VARCHAR(10) NOT NULL
                             CHECK (day_of_week IN ('MONDAY','TUESDAY','WEDNESDAY',
                                                    'THURSDAY','FRIDAY','SATURDAY')),
    start_time   TIME        NOT NULL,
    end_time     TIME        NOT NULL,
    room         VARCHAR(50),
    building     VARCHAR(100)
);

-- ─────────────────────────────────────────────
-- ANNOUNCEMENTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(300) NOT NULL,
    content     TEXT         NOT NULL,
    author_id   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    target_role VARCHAR(20)  CHECK (target_role IN ('STUDENT','TEACHER','OFFICE','ALL')),
    is_active   BOOLEAN   DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at  TIMESTAMP
);

-- ─────────────────────────────────────────────
-- EVENTS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
    id             BIGSERIAL PRIMARY KEY,
    title          VARCHAR(300) NOT NULL,
    description    TEXT,
    location       VARCHAR(200),
    start_datetime TIMESTAMP    NOT NULL,
    end_datetime   TIMESTAMP,
    organizer_id   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    event_type     VARCHAR(50),
    is_active      BOOLEAN   DEFAULT TRUE,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- CAFETERIA MENU
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cafeteria_menu (
    id         BIGSERIAL PRIMARY KEY,
    menu_date  DATE        NOT NULL,
    meal_type  VARCHAR(20) NOT NULL
               CHECK (meal_type IN ('BREAKFAST', 'LUNCH', 'DINNER')),
    items      JSONB,
    calories   INTEGER,
    price      DECIMAL(6, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (menu_date, meal_type)
);

-- ─────────────────────────────────────────────
-- NOTIFICATIONS
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
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

-- ─────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────

-- users
CREATE INDEX IF NOT EXISTS idx_users_email      ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role       ON users(role);

-- courses
CREATE INDEX IF NOT EXISTS idx_courses_teacher    ON courses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_department ON courses(department);
CREATE INDEX IF NOT EXISTS idx_courses_semester   ON courses(semester, academic_year);

-- enrollments
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course  ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status  ON enrollments(status);

-- schedule
CREATE INDEX IF NOT EXISTS idx_schedule_course ON schedule(course_id);
CREATE INDEX IF NOT EXISTS idx_schedule_day    ON schedule(day_of_week);

-- announcements
CREATE INDEX IF NOT EXISTS idx_announcements_role   ON announcements(target_role);
CREATE INDEX IF NOT EXISTS idx_announcements_active ON announcements(is_active);
CREATE INDEX IF NOT EXISTS idx_announcements_date   ON announcements(created_at DESC);

-- events
CREATE INDEX IF NOT EXISTS idx_events_start    ON events(start_datetime);
CREATE INDEX IF NOT EXISTS idx_events_active   ON events(is_active);
CREATE INDEX IF NOT EXISTS idx_events_type     ON events(event_type);

-- cafeteria_menu
CREATE INDEX IF NOT EXISTS idx_cafeteria_date      ON cafeteria_menu(menu_date);
CREATE INDEX IF NOT EXISTS idx_cafeteria_meal_type ON cafeteria_menu(menu_date, meal_type);

-- notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user    ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread  ON notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

-- ─────────────────────────────────────────────
-- VIEWS
-- ─────────────────────────────────────────────

-- Öğrencinin aldığı tüm dersler ve notları (transkript)
CREATE OR REPLACE VIEW student_transcript AS
SELECT
    e.student_id,
    u.first_name || ' ' || u.last_name  AS student_name,
    u.student_id                         AS student_number,
    c.code                               AS course_code,
    c.name                               AS course_name,
    c.credits,
    c.department,
    c.semester,
    c.academic_year,
    e.grade,
    e.status                             AS enrollment_status,
    e.enrolled_at
FROM enrollments e
JOIN users    u ON u.id = e.student_id
JOIN courses  c ON c.id = e.course_id
WHERE u.role = 'STUDENT';

-- Öğrencinin haftalık ders programı
CREATE OR REPLACE VIEW student_schedule AS
SELECT
    e.student_id,
    u.first_name || ' ' || u.last_name  AS student_name,
    c.code                               AS course_code,
    c.name                               AS course_name,
    t.first_name || ' ' || t.last_name  AS teacher_name,
    s.day_of_week,
    s.start_time,
    s.end_time,
    s.room,
    s.building
FROM enrollments e
JOIN users    u  ON u.id  = e.student_id
JOIN courses  c  ON c.id  = e.course_id
JOIN schedule s  ON s.course_id = c.id
LEFT JOIN users t ON t.id = c.teacher_id
WHERE u.role = 'STUDENT'
  AND e.status = 'ACTIVE'
ORDER BY s.day_of_week, s.start_time;

-- Öğretmenin verdiği dersler ve kayıtlı öğrenci sayısı
CREATE OR REPLACE VIEW teacher_courses AS
SELECT
    c.id                                  AS course_id,
    c.teacher_id,
    t.first_name || ' ' || t.last_name   AS teacher_name,
    c.code                                AS course_code,
    c.name                                AS course_name,
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

-- Son 30 günün aktif duyuruları (en yeni önce)
CREATE OR REPLACE VIEW recent_announcements AS
SELECT
    a.id,
    a.title,
    a.content,
    a.target_role,
    a.created_at,
    a.expires_at,
    u.first_name || ' ' || u.last_name AS author_name
FROM announcements a
LEFT JOIN users u ON u.id = a.author_id
WHERE a.is_active = TRUE
  AND (a.expires_at IS NULL OR a.expires_at > CURRENT_TIMESTAMP)
  AND a.created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY a.created_at DESC;

-- Yaklaşan etkinlikler (gelecek 30 gün)
CREATE OR REPLACE VIEW upcoming_events AS
SELECT
    e.id,
    e.title,
    e.description,
    e.location,
    e.start_datetime,
    e.end_datetime,
    e.event_type,
    u.first_name || ' ' || u.last_name AS organizer_name,
    e.start_datetime - CURRENT_TIMESTAMP AS time_until_event
FROM events e
LEFT JOIN users u ON u.id = e.organizer_id
WHERE e.is_active = TRUE
  AND e.start_datetime BETWEEN CURRENT_TIMESTAMP
                            AND CURRENT_TIMESTAMP + INTERVAL '30 days'
ORDER BY e.start_datetime ASC;

-- Kullanıcı başına okunmamış bildirim sayısı
CREATE OR REPLACE VIEW unread_notification_count AS
SELECT
    n.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    u.role,
    COUNT(*)                            AS unread_count,
    MAX(n.created_at)                   AS latest_notification_at
FROM notifications n
JOIN users u ON u.id = n.user_id
WHERE n.is_read = FALSE
GROUP BY n.user_id, u.first_name, u.last_name, u.role;

-- ─────────────────────────────────────────────
-- TRIGGERS
-- ─────────────────────────────────────────────

-- Trigger Function: Öğrenci bir derse kayıt olduğunda otomatik bildirim oluştur
CREATE OR REPLACE FUNCTION fn_notify_on_enrollment()
RETURNS TRIGGER AS $$
DECLARE
    v_course_name TEXT;
    v_course_code TEXT;
BEGIN
    -- Ders bilgisini al
    SELECT name, code
    INTO v_course_name, v_course_code
    FROM courses
    WHERE id = NEW.course_id;

    -- Öğrenciye bildirim oluştur
    INSERT INTO notifications (
        user_id,
        title,
        body,
        type,
        is_read,
        reference_id,
        reference_type,
        created_at
    ) VALUES (
        NEW.student_id,
        'Ders Kaydı Onaylandı',
        v_course_name || ' (' || v_course_code || ') dersine başarıyla kaydoldunuz.',
        'ENROLLMENT',
        FALSE,
        NEW.id,
        'ENROLLMENT',
        NOW()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: enrollments tablosuna INSERT sonrası tetiklenir
DROP TRIGGER IF EXISTS trg_enrollment_notification ON enrollments;
CREATE TRIGGER trg_enrollment_notification
    AFTER INSERT ON enrollments
    FOR EACH ROW
    EXECUTE FUNCTION fn_notify_on_enrollment();

-- ─────────────────────────────────────────────
-- STORED PROCEDURES
-- ─────────────────────────────────────────────

-- Prosedür: Kullanıcıya ait okunmamış bildirimleri getir VE tek seferde okundu işaretle.
-- Kullanım: SELECT * FROM get_and_mark_notifications(1);
CREATE OR REPLACE FUNCTION get_and_mark_notifications(p_user_id BIGINT)
RETURNS TABLE (
    notif_id       BIGINT,
    notif_title    VARCHAR(300),
    notif_body     TEXT,
    notif_type     VARCHAR(50),
    notif_ref_id   BIGINT,
    notif_ref_type VARCHAR(50),
    notif_at       TIMESTAMP
) AS $$
BEGIN
    -- 1. Okunmamış bildirimleri döndür (en yeni önce)
    RETURN QUERY
        SELECT
            n.id,
            n.title,
            n.body,
            n.type,
            n.reference_id,
            n.reference_type,
            n.created_at
        FROM notifications n
        WHERE n.user_id = p_user_id
          AND n.is_read = FALSE
        ORDER BY n.created_at DESC;

    -- 2. Aynı işlem içinde hepsini okundu olarak işaretle
    UPDATE notifications
    SET    is_read = TRUE
    WHERE  user_id = p_user_id
      AND  is_read = FALSE;
END;
$$ LANGUAGE plpgsql;

-- Yardımcı: Sadece okunmamış bildirim sayısını döndürür (işaretlemez)
CREATE OR REPLACE FUNCTION count_unread_notifications(p_user_id BIGINT)
RETURNS INTEGER AS $$
    SELECT COUNT(*)::INTEGER
    FROM   notifications
    WHERE  user_id = p_user_id
      AND  is_read = FALSE;
$$ LANGUAGE sql STABLE;

-- ─────────────────────────────────────────────
-- YENİ TABLOLAR (Week 3 — Etkinlik + FCM)
-- ─────────────────────────────────────────────

-- events tablosuna capacity sütunu ekle (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'events' AND column_name = 'capacity'
    ) THEN
        ALTER TABLE events ADD COLUMN capacity INTEGER DEFAULT 100;
    END IF;
END $$;

-- Etkinlik katılımcıları
CREATE TABLE IF NOT EXISTS event_participants (
    id         BIGSERIAL PRIMARY KEY,
    event_id   BIGINT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id    BIGINT NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    joined_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_participants_event ON event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_user  ON event_participants(user_id);

-- FCM cihaz token'ları
CREATE TABLE IF NOT EXISTS device_tokens (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token  TEXT      NOT NULL,
    platform   VARCHAR(20) DEFAULT 'ANDROID',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (fcm_token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);

-- ─────────────────────────────────────────────
-- ÖRNEK VERİLER (Etkinlik + Yemek Menüsü)
-- ─────────────────────────────────────────────

-- Günlük yemek menüsü (bugün + 6 gün)
INSERT INTO cafeteria_menu (menu_date, meal_type, items, calories, price) VALUES
  (CURRENT_DATE, 'BREAKFAST',
   '[{"name":"Menemen","calories":220},{"name":"Beyaz Peynir","calories":80},{"name":"Zeytin","calories":60},{"name":"Çay","calories":5}]',
   365, 10.00),
  (CURRENT_DATE, 'LUNCH',
   '[{"name":"Mercimek Çorbası","calories":150},{"name":"Tavuk Izgara","calories":280},{"name":"Bulgur Pilavı","calories":200},{"name":"Mevsim Salatası","calories":45},{"name":"Ayran","calories":60}]',
   735, 25.00),
  (CURRENT_DATE, 'DINNER',
   '[{"name":"Domates Çorbası","calories":120},{"name":"Fırın Köfte","calories":320},{"name":"Makarna","calories":250},{"name":"Cacık","calories":60}]',
   750, 20.00),
  (CURRENT_DATE + 1, 'BREAKFAST',
   '[{"name":"Omlet","calories":250},{"name":"Kaşar Peyniri","calories":90},{"name":"Domates","calories":20},{"name":"Çay","calories":5}]',
   365, 10.00),
  (CURRENT_DATE + 1, 'LUNCH',
   '[{"name":"Ezogelin Çorbası","calories":160},{"name":"Kızartma","calories":350},{"name":"Pirinç Pilavı","calories":220},{"name":"Komposto","calories":80}]',
   810, 25.00),
  (CURRENT_DATE + 1, 'DINNER',
   '[{"name":"Yayla Çorbası","calories":130},{"name":"Etli Güveç","calories":380},{"name":"Makarna","calories":250},{"name":"Yoğurt","calories":80}]',
   840, 20.00),
  (CURRENT_DATE - 1, 'BREAKFAST',
   '[{"name":"Sahanda Yumurta","calories":200},{"name":"Tulum Peyniri","calories":100},{"name":"Bal","calories":60},{"name":"Çay","calories":5}]',
   365, 10.00),
  (CURRENT_DATE - 1, 'LUNCH',
   '[{"name":"Tarhana Çorbası","calories":140},{"name":"Kuru Fasulye","calories":300},{"name":"Pilav","calories":200},{"name":"Cacık","calories":60}]',
   700, 25.00),
  (CURRENT_DATE - 1, 'DINNER',
   '[{"name":"Işkın Çorbası","calories":100},{"name":"Sebzeli Tavuk","calories":280},{"name":"Bulgur","calories":180},{"name":"Meyve","calories":70}]',
   630, 20.00)
ON CONFLICT (menu_date, meal_type) DO NOTHING;

-- Örnek etkinlikler
INSERT INTO events (title, description, location, start_datetime, end_datetime, event_type, is_active, capacity) VALUES
  ('Kariyer Günleri 2025',
   'Sektörün önde gelen firmaları ile yüz yüze tanışma ve staj/iş fırsatı bulma etkinliği.',
   'Kongre ve Kültür Merkezi', NOW() + INTERVAL '7 days', NOW() + INTERVAL '7 days' + INTERVAL '8 hours',
   'CAREER', TRUE, 300),
  ('Bahar Futbol Turnuvası',
   'Fakülteler arası futbol turnuvası. Takımını kayıt ettir, kupayı kap!',
   'Spor Tesisleri — Saha 1', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days' + INTERVAL '5 hours',
   'SPORTS', TRUE, 120),
  ('Yapay Zeka Sempozyumu',
   'Akademisyenler ve sektör temsilcilerinin katılımıyla yapay zeka gelişmeleri tartışılacak.',
   'Mühendislik Fakültesi A-101', NOW() + INTERVAL '14 days', NOW() + INTERVAL '14 days' + INTERVAL '6 hours',
   'ACADEMIC', TRUE, 150),
  ('Mezuniyet Seremonisi',
   '2024-2025 akademik yılı mezunlarının törenle diplomalarını alacağı özel gün.',
   'Büyük Amfi Tiyatro', NOW() + INTERVAL '30 days', NOW() + INTERVAL '30 days' + INTERVAL '3 hours',
   'CEREMONY', TRUE, 500),
  ('Yazılım Geliştirme Hackathon',
   '24 saatlik kod maratonu. Bireysel veya 3 kişilik takım olarak katılabilirsiniz.',
   'Bilgisayar Lab — Blok B', NOW() + INTERVAL '10 days', NOW() + INTERVAL '11 days',
   'TECH', TRUE, 80)
ON CONFLICT DO NOTHING;
