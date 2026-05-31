-- CampusConnect — Türkçe Karakter Düzeltme
-- Bu dosya docker cp ile container'a kopyalanıp psql -f ile çalıştırılır
BEGIN;

-- ─── USERS: İsim ve departman düzeltme ───────────────────────
UPDATE users SET first_name='Bengü',   last_name='Gedik',    department='Yazılım Mühendisliği'       WHERE email='bengu@agu.edu.tr';
UPDATE users SET first_name='Ahmet',   last_name='Yılmaz',   department='Yazılım Mühendisliği'       WHERE email='ahmet@agu.edu.tr';
UPDATE users SET first_name='Mehmet',  last_name='Kaya',     department='Matematik'                  WHERE email='mehmet.kaya@agu.edu.tr';
UPDATE users SET first_name='Ayşe',    last_name='Demir',    department='Yazılım Mühendisliği'       WHERE email='ayse.demir@agu.edu.tr';
UPDATE users SET first_name='Fatma',   last_name='Çelik',    department='Fizik'                      WHERE email='fatma.celik@agu.edu.tr';
UPDATE users SET first_name='Mustafa', last_name='Şahin',    department='Yabancı Diller'             WHERE email='mustafa.sahin@agu.edu.tr';
UPDATE users SET first_name='Öğrenci', last_name='İşleri',   department='Öğrenci İşleri', position='Müdür' WHERE email='ogrenci.isleri@agu.edu.tr';
UPDATE users SET first_name='Ali',     last_name='Kaya',     department='Yazılım Mühendisliği'       WHERE email='ali.kaya@agu.edu.tr';
UPDATE users SET first_name='Zeynep',  last_name='Arslan',   department='Bilgisayar Mühendisliği'    WHERE email='zeynep.arslan@agu.edu.tr';
UPDATE users SET first_name='Mehmet',  last_name='Yıldız',   department='Yazılım Mühendisliği'       WHERE email='mehmet.yildiz@agu.edu.tr';
UPDATE users SET first_name='Fatma',   last_name='Şahin',    department='Elektrik-Elektronik Mühendisliği' WHERE email='fatma.sahin@agu.edu.tr';
UPDATE users SET first_name='Emre',    last_name='Çelik',    department='Bilgisayar Mühendisliği'    WHERE email='emre.celik@agu.edu.tr';
UPDATE users SET first_name='Ayşe',    last_name='Koca',     department='Yazılım Mühendisliği'       WHERE email='ayse.koca@agu.edu.tr';
UPDATE users SET first_name='Hüseyin', last_name='Demir',    department='İşletme'                    WHERE email='huseyin.demir@agu.edu.tr';
UPDATE users SET first_name='Selin',   last_name='Özkan',    department='Yazılım Mühendisliği'       WHERE email='selin.ozkan@agu.edu.tr';
UPDATE users SET first_name='Burak',   last_name='Aydın',    department='Bilgisayar Mühendisliği'    WHERE email='burak.aydin@agu.edu.tr';
UPDATE users SET first_name='Elif',    last_name='Güneş',    department='Elektrik-Elektronik Mühendisliği' WHERE email='elif.gunes@agu.edu.tr';
UPDATE users SET first_name='Kaan',    last_name='Çetin',    department='Yazılım Mühendisliği'       WHERE email='kaan.cetin@agu.edu.tr';
UPDATE users SET first_name='Merve',   last_name='Kılıç',    department='İşletme'                    WHERE email='merve.kilic@agu.edu.tr';
UPDATE users SET first_name='Osman',   last_name='Yıldırım', department='Bilgisayar Mühendisliği'    WHERE email='osman.yildirim@agu.edu.tr';
UPDATE users SET first_name='Nur',     last_name='Aksu',     department='Yazılım Mühendisliği'       WHERE email='nur.aksu@agu.edu.tr';
UPDATE users SET first_name='Tarık',   last_name='Eren',     department='Endüstri Mühendisliği'      WHERE email='tarik.eren@agu.edu.tr';
UPDATE users SET first_name='Pınar',   last_name='Güler',    department='Endüstri Mühendisliği'      WHERE email='pinar.guler@agu.edu.tr';
UPDATE users SET first_name='Serkan',  last_name='Doğan',    department='Elektrik-Elektronik Mühendisliği' WHERE email='serkan.dogan@agu.edu.tr';
UPDATE users SET first_name='Büşra',   last_name='Tekin',    department='Yazılım Mühendisliği'       WHERE email='busra.tekin@agu.edu.tr';
UPDATE users SET first_name='Furkan',  last_name='Aksoy',    department='Bilgisayar Mühendisliği'    WHERE email='furkan.aksoy@agu.edu.tr';
UPDATE users SET first_name='İrem',    last_name='Yalçın',   department='İşletme'                    WHERE email='irem.yalcin@agu.edu.tr';

-- ─── COURSES: Ad ve departman düzeltme ───────────────────────
UPDATE courses SET name='Programlamaya Giriş',
    description='Temel programlama: Python ve algoritmik düşünme',
    department='Yazılım Mühendisliği'       WHERE code='BIL101';
UPDATE courses SET name='Programlama Dilleri',
    description='C, C++, Python karşılaştırmalı inceleme',
    department='Yazılım Mühendisliği'       WHERE code='BIL102';
UPDATE courses SET name='Veri Yapıları ve Algoritmalar',
    description='Linked list, tree, graph ve temel algoritmalar',
    department='Yazılım Mühendisliği'       WHERE code='BIL201';
UPDATE courses SET name='Nesne Yönelimli Programlama',
    description='Java ile OOP: encapsulation, inheritance, polymorphism',
    department='Yazılım Mühendisliği'       WHERE code='BIL202';
UPDATE courses SET name='Matematik I',
    description='Analitik geometri, limit ve türev',
    department='Matematik'                  WHERE code='MAT101';
UPDATE courses SET name='Matematik II',
    description='İntegral, diferansiyel denklemler',
    department='Matematik'                  WHERE code='MAT102';
UPDATE courses SET name='Fizik I',
    description='Mekanik, Newton yasaları, enerji',
    department='Fizik'                      WHERE code='FIZ101';
UPDATE courses SET name='Fizik II',
    description='Elektrik, manyetizma, dalgalar',
    department='Fizik'                      WHERE code='FIZ102';
UPDATE courses SET name='İngilizce I',
    description='Temel İngilizce dil becerileri',
    department='Yabancı Diller'             WHERE code='ING101';
UPDATE courses SET name='İngilizce II',
    description='Orta düzey: akademik yazım ve konuşma',
    department='Yabancı Diller'             WHERE code='ING102';
UPDATE courses SET name='İstatistik',
    description='Olasılık ve istatistiksel analizler',
    department='Matematik'                  WHERE code='IST101';
UPDATE courses SET name='Türk Dili I',
    description='Dil bilgisi ve yazılı anlatım',
    department='Türk Dili'                  WHERE code='TUR101';
UPDATE courses SET name='Türk Dili II',
    description='Akademik yazım ve sözlü anlatım',
    department='Türk Dili'                  WHERE code='TUR102';
UPDATE courses SET name='Atatürk İlkeleri ve İnkılap Tarihi I',
    description='Osmanlı dönemi ve Kurtuluş Savaşı',
    department='Atatürk İlkeleri'           WHERE code='AIIT101';
UPDATE courses SET name='Atatürk İlkeleri ve İnkılap Tarihi II',
    description='Kemalist ilkeler ve Cumhuriyetin gelişimi',
    department='Atatürk İlkeleri'           WHERE code='AIIT102';
UPDATE courses SET name='İktisat',
    description='Mikro ve makroekonomi temelleri',
    department='İşletme'                    WHERE code='IKT101';

-- ─── SCHEDULE: Building adlarını düzelt ──────────────────────
UPDATE schedule SET building='Mühendislik Fakültesi'          WHERE building LIKE '%hendislik%' OR building LIKE '%M??hendislik%';
UPDATE schedule SET building='Fen-Edebiyat Fakültesi'         WHERE building LIKE '%Fen%' OR building LIKE '%Edebiyat%';
UPDATE schedule SET building='Yabancı Diller MYO'             WHERE building LIKE '%Yabanc%';
UPDATE schedule SET building='Merkez Bina'                    WHERE building='Merkez Bina';
UPDATE schedule SET building='İktisadi ve İdari Bilimler'     WHERE building LIKE '%ktisat%' OR building LIKE '%ktisadi%';

-- ─── ANNOUNCEMENTS: Sil ve yeniden ekle ─────────────────────
DELETE FROM announcements;

INSERT INTO announcements (title, content, author_id, target_role, is_active, is_pinned, created_at) VALUES
('2025-2026 Bahar Yarıyılı Kayıt Tarihleri',
 'Bahar yarıyılı ders kayıtları 10-15 Ocak 2026 arasında yapılacaktır. Kayıt öncesi danışmanınızla görüşün.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'ALL', TRUE, TRUE, NOW() - INTERVAL '25 days'),
('Kütüphane Uzatılmış Çalışma Saatleri',
 'Final dönemine özel: hafta içi 07:00-24:00, hafta sonu 09:00-22:00.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'ALL', TRUE, FALSE, NOW() - INTERVAL '20 days'),
('2026 Burs Başvuruları Başladı',
 'Akademik başarı bursu başvuruları açıldı. Son tarih: 30 Haziran 2026. Burs Birimi''ni ziyaret edin.',
 (SELECT id FROM users WHERE email='ogrenci.isleri@agu.edu.tr'), 'STUDENT', TRUE, TRUE, NOW() - INTERVAL '15 days'),
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

-- ─── EVENTS: Sil ve yeniden ekle ─────────────────────────────
DELETE FROM event_participants;
DELETE FROM events;

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

-- ─── CAFETERIA MENU: Items JSONB düzelt ──────────────────────
UPDATE cafeteria_menu SET items='[{"name":"Menemen","calories":220},{"name":"Beyaz Peynir","calories":80},{"name":"Zeytin","calories":60},{"name":"Çay","calories":5}]'::jsonb WHERE date='2026-05-26' AND meal_type='BREAKFAST';
UPDATE cafeteria_menu SET items='[{"name":"Mercimek Çorbası","calories":150},{"name":"Tavuk Izgara","calories":280},{"name":"Bulgur Pilavı","calories":200},{"name":"Mevsim Salatası","calories":45},{"name":"Ayran","calories":60}]'::jsonb WHERE date='2026-05-26' AND meal_type='LUNCH';
UPDATE cafeteria_menu SET items='[{"name":"Domates Çorbası","calories":120},{"name":"Köfte","calories":300},{"name":"Makarna","calories":250},{"name":"Yoğurt","calories":60}]'::jsonb WHERE date='2026-05-26' AND meal_type='DINNER';
UPDATE cafeteria_menu SET items='[{"name":"Omlet","calories":250},{"name":"Kaşar Peyniri","calories":90},{"name":"Domates","calories":20},{"name":"Çay","calories":5}]'::jsonb WHERE date='2026-05-27' AND meal_type='BREAKFAST';
UPDATE cafeteria_menu SET items='[{"name":"Ezogelin Çorbası","calories":160},{"name":"Etli Nohut","calories":320},{"name":"Pilav","calories":200},{"name":"Komposto","calories":80}]'::jsonb WHERE date='2026-05-27' AND meal_type='LUNCH';
UPDATE cafeteria_menu SET items='[{"name":"Yayla Çorbası","calories":130},{"name":"Fırın Tavuk","calories":280},{"name":"Bulgur","calories":180},{"name":"Cacık","calories":60}]'::jsonb WHERE date='2026-05-27' AND meal_type='DINNER';
UPDATE cafeteria_menu SET items='[{"name":"Sahanda Yumurta","calories":200},{"name":"Tulum Peyniri","calories":100},{"name":"Bal","calories":60},{"name":"Çay","calories":5}]'::jsonb WHERE date='2026-05-28' AND meal_type='BREAKFAST';
UPDATE cafeteria_menu SET items='[{"name":"Tarhana Çorbası","calories":140},{"name":"Kuru Fasulye","calories":300},{"name":"Pirinç Pilavı","calories":200},{"name":"Turşu","calories":20}]'::jsonb WHERE date='2026-05-28' AND meal_type='LUNCH';
UPDATE cafeteria_menu SET items='[{"name":"Şehriye Çorbası","calories":110},{"name":"Sebzeli Güveç","calories":260},{"name":"Makarna","calories":250},{"name":"Meyve","calories":70}]'::jsonb WHERE date='2026-05-28' AND meal_type='DINNER';
UPDATE cafeteria_menu SET items='[{"name":"Peynirli Börek","calories":280},{"name":"Zeytin","calories":60},{"name":"Domates","calories":20},{"name":"Çay","calories":5}]'::jsonb WHERE date='2026-05-29' AND meal_type='BREAKFAST';
UPDATE cafeteria_menu SET items='[{"name":"Soğan Çorbası","calories":120},{"name":"Izgara Köfte","calories":320},{"name":"Patates Kızartması","calories":300},{"name":"Mevsim Salatası","calories":45}]'::jsonb WHERE date='2026-05-29' AND meal_type='LUNCH';
UPDATE cafeteria_menu SET items='[{"name":"Mercimek Çorbası","calories":150},{"name":"Tavuk Haşlama","calories":240},{"name":"Pilav","calories":200},{"name":"Ayran","calories":60}]'::jsonb WHERE date='2026-05-29' AND meal_type='DINNER';
UPDATE cafeteria_menu SET items='[{"name":"Menemen","calories":220},{"name":"Beyaz Peynir","calories":80},{"name":"Zeytin","calories":60},{"name":"Çay","calories":5}]'::jsonb WHERE date='2026-05-30' AND meal_type='BREAKFAST';
UPDATE cafeteria_menu SET items='[{"name":"Balık Çorbası","calories":130},{"name":"Balık","calories":280},{"name":"Pilav","calories":200},{"name":"Limon","calories":10}]'::jsonb WHERE date='2026-05-30' AND meal_type='LUNCH';
UPDATE cafeteria_menu SET items='[{"name":"Işkın Çorbası","calories":100},{"name":"Sebzeli Tavuk","calories":280},{"name":"Bulgur","calories":180},{"name":"Yoğurt","calories":60}]'::jsonb WHERE date='2026-05-30' AND meal_type='DINNER';

-- ─── NOTIFICATIONS: Enrollment olanları courses'tan yeniden oluştur ──
UPDATE notifications SET title='Ders Kaydı Onaylandı' WHERE type='ENROLLMENT';
UPDATE notifications n
SET body = c.name || ' (' || c.code || ') dersine kaydoldunuz.'
FROM enrollments e
JOIN courses c ON c.id = e.course_id
WHERE n.reference_id = e.id AND n.type = 'ENROLLMENT';

-- Manuel eklenen bildirimleri düzelt (ANNOUNCEMENT/SYSTEM/REMINDER)
DELETE FROM notifications WHERE user_id=1 AND type IN ('ANNOUNCEMENT','SYSTEM','REMINDER');
INSERT INTO notifications (user_id, title, body, type, is_read, reference_type, created_at) VALUES
(1, 'Yeni Duyuru', 'Burs başvuruları başladı! Son tarih 30 Haziran 2026.',         'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '15 days'),
(1, 'Yeni Duyuru', 'Erasmus+ 2026-2027 başvuruları açıldı!',                       'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '5 days'),
(1, 'Yeni Duyuru', 'Kariyer Günleri 2026 — 2 Haziran kayıt başladı.',              'ANNOUNCEMENT', FALSE, 'ANNOUNCEMENT', NOW() - INTERVAL '2 days'),
(1, 'Sistem Bildirimi', 'Dönem sonu notlarınız güncellendi. Transkriptinizi inceleyebilirsiniz.', 'SYSTEM', TRUE, 'SYSTEM', NOW() - INTERVAL '7 days'),
(1, 'Hatırlatma',  'Güz dönemi not itiraz süresi bu hafta sona eriyor.',           'REMINDER', FALSE, 'SYSTEM', NOW() - INTERVAL '1 day');

-- ─── Tüm bildirimleri okunmamış yap (demo için) ───────────────
UPDATE notifications SET is_read = FALSE WHERE user_id = 1;

COMMIT;
