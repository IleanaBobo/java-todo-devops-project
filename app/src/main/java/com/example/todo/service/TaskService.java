package com.example.todo.service;

import com.example.todo.model.Task;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final List<Task> tasks = new ArrayList<>();
    private final AtomicLong idCounter = new AtomicLong();

    public List<Task> getAllTasks() {
        return tasks;
    }

    public Task createTask(Task task) {
        Task newTask = new Task(
                idCounter.incrementAndGet(),
                task.getTitle(),
                false
        );

        tasks.add(newTask);
        return newTask;
    }

    public Optional<Task> completeTask(Long id) {
        return tasks.stream()
                .filter(task -> task.getId().equals(id))
                .findFirst()
                .map(task -> {
                    task.setCompleted(true);
                    return task;
                });
    }

    public boolean deleteTask(Long id) {
        return tasks.removeIf(task -> task.getId().equals(id));
    }
}
