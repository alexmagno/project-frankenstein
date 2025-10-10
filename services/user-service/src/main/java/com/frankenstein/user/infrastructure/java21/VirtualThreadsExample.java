package com.frankenstein.user.infrastructure.java21;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.stream.IntStream;

import org.springframework.stereotype.Service;

/**
 * Java 21 Virtual Threads examples for high-concurrency user operations.
 * Virtual Threads provide massive scalability improvements for I/O-bound operations.
 */
@Service
public class VirtualThreadsExample {

    /**
     * Virtual Thread Executor for high-concurrency operations.
     * Can handle millions of virtual threads with minimal overhead.
     */
    private final java.util.concurrent.ExecutorService virtualExecutor = 
        Executors.newVirtualThreadPerTaskExecutor();

    /**
     * Process user registrations concurrently using Virtual Threads.
     * Traditional threads would be limited to thousands, Virtual Threads can handle hundreds of thousands.
     */
    public List<String> processUserRegistrationsConcurrently(List<String> emails) {
        var startTime = Instant.now();
        
        // Create a virtual thread for each registration
        List<Future<String>> futures = emails.stream()
            .map(email -> virtualExecutor.submit(() -> {
                // Simulate I/O-bound operation (database call, email validation, etc.)
                return processUserRegistration(email);
            }))
            .toList();

        // Collect results
        List<String> results = futures.stream()
            .map(future -> {
                try {
                    return future.get();
                } catch (Exception e) {
                    return "Error: " + e.getMessage();
                }
            })
            .toList();

        var duration = Duration.between(startTime, Instant.now());
        System.out.println("Processed %d registrations in %d ms using Virtual Threads"
            .formatted(emails.size(), duration.toMillis()));

        return results;
    }

    /**
     * Simulate a user registration process with I/O operations.
     */
    private String processUserRegistration(String email) {
        try {
            // Simulate database operation
            Thread.sleep(100);
            
            // Simulate email validation service call
            Thread.sleep(50);
            
            // Simulate user creation
            Thread.sleep(25);
            
            return "User registered: " + email;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return "Registration failed: " + email;
        }
    }

    /**
     * Demonstrate Virtual Threads vs Platform Threads performance.
     * Virtual Threads excel in I/O-bound scenarios.
     */
    public void compareVirtualVsPlatformThreads() {
        int numberOfTasks = 10_000;
        
        // Test with Platform Threads (traditional)
        var platformExecutor = Executors.newFixedThreadPool(200); // Limited pool
        var startTime = Instant.now();
        
        List<Future<String>> platformFutures = IntStream.range(0, numberOfTasks)
            .mapToObj(i -> platformExecutor.submit(() -> simulateIoOperation("task-" + i)))
            .toList();
            
        // Wait for completion
        platformFutures.forEach(future -> {
            try { future.get(); } catch (Exception e) { /* ignore */ }
        });
        
        var platformDuration = Duration.between(startTime, Instant.now());
        platformExecutor.shutdown();

        // Test with Virtual Threads
        startTime = Instant.now();
        List<Future<String>> virtualFutures = IntStream.range(0, numberOfTasks)
            .mapToObj(i -> virtualExecutor.submit(() -> simulateIoOperation("task-" + i)))
            .toList();
            
        // Wait for completion
        virtualFutures.forEach(future -> {
            try { future.get(); } catch (Exception e) { /* ignore */ }
        });
        
        var virtualDuration = Duration.between(startTime, Instant.now());

        System.out.println("""
            Performance Comparison for %d I/O-bound tasks:
            Platform Threads: %d ms
            Virtual Threads:  %d ms
            Improvement:      %.2fx faster
            """.formatted(
                numberOfTasks,
                platformDuration.toMillis(),
                virtualDuration.toMillis(),
                (double) platformDuration.toMillis() / virtualDuration.toMillis()
            ));
    }

    private String simulateIoOperation(String taskId) {
        try {
            // Simulate I/O operation (database, network call, etc.)
            Thread.sleep(50);
            return "Completed: " + taskId;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return "Failed: " + taskId;
        }
    }

    /**
     * Virtual Threads with CompletableFuture for complex async workflows.
     * Great for microservices communication and event processing.
     */
    public CompletableFuture<String> processUserWorkflowAsync(UUID userId) {
        return CompletableFuture
            .supplyAsync(() -> fetchUserProfile(userId), virtualExecutor)
            .thenComposeAsync(profile -> validateUserProfile(profile), virtualExecutor)
            .thenComposeAsync(validation -> updateUserStatus(userId, validation), virtualExecutor)
            .thenComposeAsync(status -> notifyUserUpdate(userId, status), virtualExecutor)
            .exceptionally(throwable -> "Workflow failed: " + throwable.getMessage());
    }

    private String fetchUserProfile(UUID userId) {
        // Simulate database fetch
        try { Thread.sleep(100); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        return "Profile for user: " + userId;
    }

    private CompletableFuture<String> validateUserProfile(String profile) {
        return CompletableFuture.supplyAsync(() -> {
            // Simulate validation service call
            try { Thread.sleep(75); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return "Validated: " + profile;
        }, virtualExecutor);
    }

    private CompletableFuture<String> updateUserStatus(UUID userId, String validation) {
        return CompletableFuture.supplyAsync(() -> {
            // Simulate database update
            try { Thread.sleep(50); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return "Updated status for: " + userId;
        }, virtualExecutor);
    }

    private CompletableFuture<String> notifyUserUpdate(UUID userId, String status) {
        return CompletableFuture.supplyAsync(() -> {
            // Simulate notification service call
            try { Thread.sleep(25); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return "Notification sent for: " + userId;
        }, virtualExecutor);
    }

    /**
     * Structured Concurrency example (Preview in Java 21).
     * Provides better error handling and resource management for concurrent operations.
     */
    public String processUserWithStructuredConcurrency(UUID userId) {
        try (var scope = new java.util.concurrent.StructuredTaskScope.ShutdownOnFailure()) {
            
            // Launch concurrent subtasks
            var profileFuture = scope.fork(() -> fetchUserProfile(userId));
            var preferencesFuture = scope.fork(() -> fetchUserPreferences(userId));
            var activityFuture = scope.fork(() -> fetchUserActivity(userId));
            
            // Wait for all tasks to complete or any to fail
            scope.join();           // Wait for all tasks
            scope.throwIfFailed();  // Throw if any task failed
            
            // All tasks completed successfully
            return "User data processed: " + 
                   profileFuture.resultNow() + ", " +
                   preferencesFuture.resultNow() + ", " +
                   activityFuture.resultNow();
                   
        } catch (Exception e) {
            return "Failed to process user: " + e.getMessage();
        }
    }

    private String fetchUserPreferences(UUID userId) {
        try { Thread.sleep(80); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        return "Preferences for: " + userId;
    }

    private String fetchUserActivity(UUID userId) {
        try { Thread.sleep(60); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        return "Activity for: " + userId;
    }
}
