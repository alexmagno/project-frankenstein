package com.frankenstein.user.application.commands;

import lombok.Data;

import java.util.UUID;

/**
 * Command to register a new user in the system.
 * Commands represent the intent to change the system state.
 * They are handled by command handlers that interact with aggregates.
 */
@Data
public class RegisterUserCommand {
    
    private final UUID userId;
    private final String email;
    private final String firstName;
    private final String lastName;
    private final String password;
    
    public RegisterUserCommand(String email, String firstName, String lastName, String password) {
        this.userId = UUID.randomUUID(); // Generate new ID for registration
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
    }
}
