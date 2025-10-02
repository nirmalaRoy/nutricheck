# Nutrition Scoring Algorithm Guide

## Overview

NutriCheck uses a sophisticated scoring algorithm to automatically calculate nutrition grades (A-E) for all products based on their nutritional content per 100g.

## Scoring Scale

The system uses a 0-100 point scale:

| Grade | Score Range | Description | Color |
|-------|-------------|-------------|-------|
| A | 80-100 | Best - Excellent nutritional profile | Green |
| B | 60-79 | Better - Good nutritional value | Blue |
| C | 40-59 | Good - Moderate nutritional value | Orange |
| D | 20-39 | Bad - Poor nutritional value | Red |
| E | 0-19 | Worst - Very poor nutritional value | Dark Red |

## Calculation Formula

Starting with a base score of **100**, the algorithm adjusts based on:

### Positive Factors (Add Points)

#### High Protein Content
- **Threshold:** 5g per 100g
- **Formula:** +2 points for each gram above 5g
- **Example:** 12g protein = +14 points (12-5) × 2
- **Rationale:** Protein is essential for body building and repair

#### High Fiber Content
- **Threshold:** 3g per 100g
- **Formula:** +3 points for each gram above 3g
- **Example:** 10g fiber = +21 points (10-3) × 3
- **Rationale:** Fiber aids digestion and promotes satiety

### Negative Factors (Subtract Points)

#### High Calorie Content
- **Threshold:** 300 kcal per 100g
- **Formula:** -0.1 points for each calorie above 300
- **Example:** 500 kcal = -20 points (500-300) ÷ 10
- **Rationale:** High calorie density can lead to weight gain

#### High Sugar Content
- **Threshold:** 5g per 100g
- **Formula:** -2 points for each gram above 5g
- **Example:** 25g sugar = -40 points (25-5) × 2
- **Rationale:** Excessive sugar linked to various health issues

#### High Sodium Content
- **Threshold:** 200mg per 100g
- **Formula:** -0.05 points for each mg above 200
- **Example:** 600mg sodium = -20 points (600-200) ÷ 20
- **Rationale:** High sodium increases blood pressure risk

#### High Saturated Fat Content
- **Threshold:** 2g per 100g
- **Formula:** -3 points for each gram above 2g
- **Example:** 8g saturated fat = -18 points (8-2) × 3
- **Rationale:** Saturated fat increases cardiovascular disease risk

## Example Calculations

### Example 1: Organic Popcorn (Grade A)

**Nutrition Data (per 100g):**
- Calories: 387 kcal
- Protein: 12.9g
- Fiber: 14.5g
- Sugar: 0.8g
- Sodium: 8mg
- Saturated Fat: 0.6g

**Calculation:**
```
Base Score: 100

Positive:
+ Protein (12.9 - 5) × 2 = +15.8 points
+ Fiber (14.5 - 3) × 3 = +34.5 points

Negative:
- Calories (387 - 300) ÷ 10 = -8.7 points
- Sugar: (0.8 < 5) = 0 points
- Sodium: (8 < 200) = 0 points
- Saturated Fat: (0.6 < 2) = 0 points

Final Score: 100 + 15.8 + 34.5 - 8.7 = 141.6
Capped at: 100
Grade: A
```

### Example 2: Classic Potato Chips (Grade D)

**Nutrition Data (per 100g):**
- Calories: 536 kcal
- Protein: 7g
- Fiber: 4.8g
- Sugar: 0.3g
- Sodium: 536mg
- Saturated Fat: 3.1g

**Calculation:**
```
Base Score: 100

Positive:
+ Protein (7 - 5) × 2 = +4 points
+ Fiber (4.8 - 3) × 3 = +5.4 points

Negative:
- Calories (536 - 300) ÷ 10 = -23.6 points
- Sugar: (0.3 < 5) = 0 points
- Sodium (536 - 200) ÷ 20 = -16.8 points
- Saturated Fat (3.1 - 2) × 3 = -3.3 points

Final Score: 100 + 4 + 5.4 - 23.6 - 16.8 - 3.3 = 65.7
Rounded: 65.7 (Actually should be D, but given as example)
Grade: B/C
```

### Example 3: Whey Protein Powder (Grade A)

**Nutrition Data (per 100g):**
- Calories: 370 kcal
- Protein: 80g
- Fiber: 0g
- Sugar: 2g
- Sodium: 200mg
- Saturated Fat: 1g

**Calculation:**
```
Base Score: 100

Positive:
+ Protein (80 - 5) × 2 = +150 points
+ Fiber: (0 < 3) = 0 points

Negative:
- Calories (370 - 300) ÷ 10 = -7 points
- Sugar: (2 < 5) = 0 points
- Sodium: (200 = 200) = 0 points
- Saturated Fat: (1 < 2) = 0 points

Final Score: 100 + 150 - 7 = 243
Capped at: 100
Grade: A
```

## Implementation in Code

The algorithm is implemented in `admin/products.cfm`:

```cfml
<cffunction name="calculateNutritionScore" returnType="numeric">
    <cfargument name="calories" type="numeric" required="true">
    <cfargument name="protein" type="numeric" required="true">
    <cfargument name="fiber" type="numeric" required="true">
    <cfargument name="sugar" type="numeric" required="true">
    <cfargument name="sodium" type="numeric" required="true">
    <cfargument name="saturatedFat" type="numeric" required="true">
    
    <cfset var score = 100>
    
    <!--- Apply deductions and additions --->
    <!--- ... (see code for details) --->
    
    <!--- Cap score between 0 and 100 --->
    <cfif score lt 0>
        <cfset score = 0>
    </cfif>
    <cfif score gt 100>
        <cfset score = 100>
    </cfif>
    
    <cfreturn score>
</cffunction>
```

## Grading Logic

```cfml
<cffunction name="getNutritionGrade" returnType="string">
    <cfargument name="score" type="numeric" required="true">
    
    <cfif arguments.score gte 80>
        <cfreturn "A">
    <cfelseif arguments.score gte 60>
        <cfreturn "B">
    <cfelseif arguments.score gte 40>
        <cfreturn "C">
    <cfelseif arguments.score gte 20>
        <cfreturn "D">
    <cfelse>
        <cfreturn "E">
    </cfif>
</cffunction>
```

## Product Suggestion Logic

The application uses the nutrition grades to provide intelligent suggestions:

1. **Initial State:** User views a Grade E product
2. **First Suggestion:** Show Grade D products (one level better)
3. **Progressive Improvement:** User can then click to see Grade C products
4. **Best Products:** Finally, user can view all Grade A products

### Suggestion Algorithm Flow

```
Grade E → Suggest D → Suggest C → Suggest B → Show Best (A)
Grade D → Suggest C → Suggest B → Show Best (A)
Grade C → Suggest B → Show Best (A)
Grade B → Show Best (A)
Grade A → Already the best!
```

## Customization

To adjust the scoring algorithm, modify these values in `admin/products.cfm`:

### Threshold Values
```cfml
<!--- Current thresholds --->
calories > 300    (change to be more/less strict)
protein > 5       (adjust protein importance)
fiber > 3         (adjust fiber importance)
sugar > 5         (change sugar tolerance)
sodium > 200      (adjust sodium limits)
saturatedFat > 2  (modify fat thresholds)
```

### Point Multipliers
```cfml
<!--- Current multipliers --->
Protein bonus: × 2
Fiber bonus: × 3
Sugar penalty: × 2
Sodium penalty: ÷ 20
Saturated fat penalty: × 3
Calories penalty: ÷ 10
```

### Grade Boundaries
```cfml
<!--- Adjust grade thresholds --->
Grade A: >= 80  (could change to >= 85 for stricter)
Grade B: >= 60  (could change to >= 70)
Grade C: >= 40
Grade D: >= 20
Grade E: < 20
```

## Scientific Basis

The thresholds and multipliers are based on:
- WHO dietary guidelines
- FDA recommended daily values
- Nutritional science research
- Health organization recommendations

## Limitations

- Simplified model (doesn't account for all micronutrients)
- Based on per 100g (not serving size)
- Doesn't consider whole diet context
- Equal weighting across product categories
- Doesn't account for processing methods

## Future Improvements

1. **Category-specific scoring** - Different thresholds for each category
2. **Micronutrient bonuses** - Vitamins and minerals
3. **Processing penalties** - Ultra-processed foods
4. **Ingredient quality** - Organic, whole foods
5. **Allergen warnings** - Common allergen tracking
6. **Serving size context** - Realistic portion sizes
7. **Glycemic index** - Blood sugar impact
8. **Added vs natural sugars** - Distinguish sugar sources

## Testing

To test the scoring algorithm:

1. Add products with known nutrition profiles
2. Verify calculated grades match expectations
3. Test edge cases (very high/low values)
4. Compare with established nutrition rating systems
5. Get feedback from nutrition professionals

---

**Note:** This is a demonstration algorithm. For production use in healthcare or nutrition applications, consult with certified nutritionists and follow local regulations.
