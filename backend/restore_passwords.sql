-- Ahmet ve Bengü'nün orijinal şifrelerini geri yükle
UPDATE users SET password = '$2a$10$XVj60jLrS9/rCYjg1kHvWua7Rf.HYQD6ZM3Oi4dkkdGS1OfuWltme' WHERE email='ahmet@agu.edu.tr';
UPDATE users SET password = '$2a$10$4GsGo.bgKSATwz1OJ7pKUu2vmk50SRsUP8bIJ/5cTa6MDnrBbQq1.' WHERE email='bengu@agu.edu.tr';
SELECT email, LEFT(password,20) as pwd_prefix FROM users WHERE email IN ('ahmet@agu.edu.tr','bengu@agu.edu.tr');
