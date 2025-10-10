package com.frankenstein.user.infrastructure.java21;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.SequencedMap;
import java.util.SequencedSet;

/**
 * Java 21 Sequenced Collections examples demonstrating enhanced collection operations.
 * Sequenced Collections provide consistent methods to access first/last elements
 * and reverse collections across different collection types.
 */
public class SequencedCollectionsExample {

    /**
     * Demonstrate SequencedList operations.
     * Now all List implementations have consistent first/last element access.
     */
    public void demonstrateSequencedList() {
        // All List implementations now support sequenced operations
        List<String> userEmails = new ArrayList<>();
        userEmails.add("first@example.com");
        userEmails.add("middle@example.com");
        userEmails.add("last@example.com");

        // Java 21: Consistent first/last access across all List types
        String firstEmail = userEmails.getFirst();  // first@example.com
        String lastEmail = userEmails.getLast();    // last@example.com

        System.out.println("First user: " + firstEmail);
        System.out.println("Last user: " + lastEmail);

        // Reverse the list consistently
        List<String> reversedEmails = userEmails.reversed();
        System.out.println("Reversed: " + reversedEmails);

        // Add to beginning and end consistently
        userEmails.addFirst("newest@example.com");
        userEmails.addLast("oldest@example.com");
        
        System.out.println("After adding: " + userEmails);
    }

    /**
     * Demonstrate SequencedSet operations.
     * LinkedHashSet now has consistent first/last operations.
     */
    public void demonstrateSequencedSet() {
        // LinkedHashSet maintains insertion order and now supports sequenced operations
        LinkedHashSet<String> userRoles = new LinkedHashSet<>();
        userRoles.add("ADMIN");
        userRoles.add("USER");
        userRoles.add("MODERATOR");

        // Java 21: Consistent access to first/last elements
        String firstRole = userRoles.getFirst();  // ADMIN (first inserted)
        String lastRole = userRoles.getLast();    // MODERATOR (last inserted)

        System.out.println("Primary role: " + firstRole);
        System.out.println("Latest role: " + lastRole);

        // Reverse the set
        SequencedSet<String> reversedRoles = userRoles.reversed();
        System.out.println("Roles in reverse order: " + reversedRoles);

        // Remove first and last elements
        userRoles.removeFirst();  // Removes ADMIN
        userRoles.removeLast();   // Removes MODERATOR
        System.out.println("After removing first/last: " + userRoles);
    }

    /**
     * Demonstrate SequencedMap operations.
     * LinkedHashMap now has consistent first/last entry operations.
     */
    public void demonstrateSequencedMap() {
        // LinkedHashMap maintains insertion order
        LinkedHashMap<String, LocalDateTime> userLoginTimes = new LinkedHashMap<>();
        userLoginTimes.put("alice@example.com", LocalDateTime.now().minusHours(3));
        userLoginTimes.put("bob@example.com", LocalDateTime.now().minusHours(2));
        userLoginTimes.put("charlie@example.com", LocalDateTime.now().minusHours(1));

        // Java 21: Access first and last entries
        Map.Entry<String, LocalDateTime> firstLogin = userLoginTimes.firstEntry();
        Map.Entry<String, LocalDateTime> lastLogin = userLoginTimes.lastEntry();

        System.out.println("Earliest login: " + firstLogin.getKey() + " at " + firstLogin.getValue());
        System.out.println("Latest login: " + lastLogin.getKey() + " at " + lastLogin.getValue());

        // Get reversed view of the map
        SequencedMap<String, LocalDateTime> reversedLogins = userLoginTimes.reversed();
        System.out.println("Logins in reverse order: " + reversedLogins.keySet());

        // Remove first and last entries
        userLoginTimes.pollFirstEntry();  // Removes alice
        userLoginTimes.pollLastEntry();   // Removes charlie
        System.out.println("After removing first/last: " + userLoginTimes.keySet());
    }

    /**
     * Practical example: User session management with Sequenced Collections.
     */
    public static class UserSessionManager {
        private final LinkedHashMap<String, UserSession> activeSessions = new LinkedHashMap<>();
        private final int maxSessions = 100;

        public record UserSession(
            String sessionId,
            String userId,
            LocalDateTime loginTime,
            String ipAddress
        ) {}

        public void addSession(UserSession session) {
            // Add new session
            activeSessions.put(session.sessionId(), session);

            // If we exceed max sessions, remove the oldest one
            if (activeSessions.size() > maxSessions) {
                Map.Entry<String, UserSession> oldestSession = activeSessions.pollFirstEntry();
                System.out.println("Removed oldest session: " + oldestSession.getValue().userId());
            }
        }

        public UserSession getMostRecentSession() {
            return activeSessions.isEmpty() ? null : activeSessions.lastEntry().getValue();
        }

        public UserSession getOldestSession() {
            return activeSessions.isEmpty() ? null : activeSessions.firstEntry().getValue();
        }

        public List<UserSession> getRecentSessions(int count) {
            return activeSessions.reversed()  // Most recent first
                .values()
                .stream()
                .limit(count)
                .toList();
        }

        public void cleanupOldSessions(int hoursOld) {
            LocalDateTime cutoff = LocalDateTime.now().minusHours(hoursOld);
            
            // Remove old sessions (iterate from oldest first)
            activeSessions.entrySet().removeIf(entry -> 
                entry.getValue().loginTime().isBefore(cutoff));
        }

        public int getActiveSessionCount() {
            return activeSessions.size();
        }
    }

    /**
     * Example: Priority queue with sequenced operations.
     */
    public static class UserNotificationQueue {
        private final LinkedHashSet<NotificationTask> tasks = new LinkedHashSet<>();

        public record NotificationTask(
            String userId,
            String message,
            Priority priority,
            LocalDateTime createdAt
        ) {}

        public enum Priority { LOW, NORMAL, HIGH, URGENT }

        public void addTask(NotificationTask task) {
            // Remove if already exists (to update position)
            tasks.remove(task);
            
            // Add based on priority (simplified - real implementation would use proper ordering)
            if (task.priority() == Priority.URGENT) {
                tasks.addFirst(task);  // Urgent tasks go first
            } else {
                tasks.addLast(task);   // Other tasks go to end
            }
        }

        public NotificationTask getNextTask() {
            return tasks.isEmpty() ? null : tasks.removeFirst();
        }

        public NotificationTask peekNextTask() {
            return tasks.isEmpty() ? null : tasks.getFirst();
        }

        public List<NotificationTask> getAllTasks() {
            return new ArrayList<>(tasks);
        }

        public List<NotificationTask> getTasksInReverseOrder() {
            return new ArrayList<>(tasks.reversed());
        }

        public boolean removeTasksForUser(String userId) {
            return tasks.removeIf(task -> task.userId().equals(userId));
        }
    }

    /**
     * Demonstrate all sequenced collection types working together.
     */
    public void comprehensiveExample() {
        System.out.println("=== Comprehensive Sequenced Collections Example ===");

        // Session management
        UserSessionManager sessionManager = new UserSessionManager();
        sessionManager.addSession(new UserSessionManager.UserSession(
            "session1", "user1", LocalDateTime.now().minusHours(2), "192.168.1.1"));
        sessionManager.addSession(new UserSessionManager.UserSession(
            "session2", "user2", LocalDateTime.now().minusHours(1), "192.168.1.2"));
        sessionManager.addSession(new UserSessionManager.UserSession(
            "session3", "user3", LocalDateTime.now(), "192.168.1.3"));

        System.out.println("Most recent session: " + sessionManager.getMostRecentSession().userId());
        System.out.println("Oldest session: " + sessionManager.getOldestSession().userId());

        // Notification queue
        UserNotificationQueue notificationQueue = new UserNotificationQueue();
        notificationQueue.addTask(new UserNotificationQueue.NotificationTask(
            "user1", "Welcome message", UserNotificationQueue.Priority.NORMAL, LocalDateTime.now()));
        notificationQueue.addTask(new UserNotificationQueue.NotificationTask(
            "user2", "Security alert", UserNotificationQueue.Priority.URGENT, LocalDateTime.now()));
        notificationQueue.addTask(new UserNotificationQueue.NotificationTask(
            "user3", "Newsletter", UserNotificationQueue.Priority.LOW, LocalDateTime.now()));

        System.out.println("Next task: " + notificationQueue.getNextTask().message());
        System.out.println("Remaining tasks: " + notificationQueue.getAllTasks().size());
    }
}
