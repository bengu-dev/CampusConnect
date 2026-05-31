-- Şifreleri doğru bcrypt hash ile güncelle (123456)
UPDATE users
SET password = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM5lDml.bD/fZMZzOi3i'
WHERE email IN (
    'ahmet@agu.edu.tr',
    'bengu@agu.edu.tr',
    'mehmet.kaya@agu.edu.tr',
    'ayse.demir@agu.edu.tr',
    'fatma.celik@agu.edu.tr',
    'mustafa.sahin@agu.edu.tr',
    'ogrenci.isleri@agu.edu.tr'
);

-- Doğrula
SELECT email, LEFT(password, 15) as pwd_prefix FROM users
WHERE email = 'ahmet@agu.edu.tr';
