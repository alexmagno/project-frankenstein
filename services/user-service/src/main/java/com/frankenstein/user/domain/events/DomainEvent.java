package com.frankenstein.user.domain.events;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonTypeInfo;

/**
 * Base class for all domain events in the system.
 * Events represent something that has happened in the domain.
 */
@JsonTypeInfo(use = JsonTypeInfo.Id.CLASS, property = "@type")
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
    
    public UUID getEventId() {
        return eventId;
    }
    
    public UUID getAggregateId() {
        return aggregateId;
    }
    
    public String getAggregateType() {
        return aggregateType;
    }
    
    public String getEventType() {
        return eventType;
    }
    
    public int getEventVersion() {
        return eventVersion;
    }
    
    public Instant getOccurredAt() {
        return occurredAt;
    }
    
    /**
     * Get the event data that will be persisted to the event store.
     * This should contain all the information needed to reconstruct the event.
     */
    public abstract Object getEventData();
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        DomainEvent that = (DomainEvent) o;
        return eventVersion == that.eventVersion &&
                Objects.equals(eventId, that.eventId) &&
                Objects.equals(aggregateId, that.aggregateId) &&
                Objects.equals(aggregateType, that.aggregateType) &&
                Objects.equals(eventType, that.eventType);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(eventId, aggregateId, aggregateType, eventType, eventVersion);
    }
    
    @Override
    public String toString() {
        return "DomainEvent{" +
                "eventId=" + eventId +
                ", aggregateId=" + aggregateId +
                ", aggregateType='" + aggregateType + '\'' +
                ", eventType='" + eventType + '\'' +
                ", eventVersion=" + eventVersion +
                ", occurredAt=" + occurredAt +
                '}';
    }
}
