# NutriCheck Database Files

This folder contains all database-related files for the NutriCheck application.

## Files

### `nutricheck_schema.sql`
- **Purpose**: Complete NutriCheck database schema with sample data
- **Description**: Full database setup including tables for users, products, categories, nutrition data, product ratings, and sample data
- **Usage**: Run this to create the complete database structure with test data

### `calculate_grade.sql`
- **Purpose**: Grade recalculation script using Nutri-Score formula
- **Description**: SQL stored procedure to recalculate all product grades based on nutritional data
- **Usage**: Run this to update existing product grades using the Nutri-Score algorithm

## Database Name
All scripts use the database name: `nutricheck`

## Usage Instructions

1. **Initial Setup**: Run `nutricheck_schema.sql` for complete setup with sample data
2. **Grade Recalculation**: Run `calculate_grade.sql` to recalculate all product grades

## Nutri-Score Formula
The grade calculation follows the Nutri-Score algorithm:
- Negative Points = Calories + Sugar + Fat
- Positive Points = Fiber + Protein  
- Nutritional Score = Negative Points - Positive Points
- Grade: A (≤-1), B (0-2), C (3-10), D (11-18), E (≥19)
