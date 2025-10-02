-- NutriCheck Database Grade Recalculation Script
-- This script recalculates all product grades using the Nutri-Score formula
-- Run this after implementing the NutriScoreCalculator.cfc component

USE nutricheck;

-- Show current grade distribution before update
SELECT 'BEFORE UPDATE:' as status, nutrition_grade, COUNT(*) as count 
FROM product_ratings 
GROUP BY nutrition_grade 
ORDER BY nutrition_grade;

-- Create a temporary stored procedure to calculate Nutri-Score grades
-- This mirrors the logic from the NutriScoreCalculator.cfc component

DELIMITER //
CREATE PROCEDURE RecalculateNutriCheckGrades()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE product_id INT;
    DECLARE product_name VARCHAR(100);
    DECLARE calories DECIMAL(8,2);
    DECLARE sugar DECIMAL(8,2);
    DECLARE fat DECIMAL(8,2);
    DECLARE fiber DECIMAL(8,2);
    DECLARE protein DECIMAL(8,2);
    
    -- Points variables
    DECLARE calories_points INT DEFAULT 0;
    DECLARE sugar_points INT DEFAULT 0;
    DECLARE fat_points INT DEFAULT 0;
    DECLARE fiber_points INT DEFAULT 0;
    DECLARE protein_points INT DEFAULT 0;
    DECLARE negative_points INT DEFAULT 0;
    DECLARE positive_points INT DEFAULT 0;
    DECLARE nutritional_score INT DEFAULT 0;
    DECLARE calculated_grade CHAR(1);
    
    -- Cursor to iterate through all products with nutrition data
    DECLARE product_cursor CURSOR FOR 
        SELECT 
            p.product_id, p.product_name,
            n.calories_per_100g, n.sugar_g, n.fat_g, n.fiber_g, n.protein_g
        FROM products p
        JOIN nutrition_data n ON p.product_id = n.product_id
        WHERE n.calories_per_100g IS NOT NULL;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN product_cursor;
    
    products_loop: LOOP
        FETCH product_cursor INTO product_id, product_name, calories, sugar, fat, fiber, protein;
        IF done THEN
            LEAVE products_loop;
        END IF;
        
        -- Reset points for each product
        SET calories_points = 0, sugar_points = 0, fat_points = 0, fiber_points = 0, protein_points = 0;
        SET calculated_grade = 'E'; -- Default grade
        
        -- Calculate Calories Points
        CASE 
            WHEN calories <= 80 THEN SET calories_points = 0;
            WHEN calories <= 160 THEN SET calories_points = 1;
            WHEN calories <= 240 THEN SET calories_points = 2;
            WHEN calories <= 320 THEN SET calories_points = 3;
            WHEN calories <= 400 THEN SET calories_points = 4;
            WHEN calories <= 480 THEN SET calories_points = 5;
            WHEN calories <= 560 THEN SET calories_points = 6;
            WHEN calories <= 640 THEN SET calories_points = 7;
            WHEN calories <= 720 THEN SET calories_points = 8;
            WHEN calories <= 800 THEN SET calories_points = 9;
            ELSE SET calories_points = 10;
        END CASE;
        
        -- Calculate Sugar Points
        CASE
            WHEN sugar <= 4.5 THEN SET sugar_points = 0;
            WHEN sugar <= 9 THEN SET sugar_points = 1;
            WHEN sugar <= 13.5 THEN SET sugar_points = 2;
            WHEN sugar <= 18 THEN SET sugar_points = 3;
            WHEN sugar <= 22.5 THEN SET sugar_points = 4;
            WHEN sugar <= 27 THEN SET sugar_points = 5;
            WHEN sugar <= 31 THEN SET sugar_points = 6;
            WHEN sugar <= 36 THEN SET sugar_points = 7;
            WHEN sugar <= 40 THEN SET sugar_points = 8;
            WHEN sugar <= 45 THEN SET sugar_points = 9;
            ELSE SET sugar_points = 10;
        END CASE;
        
        -- Calculate Fat Points
        CASE
            WHEN fat <= 1 THEN SET fat_points = 0;
            WHEN fat <= 2 THEN SET fat_points = 1;
            WHEN fat <= 3 THEN SET fat_points = 2;
            WHEN fat <= 4 THEN SET fat_points = 3;
            WHEN fat <= 5 THEN SET fat_points = 4;
            WHEN fat <= 6 THEN SET fat_points = 5;
            WHEN fat <= 7 THEN SET fat_points = 6;
            WHEN fat <= 8 THEN SET fat_points = 7;
            WHEN fat <= 9 THEN SET fat_points = 8;
            WHEN fat <= 10 THEN SET fat_points = 9;
            ELSE SET fat_points = 10;
        END CASE;
        
        -- Calculate Fiber Points
        CASE
            WHEN fiber <= 0.9 THEN SET fiber_points = 0;
            WHEN fiber <= 1.9 THEN SET fiber_points = 1;
            WHEN fiber <= 2.8 THEN SET fiber_points = 2;
            WHEN fiber <= 3.7 THEN SET fiber_points = 3;
            WHEN fiber <= 4.7 THEN SET fiber_points = 4;
            ELSE SET fiber_points = 5;
        END CASE;
        
        -- Calculate Protein Points
        CASE
            WHEN protein <= 1.6 THEN SET protein_points = 0;
            WHEN protein <= 3.2 THEN SET protein_points = 1;
            WHEN protein <= 4.8 THEN SET protein_points = 2;
            WHEN protein <= 6.4 THEN SET protein_points = 3;
            WHEN protein <= 8.0 THEN SET protein_points = 4;
            ELSE SET protein_points = 5;
        END CASE;
        
        -- Calculate final score
        SET negative_points = calories_points + sugar_points + fat_points;
        SET positive_points = fiber_points + protein_points;
        SET nutritional_score = negative_points - positive_points;
        
        -- Determine grade
        CASE
            WHEN nutritional_score <= -1 THEN SET calculated_grade = 'A';
            WHEN nutritional_score >= 0 AND nutritional_score <= 2 THEN SET calculated_grade = 'B';
            WHEN nutritional_score >= 3 AND nutritional_score <= 10 THEN SET calculated_grade = 'C';
            WHEN nutritional_score >= 11 AND nutritional_score <= 18 THEN SET calculated_grade = 'D';
            ELSE SET calculated_grade = 'E';
        END CASE;
        
        -- Update the product rating
        UPDATE product_ratings 
        SET nutrition_grade = calculated_grade, 
            nutrition_score = nutritional_score,
            calculated_at = NOW() 
        WHERE product_id = product_id;
        
        -- Output progress
        SELECT CONCAT('Updated product "', product_name, '" (ID: ', product_id, ') with grade ', calculated_grade, ' (Score: ', nutritional_score, ')') as progress_message;
        
    END LOOP;
    
    CLOSE product_cursor;
END //
DELIMITER ;

-- Execute the recalculation
CALL RecalculateNutriCheckGrades();

-- Show final grade distribution after update  
SELECT 'AFTER UPDATE:' as status, nutrition_grade, COUNT(*) as count 
FROM product_ratings 
GROUP BY nutrition_grade 
ORDER BY nutrition_grade;

-- Drop the temporary procedure
DROP PROCEDURE RecalculateNutriCheckGrades;

-- Final summary
SELECT 
    'RECALCULATION COMPLETE' as status,
    COUNT(*) as total_products_updated,
    NOW() as completion_time
FROM product_ratings 
WHERE calculated_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE);

-- Show detailed results for verification
SELECT 
    p.product_name,
    p.brand,
    c.category_name,
    n.calories_per_100g,
    n.sugar_g,
    n.fat_g,
    n.fiber_g,
    n.protein_g,
    r.nutrition_grade,
    r.nutrition_score,
    r.calculated_at
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN nutrition_data n ON p.product_id = n.product_id
JOIN product_ratings r ON p.product_id = r.product_id
ORDER BY r.nutrition_score ASC, p.product_name;
