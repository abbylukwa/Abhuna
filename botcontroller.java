package com.example.bot.controller;

import com.example.bot.model.Message;
import com.example.bot.service.BotService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/bot")
public class BotController {
    
    @Autowired
    private BotService botService;
    
    @PostMapping("/message")
    public String handleMessage(@RequestBody Message message) {
        return botService.processMessage(
            message.getFrom(), 
            message.getText(), 
            message.getActivationCode()
        );
    }
    
    @PostMapping("/deactivate")
    public String deactivate(@RequestParam String from) {
        botService.deactivateSession(from);
        return "Bot deactivated for session: " + from;
    }
    
    @GetMapping("/status")
    public String status() {
        return "WhatsApp Spouse Bot is running! Use activation code: Abby0121";
    }
}
