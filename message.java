package com.example.bot.model;

public class Message {
    private String from;
    private String text;
    private String activationCode;
    
    public Message() {}
    
    public Message(String from, String text, String activationCode) {
        this.from = from;
        this.text = text;
        this.activationCode = activationCode;
    }
    public String getFrom() {
        return from;
    }
    
    public void setFrom(String from) {
        this.from = from;
    }
    
    public String getText() {
        return text;
    }
    
    public void setText(String text) {
        this.text = text;
    }
    
    public String getActivationCode() {
        return activationCode;
    }
    
    public void setActivationCode(String activationCode) {
        this.activationCode = activationCode;
    }
}
