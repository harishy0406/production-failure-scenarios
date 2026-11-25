-- Initial database schema and seed data for simulation
CREATE DATABASE production_db;

\c production_db;

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (name, email) VALUES
    ('Alice Martin', 'alice@example.com'),
    ('Bob Stone', 'bob@example.com'),
    ('Charlie Vance', 'charlie@example.com');

INSERT INTO orders (customer_id, amount, status) VALUES
    (1, 149.99, 'completed'),
    (1, 49.50, 'completed'),
    (2, 890.00, 'processing'),
    (3, 25.00, 'completed');
