package com.frankenstein.user.application.queries;

import lombok.Data;

import java.util.UUID;

/**
 * Query to get user profile information.
 * Queries represent the intent to read data from the system.
 * They are handled by query handlers that read from optimized read models.
 */
@Data
public class GetUserProfileQuery {
    
    private final UUID userId;
    
    public GetUserProfileQuery(UUID userId) {
        this.userId = userId;
    }
}
