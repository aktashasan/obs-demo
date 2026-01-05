package com.example.observability.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Custom health endpoint for Kubernetes probes
 * 
 * This is separate from /actuator/health to provide a simple, fast probe endpoint
 * that doesn't require actuator security configuration.
 */
@RestController
public class HealthController {

    /**
     * Simple health check endpoint for Kubernetes liveness/readiness probes
     * 
     * @return HTTP 200 with status "ok"
     */
    @GetMapping("/healthz")
    public ResponseEntity<Map<String, String>> healthz() {
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}

