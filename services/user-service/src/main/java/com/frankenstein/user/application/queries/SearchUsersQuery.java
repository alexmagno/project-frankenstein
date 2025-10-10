package com.frankenstein.user.application.queries;

import java.time.LocalDate;
import java.util.Optional;

/**
 * Query to search users with various filters.
 * Demonstrates Java records with optional parameters and validation.
 */
public record SearchUsersQuery(
    Optional<String> emailPattern,
    Optional<String> firstName,
    Optional<String> lastName,
    Optional<LocalDate> registeredAfter,
    Optional<LocalDate> registeredBefore,
    Optional<Boolean> isActive,
    int page,
    int size
) {
    
    /**
     * Compact constructor with validation and defaults.
     */
    public SearchUsersQuery {
        if (page < 0) {
            throw new IllegalArgumentException("Page cannot be negative");
        }
        if (size <= 0 || size > 100) {
            throw new IllegalArgumentException("Size must be between 1 and 100");
        }
        
        // Ensure Optional fields are never null
        emailPattern = Optional.ofNullable(emailPattern).orElse(Optional.empty());
        firstName = Optional.ofNullable(firstName).orElse(Optional.empty());
        lastName = Optional.ofNullable(lastName).orElse(Optional.empty());
        registeredAfter = Optional.ofNullable(registeredAfter).orElse(Optional.empty());
        registeredBefore = Optional.ofNullable(registeredBefore).orElse(Optional.empty());
        isActive = Optional.ofNullable(isActive).orElse(Optional.empty());
    }
    
    /**
     * Factory method for simple email search.
     */
    public static SearchUsersQuery byEmail(String emailPattern) {
        return new SearchUsersQuery(
            Optional.of(emailPattern),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            0,
            20
        );
    }
    
    /**
     * Factory method for simple name search.
     */
    public static SearchUsersQuery byName(String firstName, String lastName) {
        return new SearchUsersQuery(
            Optional.empty(),
            Optional.ofNullable(firstName),
            Optional.ofNullable(lastName),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            0,
            20
        );
    }
    
    /**
     * Factory method for paginated search without filters.
     */
    public static SearchUsersQuery all(int page, int size) {
        return new SearchUsersQuery(
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            Optional.empty(),
            page,
            size
        );
    }
    
    /**
     * Check if this query has any active filters.
     */
    public boolean hasFilters() {
        return emailPattern.isPresent() ||
               firstName.isPresent() || 
               lastName.isPresent() ||
               registeredAfter.isPresent() ||
               registeredBefore.isPresent() ||
               isActive.isPresent();
    }
}
