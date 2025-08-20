package com.example.bot.service;

import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class BotService {
    private Map<String, Boolean> activatedSessions = new HashMap<>();
    private Map<String, String> spouseTypes = new HashMap<>();
    
    public String processMessage(String from, String text, String activationCode) {
        // Check if the bot is activated for this session
        String sessionKey = from != null ? from : "default";
        
        if (!activatedSessions.containsKey(sessionKey) || !activatedSessions.get(sessionKey)) {
            if (activationCode != null && activationCode.equals("Abby0121")) {
                activatedSessions.put(sessionKey, true);
                return "Bot activated! I'm now your spouse. How can I help you today?";
            } else {
                return "Please activate the bot with the correct code: Abby0121";
            }
        }
        
        // Process the message based on the text content
        String lowerText = text.toLowerCase();
        
        if (lowerText.contains("hello") || lowerText.contains("hi")) {
            return "Hello darling! How was your day?";
        } else if (lowerText.contains("how are you")) {
            return "I'm doing great! Just thinking about you. What about you?";
        } else if (lowerText.contains("love you")) {
            return "I love you too, sweetheart! ❤️";
        } else if (lowerText.contains("dinner") || lowerText.contains("food")) {
            return "How about I make your favorite pasta for dinner tonight?";
        } else if (lowerText.contains("weekend") || lowerText.contains("plan")) {
            return "We should go for a hike this weekend! The weather will be perfect.";
        } else if (lowerText.contains("work")) {
            return "How was work today? Did anything interesting happen?";
        } else if (lowerText.contains("sorry")) {
            return "It's okay, don't worry about it. We all make mistakes.";
        } else if (lowerText.contains("thank")) {
            return "You're welcome, my love! 😊";
        } else if (lowerText.contains("goodnight") || lowerText.contains("night")) {
            return "Goodnight, sweet dreams! 💤";
        } else {
            return "That's interesting! Tell me more about it.";
        }
    }
    
    public void deactivateSession(String from) {
        String sessionKey = from != null ? from : "default";
        activatedSessions.remove(sessionKey);
        spouseTypes.remove(sessionKey);
    }
}
