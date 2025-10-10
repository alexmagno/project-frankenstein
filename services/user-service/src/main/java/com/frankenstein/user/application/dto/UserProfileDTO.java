package com.frankenstein.user.application.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * DTO for user profile information optimized for API responses.
 * Records are perfect for DTOs - immutable, concise, and JSON-friendly.
 */
public record UserProfileDTO(
    UUID id,
    String email,
    String firstName,
    String lastName,
    String fullName,
    String phoneNumber,
    String address,
    boolean isActive,
    boolean isEmailVerified,
    List<String> roles,
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt,
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime lastLoginAt,
    
    UserStatisticsDTO statistics
) {
    
    /**
     * Compact constructor for validation and computed fields.
     */
    public UserProfileDTO {
        // Computed field: full name
        if (fullName == null && firstName != null && lastName != null) {
            fullName = firstName + " " + lastName;
        }
        
        // Ensure collections are never null
        if (roles == null) {
            roles = List.of();
        }
        
        // Validation
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
    }
    
    /**
     * Factory method for basic user profile.
     */
    public static UserProfileDTO basic(UUID id, String email, String firstName, String lastName) {
        return new UserProfileDTO(
            id,
            email,
            firstName,
            lastName,
            null, // will be computed in constructor
            null,
            null,
            true,
            false,
            List.of("USER"),
            LocalDateTime.now(),
            null,
            new UserStatisticsDTO(0, 0, 0)
        );
    }
    
    /**
     * Create a summary version with limited information.
     */
    public UserSummaryDTO toSummary() {
        return new UserSummaryDTO(id, fullName, email, isActive);
    }
    
    /**
     * Nested record for user statistics.
     */
    public record UserStatisticsDTO(
        int totalOrders,
        int totalSpent,
        int loyaltyPoints
    ) {}
    
    /**
     * Nested record for user summary.
     */
    public record UserSummaryDTO(
        UUID id,
        String fullName,
        String email,
        boolean isActive
    ) {}
}
