package com.example.observability.controller;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Observability Test Controller
 * 
 * Purpose: Provides debug endpoints for testing Grafana dashboards and alerts.
 * This controller is ONLY enabled when obs.debug.enabled=true (disabled by
 * default).
 * 
 * Use cases:
 * - Testing latency p95 alerts by adding artificial delays
 * - Testing 5xx error ratio alerts by forcing controlled errors
 * - Validating Prometheus metric collection
 * 
 * WARNING: This should be disabled in production environments.
 */
@RestController
@ConditionalOnProperty(name = "obs.debug.enabled", havingValue = "true", matchIfMissing = false)
public class ObsTestController {

    private static final Logger logger = LoggerFactory.getLogger(ObsTestController.class);

    // Constants for validation
    private static final int MAX_SLEEP_MS = 10000;
    private static final int MIN_ERROR_CODE = 400;
    private static final int MAX_ERROR_CODE = 599;

    private final MeterRegistry meterRegistry;
    private final Timer customSleepTimer;
    private final Map<Integer, Counter> errorCounters;

    public ObsTestController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.errorCounters = new ConcurrentHashMap<>();

        // Create custom timer for sleep endpoint
        this.customSleepTimer = Timer.builder("obs.debug.sleep")
                .description("Custom timer for artificial sleep endpoint")
                .tag("endpoint", "/debug/sleep")
                .register(meterRegistry);

        logger.info("ObsTestController initialized - debug endpoints are ENABLED");
    }

    /**
     * Endpoint: GET /debug/sleep?ms=200
     * 
     * Adds artificial latency to test latency dashboards and alerts.
     * Sleep duration is capped at 10000ms for safety.
     * 
     * @param ms Sleep duration in milliseconds (default: 200, max: 10000)
     * @return JSON response with actual sleep duration
     */
    @GetMapping("/debug/sleep")
    public ResponseEntity<Map<String, Object>> sleep(
            @RequestParam(defaultValue = "200") int ms) {

        // Validate and cap sleep duration
        int actualSleepMs = Math.min(Math.max(0, ms), MAX_SLEEP_MS);

        if (actualSleepMs != ms) {
            logger.warn("Sleep duration capped: requested={}, actual={}", ms, actualSleepMs);
        }

        // Record the operation using the custom timer
        return customSleepTimer.record(() -> {
            try {
                Thread.sleep(actualSleepMs);
                logger.debug("Artificial sleep completed: {}ms", actualSleepMs);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.error("Sleep interrupted", e);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("sleptMs", actualSleepMs);

            return ResponseEntity.ok(response);
        });
    }

    /**
     * Endpoint: GET /debug/error?code=500
     * 
     * Returns controlled error responses to test error rate dashboards and alerts.
     * Increments a Prometheus counter labeled by HTTP status code.
     * 
     * @param code HTTP error code (default: 500, allowed: 400-599)
     * @return Error response with the specified HTTP status code
     */
    @GetMapping("/debug/error")
    public ResponseEntity<Map<String, Object>> error(
            @RequestParam(defaultValue = "500") int code) {

        // Validate error code range
        int actualCode = code;
        if (code < MIN_ERROR_CODE || code > MAX_ERROR_CODE) {
            logger.warn("Invalid error code requested: {}, using 500", code);
            actualCode = 500;
        }

        // Get or create counter for this error code
        Counter errorCounter = errorCounters.computeIfAbsent(actualCode,
                c -> Counter.builder("obs.forced.errors.total")
                        .description("Counter for forced error responses from debug endpoint")
                        .tag("code", String.valueOf(c))
                        .tag("endpoint", "/debug/error")
                        .register(meterRegistry));

        // Increment the counter
        errorCounter.increment();

        logger.debug("Forced error returned: code={}", actualCode);

        Map<String, Object> response = new HashMap<>();
        response.put("error", "forced");
        response.put("code", actualCode);

        return ResponseEntity.status(actualCode).body(response);
    }
}
