package com.devops.todo;

import com.devops.todo.model.Todo;
import com.devops.todo.repository.TodoRepository;
import com.devops.todo.service.TodoService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class TodoApplicationTests {

    @Autowired
    private TodoService todoService;

    @Autowired
    private TodoRepository todoRepository;

    @BeforeEach
    void setUp() {
        todoRepository.deleteAll();
    }

    @Test
    void contextLoads() {
        assertNotNull(todoService);
    }

    @Test
    void testCreateTodo() {
        Todo todo = new Todo("Test Todo", "Test Description");
        Todo savedTodo = todoService.createTodo(todo);

        assertNotNull(savedTodo.getId());
        assertEquals("Test Todo", savedTodo.getTitle());
        assertEquals("Test Description", savedTodo.getDescription());
        assertFalse(savedTodo.isCompleted());
    }

    @Test
    void testGetAllTodos() {
        todoService.createTodo(new Todo("Todo 1", "Description 1"));
        todoService.createTodo(new Todo("Todo 2", "Description 2"));

        assertEquals(2, todoService.getAllTodos().size());
    }

    @Test
    void testUpdateTodo() {
        Todo todo = todoService.createTodo(new Todo("Original", "Original Desc"));

        Todo updateDetails = new Todo("Updated", "Updated Desc");
        updateDetails.setCompleted(true);

        Todo updatedTodo = todoService.updateTodo(todo.getId(), updateDetails);

        assertEquals("Updated", updatedTodo.getTitle());
        assertEquals("Updated Desc", updatedTodo.getDescription());
        assertTrue(updatedTodo.isCompleted());
    }

    @Test
    void testDeleteTodo() {
        Todo todo = todoService.createTodo(new Todo("To Delete", "Description"));
        Long id = todo.getId();

        todoService.deleteTodo(id);

        assertEquals(0, todoService.getAllTodos().size());
    }
}
