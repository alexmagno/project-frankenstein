package com.frankenstein.user.domain.events;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.UUID;

/**
 * Domain event fired when a new user is registered in the system.
 * This event contains all the information needed to create user views.
 */
@Data
@EqualsAndHashCode(callSuper = true)
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
    
    @Data
    public static class UserRegistrationData {
        private final String email;
        private final String firstName;
        private final String lastName;
    }
}
