-- init-db.sql - Database Initialization Script
-- Author: AbayK

-- Create todos table if not exists (Spring Boot JPA will also handle this)
CREATE TABLE IF NOT EXISTS todos (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO todos (title, description, completed) VALUES
    ('Learn Docker', 'Study Docker containerization and best practices', false),
    ('Setup Kubernetes', 'Deploy application to Kubernetes cluster', false),
    ('Configure Jenkins', 'Create CI/CD pipeline with Jenkins', false)
ON CONFLICT DO NOTHING;
