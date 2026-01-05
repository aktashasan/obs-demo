package com.example.observability.filter;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Servlet Filter for HTTP request metrics instrumentation
 * 
 * This filter intercepts all HTTP requests and records:
 * 1. Request count via Counter (http_requests_total)
 * 2. Request duration via Timer (http_request_duration_seconds)
 * 
 * Both metrics include tags: method, endpoint, status
 * 
 * Uses OncePerRequestFilter to ensure metrics are recorded exactly once per request,
 * even in the presence of request forwarding or error handling.
 */
@Component
public class MetricsFilter extends OncePerRequestFilter {

    private final MeterRegistry meterRegistry;

    public MetricsFilter(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        
        long startTime = System.nanoTime();
        
        try {
            // Continue with the request
            filterChain.doFilter(request, response);
        } finally {
            // Record metrics after request completion (success or failure)
            long duration = System.nanoTime() - startTime;
            recordMetrics(request, response, duration);
        }
    }

    /**
     * Records custom metrics for the HTTP request
     * 
     * Metrics recorded:
     * - http_requests_total: Counter with tags [method, endpoint, status]
     * - http_request_duration_seconds: Timer with tags [method, endpoint, status]
     * 
     * @param request  HTTP request
     * @param response HTTP response
     * @param duration Request duration in nanoseconds
     */
    private void recordMetrics(HttpServletRequest request, HttpServletResponse response, long duration) {
        String method = request.getMethod();
        String endpoint = normalizeEndpoint(request.getRequestURI());
        String status = String.valueOf(response.getStatus());

        // Record request count
        Counter counter = Counter.builder("http_requests_total")
                .description("Total number of HTTP requests")
                .tag("method", method)
                .tag("endpoint", endpoint)
                .tag("status", status)
                .register(meterRegistry);
        counter.increment();

        // Record request duration
        Timer timer = Timer.builder("http_request_duration_seconds")
                .description("HTTP request duration in seconds")
                .tag("method", method)
                .tag("endpoint", endpoint)
                .tag("status", status)
                .register(meterRegistry);
        timer.record(duration, TimeUnit.NANOSECONDS);
    }

    /**
     * Normalizes the endpoint path to avoid high-cardinality metrics
     * 
     * Strategy:
     * - Keep well-known paths as-is: /api/hello, /healthz
     * - Keep actuator paths as-is: /actuator/*
     * - Replace path parameters with placeholders to avoid cardinality explosion
     * 
     * Examples:
     * - /api/hello -> /api/hello
     * - /api/users/123 -> /api/users/{id}
     * - /actuator/prometheus -> /actuator/prometheus
     * 
     * @param uri The request URI
     * @return Normalized endpoint path
     */
    private String normalizeEndpoint(String uri) {
        if (uri == null) {
            return "unknown";
        }

        // Remove query parameters
        int queryIndex = uri.indexOf('?');
        if (queryIndex > 0) {
            uri = uri.substring(0, queryIndex);
        }

        // Keep well-known endpoints as-is
        if (uri.equals("/api/hello") || 
            uri.equals("/healthz") || 
            uri.startsWith("/actuator/")) {
            return uri;
        }

        // For other endpoints, apply normalization to prevent cardinality issues
        // Example: /api/users/123 -> /api/users/{id}
        if (uri.matches("/api/[^/]+/\\d+")) {
            return uri.replaceAll("\\d+", "{id}");
        }

        // Return the path as-is if no normalization rule applies
        // In production, you might want more sophisticated normalization
        return uri;
    }

    /**
     * Skip metrics collection for actuator endpoints to avoid metric loops
     * (optional optimization)
     */
    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        String path = request.getRequestURI();
        // We actually want to record metrics for all endpoints including actuator
        // But you could exclude prometheus endpoint to avoid recording its own metrics:
        // return path.equals("/actuator/prometheus");
        return false;
    }
}

