package com.frankenstein.user.domain.events;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * Base interface for all domain events in the system.
 * Events represent something that has happened in the domain.
 */
@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, property = "@type")
@Data
public abstract class DomainEvent {
    
    private final UUID eventId = UUID.randomUUID();
    private final UUID aggregateId;
    private final String aggregateType;
    private final String eventType;
    private final int eventVersion;
    private final Instant occurredAt = Instant.now();
    
    protected DomainEvent(UUID aggregateId, String aggregateType, String eventType, int eventVersion) {
        this.aggregateId = aggregateId;
        this.aggregateType = aggregateType;
        this.eventType = eventType;
        this.eventVersion = eventVersion;
    }
    
    /**
     * Get the event data that will be persisted to the event store.
     * This should contain all the information needed to reconstruct the event.
     */
    public abstract Object getEventData();
}
