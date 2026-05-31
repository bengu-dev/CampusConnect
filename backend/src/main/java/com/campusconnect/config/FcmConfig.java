package com.campusconnect.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import javax.annotation.PostConstruct;
import java.io.IOException;

/**
 * Firebase Admin SDK başlatma.
 *
 * KURULUM:
 *  1. Firebase Console → Proje Ayarları → Hizmet Hesapları → JSON oluştur
 *  2. Dosyayı: backend/src/main/resources/firebase-service-account.json olarak kaydet
 *  3. .gitignore'a ekle! (hassas bilgi içerir)
 *
 * Dosya yoksa FCM özellikleri devre dışı kalır, uygulama çalışmaya devam eder.
 */
@Slf4j
@Configuration
public class FcmConfig {

    @Value("${firebase.service-account-path:#{null}}")
    private Resource serviceAccountResource;

    @PostConstruct
    public void initFirebase() {
        if (FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty()) return;

        if (serviceAccountResource == null || !serviceAccountResource.exists()) {
            log.warn("FCM: firebase-service-account.json bulunamadı — push bildirimler devre dışı.");
            return;
        }

        try {
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccountResource.getInputStream()))
                .build();
            FirebaseApp.initializeApp(options);
            log.info("FCM: Firebase Admin SDK başarıyla başlatıldı.");
        } catch (IOException e) {
            log.error("FCM başlatma hatası: {}", e.getMessage());
        }
    }
}
