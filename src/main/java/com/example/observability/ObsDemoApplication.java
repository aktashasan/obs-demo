package com.example.observability;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot Application for Observability Demo Service
 * 
 * This service demonstrates production-ready observability patterns:
 * - Prometheus metrics exposure
 * - Custom HTTP request instrumentation
 * - JVM metrics (memory, GC, threads, CPU)
 * - Kubernetes-ready health probes
 */
@SpringBootApplication
public class ObsDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(ObsDemoApplication.class, args);
    }
}

