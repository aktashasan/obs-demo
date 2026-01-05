package com.example.observability.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

/**
 * REST Controller for the hello endpoint
 * 
 * This endpoint is automatically instrumented for metrics via MetricsFilter
 */
@RestController
@RequestMapping("/api")
public class HelloController {

    /**
     * Hello endpoint that returns a greeting message with timestamp
     * 
     * Metrics collected:
     * - http_requests_total{method="GET",endpoint="/api/hello",status="200"}
     * - http_request_duration_seconds{method="GET",endpoint="/api/hello",status="200"}
     * 
     * @return JSON response with message and ISO-8601 timestamp
     */
    @GetMapping("/hello")
    public ResponseEntity<Map<String, String>> hello() {
        Map<String, String> response = Map.of(
            "message", "hello",
            "timestamp", Instant.now().toString()
        );
        
        return ResponseEntity.ok(response);
    }
}

