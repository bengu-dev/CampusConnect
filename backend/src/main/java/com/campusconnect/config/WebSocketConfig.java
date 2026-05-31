package com.campusconnect.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Flutter native WebSocket bağlantısı için
        registry.addEndpoint("/ws")
            .setAllowedOriginPatterns("*");

        // Web tarayıcı / SockJS fallback için
        registry.addEndpoint("/ws-sockjs")
            .setAllowedOriginPatterns("*")
            .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Sunucu → istemci yayın kanalları
        registry.enableSimpleBroker("/topic", "/queue");
        // İstemci → sunucu mesaj öneki
        registry.setApplicationDestinationPrefixes("/app");
    }
}
