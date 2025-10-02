-- NutriCheck Database Schema (Corrected)
-- Updated to use correct database name and table structure

USE nutricheck;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_username (username)
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (category_name)
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    brand VARCHAR(50),
    category_id INT,
    description TEXT,
    image_url VARCHAR(255),
    price DECIMAL(10,2),
    serving_size VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_brand (brand),
    INDEX idx_name (product_name)
);

-- Nutrition data table
CREATE TABLE IF NOT EXISTS nutrition_data (
    nutrition_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    calories_per_100g DECIMAL(8,2),
    protein_g DECIMAL(8,2),
    carbs_g DECIMAL(8,2),
    fat_g DECIMAL(8,2),
    fiber_g DECIMAL(8,2),
    sugar_g DECIMAL(8,2),
    sodium_mg DECIMAL(8,2),
    saturated_fat_g DECIMAL(8,2),
    trans_fat_g DECIMAL(8,2),
    cholesterol_mg DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product (product_id)
);

-- Product ratings table (for NutriScore grades)
CREATE TABLE IF NOT EXISTS product_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    nutrition_grade ENUM('A', 'B', 'C', 'D', 'E') NOT NULL,
    nutrition_score DECIMAL(5,2),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_grade (nutrition_grade)
);

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Password reset tokens table
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_token (token),
    INDEX idx_email (email),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
);

-- Insert default categories
INSERT INTO categories (category_name, description) VALUES
('Popcorn', 'Various types of popcorn products'),
('Chips', 'Potato chips and similar snacks'),
('Chocolates', 'Chocolate bars and confections'),
('Protein Supplements', 'Protein powders and supplements'),
('Biscuits', 'Cookies and biscuit products'),
('Cereals', 'Breakfast cereals and grains'),
('Nuts', 'Nuts and nut-based products'),
('Energy Bars', 'Energy and protein bars'),
('Drinks', 'Beverages and liquid nutrition')
ON DUPLICATE KEY UPDATE 
    description = VALUES(description);

-- Insert default admin user (password should be changed in production)
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES
('admin', 'admin@nutricheck.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Admin', 'User', 'admin'),
('john_doe', 'john@example.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'John', 'Doe', 'user')
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email);

-- Insert sample products
INSERT INTO products (product_name, brand, category_id, description, price, serving_size) VALUES
('Organic Popcorn', 'Healthy Choice', 1, 'Air-popped organic popcorn', 4.99, '100g'),
('Classic Potato Chips', 'Crunchy Co', 2, 'Traditional salted potato chips', 3.49, '100g'),
('Dark Chocolate Bar', 'Premium Choc', 3, '70% dark chocolate bar', 5.99, '100g'),
('Whey Protein Powder', 'FitLife', 4, 'Vanilla whey protein isolate', 29.99, '30g'),
('Whole Grain Biscuits', 'Healthy Bites', 5, 'Whole grain digestive biscuits', 2.99, '100g')
ON DUPLICATE KEY UPDATE 
    product_name = VALUES(product_name),
    brand = VALUES(brand);

-- Insert sample nutrition data
INSERT INTO nutrition_data (product_id, calories_per_100g, protein_g, carbs_g, fat_g, fiber_g, sugar_g, sodium_mg, saturated_fat_g, trans_fat_g, cholesterol_mg) VALUES
(1, 387, 12.9, 77.8, 4.5, 14.5, 0.8, 8, 0.6, 0, 0),
(2, 536, 7, 53, 34, 4.8, 0.3, 536, 3.1, 0, 0),
(3, 598, 7.8, 45.9, 42.6, 10.9, 24.2, 20, 24.2, 0, 0),
(4, 370, 80, 5, 5, 0, 2, 200, 1, 0, 10),
(5, 420, 8, 70, 12, 8, 20, 400, 2, 0, 0)
ON DUPLICATE KEY UPDATE 
    calories_per_100g = VALUES(calories_per_100g),
    protein_g = VALUES(protein_g);

-- Insert sample product ratings (will be recalculated using NutriScore)
INSERT INTO product_ratings (product_id, nutrition_grade, nutrition_score) VALUES
(1, 'A', -2.0),
(2, 'C', 7.0),
(3, 'D', 13.0),
(4, 'C', 3.0),
(5, 'C', 10.0)
ON DUPLICATE KEY UPDATE 
    nutrition_grade = VALUES(nutrition_grade),
    nutrition_score = VALUES(nutrition_score);

-- Create database connection test table
CREATE TABLE IF NOT EXISTS db_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    test_message VARCHAR(255) DEFAULT 'Database connection successful',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO db_test (test_message) VALUES ('NutriCheck schema initialized successfully')
ON DUPLICATE KEY UPDATE test_message = VALUES(test_message);
