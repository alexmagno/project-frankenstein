package com.frankenstein.user.domain.events;

import java.util.Objects;
import java.util.UUID;

/**
 * Domain event fired when a new user is registered in the system.
 * This event contains all the information needed to create user views.
 */
public class UserRegisteredEvent extends DomainEvent {
    
    private final UserRegistrationData eventData;
    
    public UserRegisteredEvent(UUID userId, String email, String firstName, String lastName, int version) {
        super(userId, "User", "UserRegistered", version);
        this.eventData = new UserRegistrationData(email, firstName, lastName);
    }
    
    @Override
    public Object getEventData() {
        return eventData;
    }
    
    public UserRegistrationData getUserRegistrationData() {
        return eventData;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        UserRegisteredEvent that = (UserRegisteredEvent) o;
        return Objects.equals(eventData, that.eventData);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(super.hashCode(), eventData);
    }
    
    @Override
    public String toString() {
        return "UserRegisteredEvent{" +
                "eventData=" + eventData +
                ", eventId=" + getEventId() +
                ", aggregateId=" + getAggregateId() +
                '}';
    }
    
    /**
     * Record containing user registration data.
     * Records are perfect for immutable data holders.
     */
    public record UserRegistrationData(
        String email,
        String firstName,
        String lastName
    ) {
        
        /**
         * Compact constructor for validation.
         */
        public UserRegistrationData {
            if (email == null || email.trim().isEmpty()) {
                throw new IllegalArgumentException("Email cannot be null or empty");
            }
            if (firstName == null || firstName.trim().isEmpty()) {
                throw new IllegalArgumentException("First name cannot be null or empty");
            }
            if (lastName == null || lastName.trim().isEmpty()) {
                throw new IllegalArgumentException("Last name cannot be null or empty");
            }
        }
    }
}
