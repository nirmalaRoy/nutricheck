<cfcomponent displayname="NutriScoreCalculator" hint="Calculates Nutri-Score grades based on nutritional data">
    
    <cffunction name="calculateGrade" access="public" returntype="struct" hint="Calculate Nutri-Score grade based on nutritional data">
        <cfargument name="calories" type="numeric" required="true" hint="Calories per 100g">
        <cfargument name="sugar" type="numeric" required="true" hint="Sugar per 100g">
        <cfargument name="fat" type="numeric" required="true" hint="Fat per 100g">
        <cfargument name="fiber" type="numeric" required="true" hint="Fiber per 100g">
        <cfargument name="protein" type="numeric" required="true" hint="Protein per 100g">
        
        <cfscript>
            // Initialize points
            var caloriesPoints = 0;
            var sugarPoints = 0;
            var fatPoints = 0;
            var fiberPoints = 0;
            var proteinPoints = 0;
            var negativePoints = 0;
            var positivePoints = 0;
            var nutritionalScore = 0;
            var grade = "E";
            
            // Calculate Calories Points
            if (arguments.calories <= 80) {
                caloriesPoints = 0;
            } else if (arguments.calories <= 160) {
                caloriesPoints = 1;
            } else if (arguments.calories <= 240) {
                caloriesPoints = 2;
            } else if (arguments.calories <= 320) {
                caloriesPoints = 3;
            } else if (arguments.calories <= 400) {
                caloriesPoints = 4;
            } else if (arguments.calories <= 480) {
                caloriesPoints = 5;
            } else if (arguments.calories <= 560) {
                caloriesPoints = 6;
            } else if (arguments.calories <= 640) {
                caloriesPoints = 7;
            } else if (arguments.calories <= 720) {
                caloriesPoints = 8;
            } else if (arguments.calories <= 800) {
                caloriesPoints = 9;
            } else {
                caloriesPoints = 10;
            }
            
            // Calculate Sugar Points
            if (arguments.sugar <= 4.5) {
                sugarPoints = 0;
            } else if (arguments.sugar <= 9) {
                sugarPoints = 1;
            } else if (arguments.sugar <= 13.5) {
                sugarPoints = 2;
            } else if (arguments.sugar <= 18) {
                sugarPoints = 3;
            } else if (arguments.sugar <= 22.5) {
                sugarPoints = 4;
            } else if (arguments.sugar <= 27) {
                sugarPoints = 5;
            } else if (arguments.sugar <= 31) {
                sugarPoints = 6;
            } else if (arguments.sugar <= 36) {
                sugarPoints = 7;
            } else if (arguments.sugar <= 40) {
                sugarPoints = 8;
            } else if (arguments.sugar <= 45) {
                sugarPoints = 9;
            } else {
                sugarPoints = 10;
            }
            
            // Calculate Fat Points
            if (arguments.fat <= 1) {
                fatPoints = 0;
            } else if (arguments.fat <= 2) {
                fatPoints = 1;
            } else if (arguments.fat <= 3) {
                fatPoints = 2;
            } else if (arguments.fat <= 4) {
                fatPoints = 3;
            } else if (arguments.fat <= 5) {
                fatPoints = 4;
            } else if (arguments.fat <= 6) {
                fatPoints = 5;
            } else if (arguments.fat <= 7) {
                fatPoints = 6;
            } else if (arguments.fat <= 8) {
                fatPoints = 7;
            } else if (arguments.fat <= 9) {
                fatPoints = 8;
            } else if (arguments.fat <= 10) {
                fatPoints = 9;
            } else {
                fatPoints = 10;
            }
            
            // Calculate Fiber Points
            if (arguments.fiber <= 0.9) {
                fiberPoints = 0;
            } else if (arguments.fiber <= 1.9) {
                fiberPoints = 1;
            } else if (arguments.fiber <= 2.8) {
                fiberPoints = 2;
            } else if (arguments.fiber <= 3.7) {
                fiberPoints = 3;
            } else if (arguments.fiber <= 4.7) {
                fiberPoints = 4;
            } else {
                fiberPoints = 5;
            }
            
            // Calculate Protein Points
            if (arguments.protein <= 1.6) {
                proteinPoints = 0;
            } else if (arguments.protein <= 3.2) {
                proteinPoints = 1;
            } else if (arguments.protein <= 4.8) {
                proteinPoints = 2;
            } else if (arguments.protein <= 6.4) {
                proteinPoints = 3;
            } else if (arguments.protein <= 8.0) {
                proteinPoints = 4;
            } else {
                proteinPoints = 5;
            }
            
            // Calculate final score
            negativePoints = caloriesPoints + sugarPoints + fatPoints;
            positivePoints = fiberPoints + proteinPoints;
            nutritionalScore = negativePoints - positivePoints;
            
            // Determine grade
            if (nutritionalScore <= -1) {
                grade = "A";
            } else if (nutritionalScore >= 0 && nutritionalScore <= 2) {
                grade = "B";
            } else if (nutritionalScore >= 3 && nutritionalScore <= 10) {
                grade = "C";
            } else if (nutritionalScore >= 11 && nutritionalScore <= 18) {
                grade = "D";
            } else {
                grade = "E";
            }
            
            // Return detailed results
            return {
                "grade" = grade,
                "nutritionalScore" = nutritionalScore,
                "negativePoints" = negativePoints,
                "positivePoints" = positivePoints,
                "breakdown" = {
                    "caloriesPoints" = caloriesPoints,
                    "sugarPoints" = sugarPoints,
                    "fatPoints" = fatPoints,
                    "fiberPoints" = fiberPoints,
                    "proteinPoints" = proteinPoints
                }
            };
        </cfscript>
    </cffunction>
    
    <cffunction name="calculateGradeFromNutritionData" access="public" returntype="struct" hint="Calculate grade from nutrition data struct">
        <cfargument name="nutritionData" type="struct" required="true" hint="Struct containing nutrition data">
        
        <cfscript>
            // Extract values with defaults
            var calories = structKeyExists(arguments.nutritionData, "calories_per_100g") ? arguments.nutritionData.calories_per_100g : 0;
            var sugar = structKeyExists(arguments.nutritionData, "sugar_g") ? arguments.nutritionData.sugar_g : 0;
            var fat = structKeyExists(arguments.nutritionData, "fat_g") ? arguments.nutritionData.fat_g : 0;
            var fiber = structKeyExists(arguments.nutritionData, "fiber_g") ? arguments.nutritionData.fiber_g : 0;
            var protein = structKeyExists(arguments.nutritionData, "protein_g") ? arguments.nutritionData.protein_g : 0;
            
            // Call the main calculation function
            return calculateGrade(calories, sugar, fat, fiber, protein);
        </cfscript>
    </cffunction>
    
    <cffunction name="getGradeDescription" access="public" returntype="string" hint="Get description for a grade">
        <cfargument name="grade" type="string" required="true" hint="Grade letter (A, B, C, D, E)">
        
        <cfscript>
            switch (arguments.grade) {
                case "A":
                    return "Excellent nutritional quality";
                case "B":
                    return "Good nutritional quality";
                case "C":
                    return "Average nutritional quality";
                case "D":
                    return "Poor nutritional quality";
                case "E":
                    return "Very poor nutritional quality";
                default:
                    return "Unknown grade";
            }
        </cfscript>
    </cffunction>
    
    <cffunction name="getGradeColor" access="public" returntype="string" hint="Get color code for a grade">
        <cfargument name="grade" type="string" required="true" hint="Grade letter (A, B, C, D, E)">
        
        <cfscript>
            switch (arguments.grade) {
                case "A":
                    return "00B04F"; // Green
                case "B":
                    return "85BB2F"; // Light Green
                case "C":
                    return "F9D71C"; // Yellow
                case "D":
                    return "FF8C00"; // Orange
                case "E":
                    return "E63E31"; // Red
                default:
                    return "CCCCCC"; // Gray
            }
        </cfscript>
    </cffunction>
    
</cfcomponent>
