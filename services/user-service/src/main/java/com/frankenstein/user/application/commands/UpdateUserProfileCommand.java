package com.frankenstein.user.application.commands;

import java.util.UUID;

/**
 * Command to update user profile information.
 * Demonstrates the power of Java records for immutable command objects.
 */
public record UpdateUserProfileCommand(
    UUID userId,
    String firstName,
    String lastName,
    String phoneNumber,
    String address
) {
    
    /**
     * Compact constructor for validation.
     * Records allow validation logic directly in the constructor.
     */
    public UpdateUserProfileCommand {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        if (firstName != null && firstName.trim().isEmpty()) {
            throw new IllegalArgumentException("First name cannot be empty");
        }
        if (lastName != null && lastName.trim().isEmpty()) {
            throw new IllegalArgumentException("Last name cannot be empty");
        }
    }
    
    /**
     * Factory method for partial updates with only required fields.
     */
    public static UpdateUserProfileCommand updateName(UUID userId, String firstName, String lastName) {
        return new UpdateUserProfileCommand(userId, firstName, lastName, null, null);
    }
    
    /**
     * Check if this command contains any actual updates.
     */
    public boolean hasUpdates() {
        return firstName != null || lastName != null || phoneNumber != null || address != null;
    }
}
