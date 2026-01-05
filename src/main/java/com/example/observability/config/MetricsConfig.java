package com.example.observability.config;

import org.springframework.context.annotation.Configuration;

/**
 * Configuration class for custom Micrometer metrics
 * 
 * Defines the custom metrics used for HTTP request instrumentation:
 * - http_requests_total (Counter)
 * - http_request_duration_seconds (Timer/Histogram)
 * 
 * Note: The MeterRegistry is auto-configured by Spring Boot with Prometheus support.
 * We don't need to manually create a bean as it causes circular dependency issues.
 * 
 * Custom metrics (Counter, Timer) are created dynamically in MetricsFilter
 * with appropriate tags (method, endpoint, status) per request.
 */
@Configuration
public class MetricsConfig {
    // No bean definitions needed - Spring Boot auto-configures MeterRegistry
    // The MetricsFilter will use the auto-configured MeterRegistry via dependency injection
}

