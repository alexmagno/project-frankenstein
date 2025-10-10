package com.frankenstein.user.infrastructure.java21;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * Java 21 String Templates examples for safer and more readable string interpolation.
 * String Templates provide type-safe string interpolation and prevent injection attacks.
 */
public class StringTemplatesExample {

    // Note: String Templates are in Preview in Java 21, will be finalized in later versions
    // This example shows the intended usage and benefits

    /**
     * Traditional string concatenation vs String Templates.
     * String Templates are safer and more readable.
     */
    public void demonstrateStringTemplates() {
        String userEmail = "john.doe@example.com";
        UUID userId = UUID.randomUUID();
        LocalDateTime timestamp = LocalDateTime.now();
        
        // Traditional way (prone to errors, hard to read)
        String traditionalMessage = "User " + userId + " with email " + userEmail + 
            " registered at " + timestamp.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        
        // String Templates way (Java 21 Preview)
        // Note: Actual syntax may vary as this is still in preview
        /*
        String templateMessage = STR."User \{userId} with email \{userEmail} registered at \{timestamp.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)}";
        */
        
        // For now, we'll use String.format() as a bridge until String Templates are stable
        String formattedMessage = "User %s with email %s registered at %s".formatted(
            userId, 
            userEmail, 
            timestamp.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        );
        
        System.out.println("Traditional: " + traditionalMessage);
        System.out.println("Formatted: " + formattedMessage);
    }

    /**
     * Safe SQL query construction using String Templates principles.
     * Prevents SQL injection by design.
     */
    public String buildSafeUserQuery(String email, boolean isActive) {
        // Using formatted strings as a safe alternative until String Templates are stable
        return """
            SELECT u.id, u.email, u.first_name, u.last_name, u.created_at
            FROM user_domain.users u
            WHERE u.email = '%s' 
            AND u.is_active = %s
            ORDER BY u.created_at DESC
            """.formatted(
                sanitizeForSql(email),  // Always sanitize inputs
                isActive
            );
    }

    /**
     * Email template generation using safer string composition.
     * Demonstrates how String Templates will improve email generation.
     */
    public record WelcomeEmailData(
        String firstName,
        String lastName,
        String email,
        String activationLink,
        LocalDateTime registrationTime
    ) {}

    public String generateWelcomeEmail(WelcomeEmailData data) {
        String formattedDate = data.registrationTime()
            .format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' HH:mm"));
            
        // Using text blocks with formatted strings (Java 21 compatible)
        return """
            Dear %s %s,
            
            Welcome to Project Frankenstein! 
            
            Your account has been created successfully with the email address: %s
            Registration completed on: %s
            
            To activate your account, please click the link below:
            %s
            
            If you didn't create this account, please ignore this email.
            
            Best regards,
            The Frankenstein Team
            """.formatted(
                data.firstName(),
                data.lastName(),
                data.email(),
                formattedDate,
                data.activationLink()
            );
    }

    /**
     * JSON generation with safe interpolation.
     * Shows how String Templates will improve API response generation.
     */
    public record UserApiResponse(
        UUID id,
        String email,
        String fullName,
        boolean isActive,
        LocalDateTime lastLogin
    ) {}

    public String generateJsonResponse(UserApiResponse user) {
        String lastLoginStr = user.lastLogin() != null 
            ? user.lastLogin().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
            : null;
            
        // Safe JSON generation (in real scenarios, use Jackson)
        return """
            {
                "id": "%s",
                "email": "%s",
                "fullName": "%s",
                "isActive": %s,
                "lastLogin": %s,
                "timestamp": "%s"
            }""".formatted(
                user.id(),
                escapeJsonString(user.email()),
                escapeJsonString(user.fullName()),
                user.isActive(),
                lastLoginStr != null ? "\"" + lastLoginStr + "\"" : "null",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
            );
    }

    /**
     * Logging message generation with structured format.
     * String Templates will make logging safer and more readable.
     */
    public void logUserActions(UUID userId, String action, String details, String ipAddress) {
        // Structured logging format
        String logMessage = """
            [USER_ACTION] userId=%s action=%s ip=%s timestamp=%s details=%s
            """.formatted(
                userId,
                sanitizeLogValue(action),
                sanitizeLogValue(ipAddress),
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                sanitizeLogValue(details)
            ).trim();
            
        System.out.println(logMessage);
    }

    /**
     * Configuration message generation.
     * Shows how String Templates improve configuration and error messages.
     */
    public String generateConfigurationMessage(String serviceName, String environment, int port) {
        return """
            🚀 %s Service Started Successfully
            ════════════════════════════════════
            Environment: %s
            Port: %d
            Timestamp: %s
            Health Check: http://localhost:%d/actuator/health
            API Docs: http://localhost:%d/swagger-ui.html
            ════════════════════════════════════
            """.formatted(
                serviceName,
                environment.toUpperCase(),
                port,
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")),
                port,
                port
            );
    }

    // Utility methods for safe string handling
    private String sanitizeForSql(String input) {
        return input != null ? input.replace("'", "''") : "";
    }

    private String escapeJsonString(String input) {
        if (input == null) return "";
        return input
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }

    private String sanitizeLogValue(String input) {
        if (input == null) return "null";
        // Remove line breaks and limit length to prevent log injection
        return input
            .replace("\n", " ")
            .replace("\r", " ")
            .replace("\t", " ")
            .substring(0, Math.min(input.length(), 100));
    }
}
