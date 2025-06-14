package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    private final String serverName = System.getenv().getOrDefault("SERVER_NAME", "unknown");

    @GetMapping("/")
    public String hello() {
        return "Hello from v0.0.4" + serverName;
    }
} 