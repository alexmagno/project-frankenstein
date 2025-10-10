package com.frankenstein.user.infrastructure.java21;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.frankenstein.user.infrastructure.java21.SealedClassesExample.AdminRole;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.ApiSuccess;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.ApiValidationError;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.BankTransferPayment;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.CreditCardPayment;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.CustomerRole;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.ModeratorRole;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.PayPalPayment;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.PaymentMethod;
import com.frankenstein.user.infrastructure.java21.SealedClassesExample.UserRole;

/**
 * Java 21 Sealed Classes examples for the User Service.
 * Demonstrates type-safe domain modeling and exhaustive pattern matching.
 */
@Service
public class SealedClassesExample {

    // Example sealed interface for payment methods
    public sealed interface PaymentMethod 
        permits CreditCardPayment, PayPalPayment, BankTransferPayment {
        
        String getPaymentId();
        BigDecimal getAmount();
        String processPayment();
    }

    public record CreditCardPayment(
        String paymentId,
        String cardNumber,
        String expiryDate,
        String cvv,
        BigDecimal amount
    ) implements PaymentMethod {
        
        @Override
        public String getPaymentId() { return paymentId; }
        
        @Override
        public BigDecimal getAmount() { return amount; }
        
        @Override
        public String processPayment() {
            return "Processing credit card payment of $" + amount + " for card ending in " + 
                   cardNumber.substring(cardNumber.length() - 4);
        }
    }

    public record PayPalPayment(
        String paymentId,
        String email,
        String paypalTransactionId,
        BigDecimal amount
    ) implements PaymentMethod {
        
        @Override
        public String getPaymentId() { return paymentId; }
        
        @Override
        public BigDecimal getAmount() { return amount; }
        
        @Override
        public String processPayment() {
            return "Processing PayPal payment of $" + amount + " for " + email;
        }
    }

    public record BankTransferPayment(
        String paymentId,
        String bankAccount,
        String routingNumber,
        BigDecimal amount
    ) implements PaymentMethod {
        
        @Override
        public String getPaymentId() { return paymentId; }
        
        @Override
        public BigDecimal getAmount() { return amount; }
        
        @Override
        public String processPayment() {
            return "Processing bank transfer of $" + amount + " to account " + 
                   bankAccount.substring(bankAccount.length() - 4);
        }
    }

    // Example sealed interface for API responses
    public sealed interface ApiResponse<T> 
        permits ApiSuccess, ApiError, ApiValidationError {
        
        int getStatusCode();
        String getMessage();
        Instant getTimestamp();
    }

    public record ApiSuccess<T>(
        T data,
        String message,
        int statusCode,
        Instant timestamp
    ) implements ApiResponse<T> {
        
        @Override
        public int getStatusCode() { return statusCode; }
        
        @Override
        public String getMessage() { return message; }
        
        @Override
        public Instant getTimestamp() { return timestamp; }
    }

    public record ApiError(
        String errorCode,
        String message,
        int statusCode,
        Instant timestamp,
        String details
    ) implements ApiResponse<Void> {
        
        @Override
        public int getStatusCode() { return statusCode; }
        
        @Override
        public String getMessage() { return message; }
        
        @Override
        public Instant getTimestamp() { return timestamp; }
    }

    public record ApiValidationError(
        Map<String, String> fieldErrors,
        String message,
        int statusCode,
        Instant timestamp
    ) implements ApiResponse<Void> {
        
        @Override
        public int getStatusCode() { return statusCode; }
        
        @Override
        public String getMessage() { return message; }
        
        @Override
        public Instant getTimestamp() { return timestamp; }
    }

    // Example sealed interface for user roles
    public sealed interface UserRole 
        permits CustomerRole, AdminRole, ModeratorRole {
        
        UUID userId();
        Set<String> getPermissions();
        boolean hasPermission(String permission);
    }

    public record CustomerRole(UUID userId, String tier) implements UserRole {
        @Override
        public Set<String> getPermissions() {
            return switch (tier.toLowerCase()) {
                case "basic" -> Set.of("VIEW_PRODUCTS", "PLACE_ORDERS");
                case "premium" -> Set.of("VIEW_PRODUCTS", "PLACE_ORDERS", "ACCESS_PREMIUM");
                case "vip" -> Set.of("VIEW_PRODUCTS", "PLACE_ORDERS", "ACCESS_PREMIUM", "PRIORITY_SUPPORT");
                default -> Set.of("VIEW_PRODUCTS");
            };
        }

        @Override
        public boolean hasPermission(String permission) {
            return getPermissions().contains(permission);
        }
    }

    public record AdminRole(UUID userId, Set<String> adminPermissions) implements UserRole {
        @Override
        public Set<String> getPermissions() {
            var basePermissions = Set.of("VIEW_PRODUCTS", "MANAGE_USERS", "VIEW_ANALYTICS");
            return Set.of(basePermissions, adminPermissions).stream()
                .flatMap(Set::stream)
                .collect(java.util.stream.Collectors.toSet());
        }

        @Override
        public boolean hasPermission(String permission) {
            return getPermissions().contains(permission);
        }
    }

    public record ModeratorRole(UUID userId, String department) implements UserRole {
        @Override
        public Set<String> getPermissions() {
            return Set.of("VIEW_PRODUCTS", "MODERATE_CONTENT", "MANAGE_REVIEWS");
        }

        @Override
        public boolean hasPermission(String permission) {
            return getPermissions().contains(permission);
        }
    }

    /**
     * Processes payment using exhaustive pattern matching.
     * Sealed classes ensure all payment types are handled.
     */
    public String processPaymentMethod(PaymentMethod payment) {
        return switch (payment) {
            case CreditCardPayment(var id, var card, var expiry, var cvv, var amount) ->
                "Credit Card Payment: " + payment.processPayment() + " [ID: " + id + "]";
                
            case PayPalPayment(var id, var email, var transactionId, var amount) ->
                "PayPal Payment: " + payment.processPayment() + " [Transaction: " + transactionId + "]";
                
            case BankTransferPayment(var id, var account, var routing, var amount) ->
                "Bank Transfer: " + payment.processPayment() + " [Routing: " + routing + "]";
        };
    }

    /**
     * Handles API responses with exhaustive pattern matching.
     * Demonstrates type-safe response handling.
     */
    public <T> String handleApiResponse(ApiResponse<T> response) {
        return switch (response) {
            case ApiSuccess<T>(var data, var message, var statusCode, var timestamp) ->
                "Success (%d): %s at %s with data: %s".formatted(statusCode, message, timestamp, data);
                
            case ApiError(var errorCode, var message, var statusCode, var timestamp, var details) ->
                "Error (%d): %s [%s] at %s - Details: %s".formatted(
                    statusCode, message, errorCode, timestamp, details);
                    
            case ApiValidationError(var fieldErrors, var message, var statusCode, var timestamp) ->
                "Validation Error (%d): %s at %s - Fields: %s".formatted(
                    statusCode, message, timestamp, fieldErrors);
        };
    }

    /**
     * Checks user permissions using sealed class pattern matching.
     * Demonstrates role-based access control.
     */
    public String checkUserAccess(UserRole role, String requestedPermission) {
        return switch (role) {
            case CustomerRole(var userId, var tier) when role.hasPermission(requestedPermission) ->
                "Customer [%s] with tier '%s' has permission: %s".formatted(userId, tier, requestedPermission);
                
            case AdminRole(var userId, var adminPerms) when role.hasPermission(requestedPermission) ->
                "Admin [%s] has permission: %s (Admin permissions: %s)".formatted(
                    userId, requestedPermission, adminPerms);
                    
            case ModeratorRole(var userId, var department) when role.hasPermission(requestedPermission) ->
                "Moderator [%s] from %s department has permission: %s".formatted(
                    userId, department, requestedPermission);
                    
            default -> "User [%s] does not have permission: %s".formatted(
                role.userId(), requestedPermission);
        };
    }

    /**
     * Example of using sealed classes with guards for complex business logic.
     * Demonstrates advanced pattern matching with conditions.
     */
    public String processHighValueTransaction(PaymentMethod payment, UserRole userRole) {
        return switch (payment) {
            case CreditCardPayment(var id, var card, var expiry, var cvv, var amount) 
                when amount.compareTo(BigDecimal.valueOf(1000)) > 0 -> {
                
                String roleCheck = switch (userRole) {
                    case CustomerRole(var userId, var tier) when "vip".equals(tier.toLowerCase()) ->
                        "VIP customer approved for high-value transaction";
                    case AdminRole(var userId, var adminPerms) ->
                        "Admin approved for high-value transaction";
                    default -> "High-value transaction requires additional verification";
                };
                
                yield "High-value credit card payment of $" + amount + " - " + roleCheck;
            }
            
            case PayPalPayment(var id, var email, var transactionId, var amount) 
                when amount.compareTo(BigDecimal.valueOf(500)) > 0 ->
                "High-value PayPal payment requires merchant verification: $" + amount;
                
            case BankTransferPayment(var id, var account, var routing, var amount) 
                when amount.compareTo(BigDecimal.valueOf(2000)) > 0 ->
                "High-value bank transfer requires compliance check: $" + amount;
                
            default -> "Standard payment processing: " + payment.processPayment();
        };
    }

    /**
     * Demonstrates sealed class exhaustiveness.
     * If a new payment method is added, this will fail to compile until updated.
     */
    public boolean isDigitalPayment(PaymentMethod payment) {
        return switch (payment) {
            case CreditCardPayment ignored -> true;
            case PayPalPayment ignored -> true;
            case BankTransferPayment ignored -> false;
            // Compiler ensures all sealed subclasses are handled
        };
    }

    /**
     * Example of sealed class hierarchy with complex nested pattern matching.
     */
    public String generatePaymentReport(PaymentMethod payment, UserRole role) {
        return switch (payment) {
            case CreditCardPayment cc -> switch (role) {
                case CustomerRole(var userId, var tier) -> 
                    "Customer %s (%s tier) paid $%s via credit card".formatted(userId, tier, cc.amount());
                case AdminRole(var userId, var perms) -> 
                    "Admin %s processed $%s credit card payment".formatted(userId, cc.amount());
                case ModeratorRole(var userId, var dept) -> 
                    "Moderator %s from %s dept processed $%s credit card payment".formatted(
                        userId, dept, cc.amount());
            };
            
            case PayPalPayment pp -> switch (role) {
                case CustomerRole(var userId, var tier) -> 
                    "Customer %s (%s tier) paid $%s via PayPal (%s)".formatted(
                        userId, tier, pp.amount(), pp.email());
                case AdminRole(var userId, var perms) -> 
                    "Admin %s processed $%s PayPal payment".formatted(userId, pp.amount());
                case ModeratorRole(var userId, var dept) -> 
                    "Moderator %s processed $%s PayPal payment".formatted(userId, pp.amount());
            };
            
            case BankTransferPayment bt -> 
                "Bank transfer of $%s processed by user %s".formatted(bt.amount(), role.userId());
        };
    }
}
