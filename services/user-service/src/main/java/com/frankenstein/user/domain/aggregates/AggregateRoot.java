package com.frankenstein.user.domain.aggregates;

import com.frankenstein.user.domain.events.DomainEvent;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

/**
 * Base class for aggregate roots in the CQRS + Event Sourcing architecture.
 * Aggregates are responsible for maintaining consistency boundaries and 
 * generating domain events when their state changes.
 */
public abstract class AggregateRoot {
    
    protected UUID id;
    protected int version = 0;
    private final List<DomainEvent> uncommittedEvents = new ArrayList<>();
    
    protected AggregateRoot() {
        // Default constructor for framework usage
    }
    
    protected AggregateRoot(UUID id) {
        this.id = id;
    }
    
    /**
     * Get the unique identifier for this aggregate.
     */
    public UUID getId() {
        return id;
    }
    
    /**
     * Get the current version of this aggregate.
     * Version is incremented with each event.
     */
    public int getVersion() {
        return version;
    }
    
    /**
     * Get all uncommitted events for this aggregate.
     * These events should be persisted to the event store.
     */
    public List<DomainEvent> getUncommittedEvents() {
        return Collections.unmodifiableList(uncommittedEvents);
    }
    
    /**
     * Mark all events as committed after they've been persisted.
     */
    public void markEventsAsCommitted() {
        uncommittedEvents.clear();
    }
    
    /**
     * Apply an event to this aggregate and add it to uncommitted events.
     * This is used when handling commands.
     */
    protected void applyEvent(DomainEvent event) {
        applyChange(event);
        uncommittedEvents.add(event);
    }
    
    /**
     * Apply an event to this aggregate without adding to uncommitted events.
     * This is used when rebuilding aggregate state from event history.
     */
    public void applyHistoricalEvent(DomainEvent event) {
        applyChange(event);
        this.version = event.getEventVersion();
    }
    
    /**
     * Apply the state changes from an event to this aggregate.
     * Subclasses must implement this to handle specific event types.
     */
    protected abstract void applyChange(DomainEvent event);
    
    /**
     * Validate business rules before applying changes.
     * Subclasses can override this to add validation logic.
     */
    protected void validateInvariants() {
        // Default implementation - no validation
    }
}
