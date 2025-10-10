package com.frankenstein.user.infrastructure.java21;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Java 21 Pattern Matching examples for the User Service.
 * Demonstrates the enhanced pattern matching capabilities in Java 21.
 */
public class PatternMatchingExamples {

    // Example sealed interface for user events (Java 21)
    public sealed interface UserEvent 
        permits UserRegistered, UserUpdated, UserDeactivated {
        UUID userId();
        LocalDateTime timestamp();
    }

    public record UserRegistered(
        UUID userId, 
        String email, 
        LocalDateTime timestamp
    ) implements UserEvent {}

    public record UserUpdated(
        UUID userId, 
        String field, 
        String oldValue, 
        String newValue, 
        LocalDateTime timestamp
    ) implements UserEvent {}

    public record UserDeactivated(
        UUID userId, 
        String reason, 
        LocalDateTime timestamp
    ) implements UserEvent {}

    /**
     * Enhanced switch expression with pattern matching (Java 21).
     * Much cleaner than traditional instanceof chains.
     */
    public String formatUserEvent(UserEvent event) {
        return switch (event) {
            case UserRegistered(var userId, var email, var timestamp) ->
                "User %s registered with email %s at %s".formatted(userId, email, timestamp);
                
            case UserUpdated(var userId, var field, var oldValue, var newValue, var timestamp) ->
                "User %s updated %s from '%s' to '%s' at %s".formatted(
                    userId, field, oldValue, newValue, timestamp);
                    
            case UserDeactivated(var userId, var reason, var timestamp) ->
                "User %s deactivated due to '%s' at %s".formatted(userId, reason, timestamp);
        };
    }

    /**
     * Pattern matching with guards (Java 21).
     * Allows additional conditions in pattern matching.
     */
    public String categorizeUser(UserEvent event) {
        return switch (event) {
            case UserRegistered(var userId, var email, var timestamp) 
                when email.endsWith("@company.com") -> "Internal user registered";
                
            case UserRegistered(var userId, var email, var timestamp) -> "External user registered";
            
            case UserUpdated(var userId, var field, var oldValue, var newValue, var timestamp)
                when "email".equals(field) -> "Critical update: email changed";
                
            case UserUpdated(var userId, var field, var oldValue, var newValue, var timestamp) -> 
                "Standard update: " + field + " changed";
                
            case UserDeactivated(var userId, var reason, var timestamp)
                when "security".equals(reason) -> "Security deactivation";
                
            case UserDeactivated(var userId, var reason, var timestamp) -> "Standard deactivation";
        };
    }

    /**
     * Pattern matching with complex records.
     * Shows deconstructor patterns with nested records.
     */
    public record UserProfile(UUID id, String name, ContactInfo contactInfo) {}
    public record ContactInfo(String email, String phone, Address address) {}
    public record Address(String street, String city, String country) {}

    public String extractUserLocation(UserProfile profile) {
        return switch (profile) {
            case UserProfile(var id, var name, ContactInfo(var email, var phone, 
                           Address(var street, var city, var country))) -> 
                "User %s lives in %s, %s".formatted(name, city, country);
        };
    }

    /**
     * Null-safe pattern matching (Java 21).
     * Handles null values elegantly in pattern matching.
     */
    public String safeFormatEvent(UserEvent event) {
        return switch (event) {
            case null -> "No event provided";
            case UserRegistered(var userId, var email, var timestamp) -> 
                "Registration: " + (email != null ? email : "no email");
            case UserUpdated(var userId, var field, var oldValue, var newValue, var timestamp) ->
                "Update: " + (field != null ? field : "unknown field");
            case UserDeactivated(var userId, var reason, var timestamp) ->
                "Deactivation: " + (reason != null ? reason : "no reason given");
        };
    }
}
