# NutriCheck Nutri-Score Implementation

## Overview
This document describes the implementation of the Nutri-Score grade calculation system in the NutriCheck application. The Nutri-Score is a nutritional rating system that grades food products from A (best) to E (worst) based on their nutritional composition.

## Formula
The Nutri-Score calculation follows this formula:

```
NegativePoints = CaloriesPoints + SugarPoints + FatPoints
PositivePoints = FiberPoints + ProteinPoints
NutritionalScore = NegativePoints - PositivePoints
```

### Grade Mapping
- **A**: NutritionalScore ≤ -1 (Excellent nutritional quality)
- **B**: 0 ≤ NutritionalScore ≤ 2 (Good nutritional quality)
- **C**: 3 ≤ NutritionalScore ≤ 10 (Average nutritional quality)
- **D**: 11 ≤ NutritionalScore ≤ 18 (Poor nutritional quality)
- **E**: NutritionalScore ≥ 19 (Very poor nutritional quality)

## Components

### 1. NutriScoreCalculator.cfc
Location: `/components/NutriScoreCalculator.cfc`

**Main Functions:**
- `calculateGrade(calories, sugar, fat, fiber, protein)` - Calculate grade from individual values
- `calculateGradeFromNutritionData(nutritionData)` - Calculate from nutrition data struct
- `getGradeDescription(grade)` - Get human-readable description
- `getGradeColor(grade)` - Get color code for UI display

**Usage Example:**
```cfml
<cfset calculator = createObject("component", "components.NutriScoreCalculator")>
<cfset result = calculator.calculateGrade(387, 0.8, 4.5, 14.5, 12.9)>
<!--- Returns: {grade: "A", nutritionalScore: -2, ...} --->
```

### 2. Products API Enhancement
Location: `/api/products.cfm`

**New Actions:**
- `calculate_grade` - Calculate grade for specific nutrition values
- `recalculate_all` - Recalculate all product grades in database

**API Endpoints:**
```
GET /api/products.cfm?action=calculate_grade&calories=387&sugar=0.8&fat=4.5&fiber=14.5&protein=12.9
GET /api/products.cfm?action=recalculate_all
GET /calculate_grade.cfm?calories=387&sugar=0.8&fat=4.5&fiber=14.5&protein=12.9
```

### 3. Test Calculator
Location: `/test_calculator.cfm`

Tests the calculator with sample data from the database and returns formatted results showing the calculation breakdown.

### 4. Database Recalculation Script
Location: `/recalculate_grades.sql`

SQL stored procedure that recalculates all product grades using the Nutri-Score formula directly in the database.

## Points Calculation Tables

### Calories Points (per 100g)
| Range | Points |
|-------|--------|
| ≤ 80 | 0 |
| 81-160 | 1 |
| 161-240 | 2 |
| 241-320 | 3 |
| 321-400 | 4 |
| 401-480 | 5 |
| 481-560 | 6 |
| 561-640 | 7 |
| 641-720 | 8 |
| 721-800 | 9 |
| > 800 | 10 |

### Sugar Points (per 100g)
| Range | Points |
|-------|--------|
| ≤ 4.5 | 0 |
| 4.6-9 | 1 |
| 9.1-13.5 | 2 |
| 13.6-18 | 3 |
| 18.1-22.5 | 4 |
| 22.6-27 | 5 |
| 27.1-31 | 6 |
| 31.1-36 | 7 |
| 36.1-40 | 8 |
| 40.1-45 | 9 |
| > 45 | 10 |

### Fat Points (per 100g)
| Range | Points |
|-------|--------|
| ≤ 1 | 0 |
| 1.1-2 | 1 |
| 2.1-3 | 2 |
| 3.1-4 | 3 |
| 4.1-5 | 4 |
| 5.1-6 | 5 |
| 6.1-7 | 6 |
| 7.1-8 | 7 |
| 8.1-9 | 8 |
| 9.1-10 | 9 |
| > 10 | 10 |

### Fiber Points (per 100g)
| Range | Points |
|-------|--------|
| ≤ 0.9 | 0 |
| 1.0-1.9 | 1 |
| 2.0-2.8 | 2 |
| 2.9-3.7 | 3 |
| 3.8-4.7 | 4 |
| > 4.7 | 5 |

### Protein Points (per 100g)
| Range | Points |
|-------|--------|
| ≤ 1.6 | 0 |
| 1.7-3.2 | 1 |
| 3.3-4.8 | 2 |
| 4.9-6.4 | 3 |
| 6.5-8.0 | 4 |
| > 8.0 | 5 |

## Sample Results

Based on the test data, here are the calculated grades:

1. **Organic Popcorn**: Grade A (Score: -2)
   - High fiber (14.5g) and protein (12.9g) = 10 positive points
   - Moderate calories (387) and fat (4.5g) = 8 negative points
   - Net score: -2 (Excellent)

2. **Classic Potato Chips**: Grade C (Score: 7)
   - High fat (34g) and calories (536) = 16 negative points
   - Moderate fiber (4.8g) and protein (7g) = 9 positive points
   - Net score: 7 (Average)

3. **Dark Chocolate Bar**: Grade D (Score: 13)
   - Very high fat (42.6g), calories (598), and sugar (24.2g) = 22 negative points
   - Good fiber (10.9g) and protein (7.8g) = 9 positive points
   - Net score: 13 (Poor)

4. **Whey Protein Powder**: Grade C (Score: 3)
   - Very high protein (80g) = 5 positive points
   - Moderate calories (370) and fat (5g) = 8 negative points
   - Net score: 3 (Average)

5. **Whole Grain Biscuits**: Grade C (Score: 10)
   - High fat (12g), calories (420), and sugar (20g) = 19 negative points
   - Good fiber (8g) and protein (8g) = 9 positive points
   - Net score: 10 (Average)

## Usage Instructions

### 1. Test the Calculator
```bash
curl "http://localhost:8501/test_calculator.cfm"
```

### 2. Calculate Individual Grade
```bash
curl "http://localhost:8501/api/products.cfm?action=calculate_grade&calories=387&sugar=0.8&fat=4.5&fiber=14.5&protein=12.9"
```

### 2a. Calculate Grade (Direct Page)
```bash
curl "http://localhost:8501/calculate_grade.cfm?calories=387&sugar=0.8&fat=4.5&fiber=14.5&protein=12.9"
```

### 3. Recalculate All Database Grades
```bash
curl "http://localhost:8501/recalculate_grades.cfm?confirm=true"
```

### 4. Run SQL Script (if database access available)
```sql
SOURCE /path/to/recalculate_grades.sql;
```

## Integration Notes

- The calculator is integrated into the existing products API
- Grades are stored in the `product_ratings` table
- The system maintains backward compatibility with existing grade data
- Color codes are provided for UI integration
- All calculations are based on per-100g values

## Future Enhancements

1. **Category-specific adjustments** - Different scoring for different food categories
2. **Portion size calculations** - Convert scores based on actual serving sizes
3. **Additional nutrients** - Include sodium, saturated fat, etc. in calculations
4. **User preferences** - Allow users to weight different nutritional factors
5. **Historical tracking** - Track grade changes over time for products

## Troubleshooting

### Common Issues:
1. **Datasource not found** - Ensure the "nutricheck" datasource is configured in ColdFusion
2. **Component not found** - Verify the NutriScoreCalculator.cfc is in the components folder
3. **Permission errors** - Check file permissions for the ColdFusion web root
4. **Database connection** - Ensure MySQL is running and accessible

### Debug Mode:
Enable ColdFusion debugging to see detailed error information in the logs.
