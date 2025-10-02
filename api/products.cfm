<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="url.action" default="list">
<cfparam name="url.search" default="">
<cfparam name="url.categoryId" default="0">
<cfparam name="url.grade" default="">
<cfparam name="url.productId" default="0">

<cftry>
    <!--- Instantiate NutriScore Calculator (only for actions that need it) --->
    <cfif url.action eq "calculate_grade" or url.action eq "recalculate_all">
        <cfset calculator = createObject("component", "components.NutriScoreCalculator")>
    </cfif>

<cfif url.action eq "list" or url.action eq "search">
    <!--- List/Search Products --->
    <cfquery name="getProducts" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name, p.brand, p.description, 
            p.price, p.serving_size,
            c.category_name,
            n.calories_per_100g, n.protein_g, n.carbs_g, n.fat_g, 
            n.fiber_g, n.sugar_g, n.sodium_mg, n.saturated_fat_g,
            r.nutrition_grade, r.nutrition_score
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN nutrition_data n ON p.product_id = n.product_id
        LEFT JOIN product_ratings r ON p.product_id = r.product_id
        WHERE 1=1
        <cfif len(trim(url.search))>
            AND (p.product_name LIKE <cfqueryparam value="%#url.search#%" cfsqltype="cf_sql_varchar">
            OR p.brand LIKE <cfqueryparam value="%#url.search#%" cfsqltype="cf_sql_varchar">
            OR c.category_name LIKE <cfqueryparam value="%#url.search#%" cfsqltype="cf_sql_varchar">)
        </cfif>
        <cfif val(url.categoryId) gt 0>
            AND p.category_id = <cfqueryparam value="#url.categoryId#" cfsqltype="cf_sql_integer">
        </cfif>
        <cfif len(trim(url.grade))>
            AND r.nutrition_grade = <cfqueryparam value="#url.grade#" cfsqltype="cf_sql_varchar">
        </cfif>
        ORDER BY r.nutrition_score DESC, p.product_name
    </cfquery>
    
    <cfset products = []>
    <cfloop query="getProducts">
        <cfset productData = {
            "productId" = product_id,
            "productName" = product_name,
            "brand" = brand,
            "description" = description,
            "price" = price,
            "servingSize" = serving_size,
            "categoryName" = category_name,
            "nutrition" = {
                "calories" = calories_per_100g,
                "protein" = protein_g,
                "carbs" = carbs_g,
                "fat" = fat_g,
                "fiber" = fiber_g,
                "sugar" = sugar_g,
                "sodium" = sodium_mg,
                "saturatedFat" = saturated_fat_g
            },
            "nutritionGrade" = nutrition_grade,
            "nutritionScore" = nutrition_score
        }>
        <cfset arrayAppend(products, productData)>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "products" = products,
        "count" = arrayLen(products)
    }>
    
<cfelseif url.action eq "getSuggestions">
    <!--- Get Better Product Suggestions --->
    <cfparam name="url.currentGrade" default="E">
    <cfparam name="url.categoryName" default="">
    
    <!--- Determine target grade --->
    <cfset targetGrade = "">
    <cfswitch expression="#url.currentGrade#">
        <cfcase value="E">
            <cfset targetGrade = "D">
        </cfcase>
        <cfcase value="D">
            <cfset targetGrade = "C">
        </cfcase>
        <cfcase value="C">
            <cfset targetGrade = "B">
        </cfcase>
        <cfcase value="B">
            <cfset targetGrade = "A">
        </cfcase>
        <cfdefaultcase>
            <cfset targetGrade = "A">
        </cfdefaultcase>
    </cfswitch>
    
    <cfquery name="getSuggestions" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name, p.brand, p.price,
            c.category_name,
            r.nutrition_grade, r.nutrition_score
        FROM products p
        JOIN categories c ON p.category_id = c.category_id
        JOIN product_ratings r ON p.product_id = r.product_id
        WHERE c.category_name = <cfqueryparam value="#url.categoryName#" cfsqltype="cf_sql_varchar">
        AND r.nutrition_grade = <cfqueryparam value="#targetGrade#" cfsqltype="cf_sql_varchar">
        AND p.product_id != <cfqueryparam value="#url.productId#" cfsqltype="cf_sql_integer">
        ORDER BY r.nutrition_score DESC
        LIMIT 5
    </cfquery>
    
    <cfset suggestions = []>
    <cfloop query="getSuggestions">
        <cfset suggestionData = {
            "productId" = product_id,
            "productName" = product_name,
            "brand" = brand,
            "price" = price,
            "categoryName" = category_name,
            "nutritionGrade" = nutrition_grade,
            "nutritionScore" = nutrition_score
        }>
        <cfset arrayAppend(suggestions, suggestionData)>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "suggestions" = suggestions,
        "targetGrade" = targetGrade,
        "message" = "Try these " & targetGrade & " grade products instead!"
    }>
    
<cfelseif url.action eq "getBest">
    <!--- Get Best Products in Category --->
    <cfparam name="url.categoryName" default="">
    
    <cfquery name="getBestProducts" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name, p.brand, p.price,
            c.category_name,
            n.calories_per_100g, n.protein_g, n.sugar_g, n.sodium_mg,
            r.nutrition_grade, r.nutrition_score
        FROM products p
        JOIN categories c ON p.category_id = c.category_id
        JOIN nutrition_data n ON p.product_id = n.product_id
        JOIN product_ratings r ON p.product_id = r.product_id
        WHERE c.category_name = <cfqueryparam value="#url.categoryName#" cfsqltype="cf_sql_varchar">
        AND r.nutrition_grade = 'A'
        AND p.product_id != <cfqueryparam value="#url.productId#" cfsqltype="cf_sql_integer">
        ORDER BY r.nutrition_score DESC
        LIMIT 5
    </cfquery>
    
    <cfset bestProducts = []>
    <cfloop query="getBestProducts">
        <cfset productData = {
            "productId" = product_id,
            "productName" = product_name,
            "brand" = brand,
            "price" = price,
            "categoryName" = category_name,
            "nutrition" = {
                "calories" = calories_per_100g,
                "protein" = protein_g,
                "sugar" = sugar_g,
                "sodium" = sodium_mg
            },
            "nutritionGrade" = nutrition_grade,
            "nutritionScore" = nutrition_score
        }>
        <cfset arrayAppend(bestProducts, productData)>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "products" = bestProducts,
        "message" = "These are the best " & url.categoryName & " products!"
    }>
    
<cfelseif url.action eq "calculate_grade">
    <!--- Calculate Nutri-Score Grade --->
    <cfparam name="url.calories" default="0">
    <cfparam name="url.sugar" default="0">
    <cfparam name="url.fat" default="0">
    <cfparam name="url.fiber" default="0">
    <cfparam name="url.protein" default="0">
    
    <cfscript>
        // Calculate grade using the NutriScore calculator
        gradeResult = calculator.calculateGrade(
            val(url.calories),
            val(url.sugar),
            val(url.fat),
            val(url.fiber),
            val(url.protein)
        );
        
        // Add additional information
        gradeResult.gradeDescription = calculator.getGradeDescription(gradeResult.grade);
        gradeResult.gradeColor = calculator.getGradeColor(gradeResult.grade);
    </cfscript>
    
    <cfset response = {
        "success" = true,
        "gradeResult" = gradeResult,
        "message" = "Grade calculated successfully"
    }>
    
<cfelseif url.action eq "recalculate_all">
    <!--- Recalculate all product grades --->
    <cfquery name="getAllProducts" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name,
            n.calories_per_100g, n.sugar_g, n.fat_g, n.fiber_g, n.protein_g
        FROM products p
        JOIN nutrition_data n ON p.product_id = n.product_id
        WHERE n.calories_per_100g IS NOT NULL
    </cfquery>
    
    <cfset updatedCount = 0>
    <cfset results = []>
    
    <cfloop query="getAllProducts">
        <cfscript>
            // Calculate new grade
            gradeResult = calculator.calculateGrade(
                calories_per_100g,
                sugar_g,
                fat_g,
                fiber_g,
                protein_g
            );
            
            // Update the product rating
            updateQuery = new Query();
            updateQuery.setDatasource("nutricheck");
            updateQuery.setSQL("
                UPDATE product_ratings 
                SET nutrition_grade = :grade, 
                    nutrition_score = :score,
                    calculated_at = NOW()
                WHERE product_id = :productId
            ");
            updateQuery.addParam(name="grade", value=gradeResult.grade, cfsqltype="cf_sql_varchar");
            updateQuery.addParam(name="score", value=gradeResult.nutritionalScore, cfsqltype="cf_sql_decimal");
            updateQuery.addParam(name="productId", value=product_id, cfsqltype="cf_sql_integer");
            updateQuery.execute();
            
            updatedCount++;
            
            // Add to results
            arrayAppend(results, {
                "productId" = product_id,
                "productName" = product_name,
                "oldGrade" = "Unknown",
                "newGrade" = gradeResult.grade,
                "nutritionalScore" = gradeResult.nutritionalScore
            });
        </cfscript>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "updatedCount" = updatedCount,
        "results" = results,
        "message" = "Successfully recalculated grades for " & updatedCount & " products"
    }>
    
<cfelseif url.action eq "getCategories">
    <!--- Get All Categories (Updated) --->
    <cfquery name="getCategories" datasource="nutricheck">
        SELECT category_id, category_name, description
        FROM categories
        ORDER BY category_id
    </cfquery>
    
    <cfset categories = []>
    <cfloop query="getCategories">
        <cfset categoryData = {
            "categoryId" = toString(category_id),
            "categoryName" = category_name,
            "description" = description
        }>
        <cfset arrayAppend(categories, categoryData)>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "categories" = categories,
        "debug" = "Updated version with toString and description"
    }>
    
<cfelseif url.action eq "getProductDetail">
    <!--- Get Single Product Detail --->
    <cfquery name="getProductDetail" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name, p.brand, p.description, 
            p.price, p.serving_size,
            c.category_name,
            n.calories_per_100g, n.protein_g, n.carbs_g, n.fat_g, 
            n.fiber_g, n.sugar_g, n.sodium_mg, n.saturated_fat_g,
            n.trans_fat_g, n.cholesterol_mg,
            r.nutrition_grade, r.nutrition_score
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN nutrition_data n ON p.product_id = n.product_id
        LEFT JOIN product_ratings r ON p.product_id = r.product_id
        WHERE p.product_id = <cfqueryparam value="#url.productId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfif getProductDetail.recordCount gt 0>
        <cfset productData = {
            "productId" = getProductDetail.product_id[1],
            "productName" = getProductDetail.product_name[1],
            "brand" = getProductDetail.brand[1],
            "description" = getProductDetail.description[1],
            "price" = getProductDetail.price[1],
            "servingSize" = getProductDetail.serving_size[1],
            "categoryName" = getProductDetail.category_name[1],
            "nutrition" = {
                "calories" = getProductDetail.calories_per_100g[1],
                "protein" = getProductDetail.protein_g[1],
                "carbs" = getProductDetail.carbs_g[1],
                "fat" = getProductDetail.fat_g[1],
                "fiber" = getProductDetail.fiber_g[1],
                "sugar" = getProductDetail.sugar_g[1],
                "sodium" = getProductDetail.sodium_mg[1],
                "saturatedFat" = getProductDetail.saturated_fat_g[1],
                "transFat" = getProductDetail.trans_fat_g[1],
                "cholesterol" = getProductDetail.cholesterol_mg[1]
            },
            "nutritionGrade" = getProductDetail.nutrition_grade[1],
            "nutritionScore" = getProductDetail.nutrition_score[1]
        }>
        
        <cfset response = {
            "success" = true,
            "product" = productData
        }>
    <cfelse>
        <cfset response = {
            "success" = false,
            "message" = "Product not found"
        }>
    </cfif>
    
<cfelse>
    <cfset response = {
        "success" = false,
        "message" = "Invalid action"
    }>
</cfif>

    <cfcatch type="any">
        <cfset response = {
            "success" = false,
            "message" = "Error: " & cfcatch.message,
            "detail" = cfcatch.detail,
            "type" = cfcatch.type
        }>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
