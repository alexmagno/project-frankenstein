package com.frankenstein.user.application.queries;

import java.util.UUID;

/**
 * Query to get user profile information.
 * Queries represent the intent to read data from the system.
 * They are handled by query handlers that read from optimized read models.
 */
public record GetUserProfileQuery(UUID userId) {
    
    /**
     * Compact constructor for validation.
     */
    public GetUserProfileQuery {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
    }
}
