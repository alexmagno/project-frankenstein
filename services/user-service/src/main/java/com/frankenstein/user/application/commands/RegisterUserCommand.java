package com.frankenstein.user.application.commands;

import java.util.UUID;

/**
 * Command to register a new user in the system.
 * Commands represent the intent to change the system state.
 * They are handled by command handlers that interact with aggregates.
 */
public record RegisterUserCommand(
    UUID userId,
    String email,
    String firstName,
    String lastName,
    String password
) {
    
    /**
     * Factory method to create a RegisterUserCommand with auto-generated user ID.
     */
    public static RegisterUserCommand create(String email, String firstName, String lastName, String password) {
        return new RegisterUserCommand(
            UUID.randomUUID(), // Generate new ID for registration
            email,
            firstName,
            lastName,
            password
        );
    }
    
    /**
     * Custom toString to protect sensitive password information.
     */
    @Override
    public String toString() {
        return "RegisterUserCommand{" +
                "userId=" + userId +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", password='[PROTECTED]'" +
                '}';
    }
}
