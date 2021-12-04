package com.example.demo.repository;

import java.util.List;

import com.example.demo.model.Event;

import org.springframework.data.jpa.repository.JpaRepository;

public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByPublished(boolean published);

    List<Event> findByTitleContaining(String title);
}
