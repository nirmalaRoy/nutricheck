<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<!--- Initialize NutriScore Calculator Component --->
<cfset nutriScoreCalculator = createObject("component", "components.NutriScoreCalculator")>

<cfparam name="url.action" default="">
<cfparam name="url.productId" default="0">

<cfif url.action eq "add">
    <!--- Add New Product --->
    <cfparam name="form.productName" default="">
    <cfparam name="form.brand" default="">
    <cfparam name="form.categoryId" default="0">
    <cfparam name="form.description" default="">
    <cfparam name="form.price" default="0">
    <cfparam name="form.servingSize" default="">
    <cfparam name="form.calories" default="0">
    <cfparam name="form.protein" default="0">
    <cfparam name="form.carbs" default="0">
    <cfparam name="form.fat" default="0">
    <cfparam name="form.fiber" default="0">
    <cfparam name="form.sugar" default="0">
    <cfparam name="form.sodium" default="0">
    <cfparam name="form.saturatedFat" default="0">
    <cfparam name="form.transFat" default="0">
    <cfparam name="form.cholesterol" default="0">
    
    <cftry>
        <!--- Insert product --->
        <cfquery name="insertProduct" datasource="nutricheck">
            INSERT INTO products (product_name, brand, category_id, description, price, serving_size)
            VALUES (
                <cfqueryparam value="#form.productName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.brand#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.categoryId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.price#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.servingSize#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        
        <!--- Get the inserted product ID --->
        <cfquery name="getProductId" datasource="nutricheck">
            SELECT LAST_INSERT_ID() as productId
        </cfquery>
        
        <cfset newProductId = getProductId.productId>
        
        <!--- Insert nutrition data --->
        <cfquery name="insertNutrition" datasource="nutricheck">
            INSERT INTO nutrition_data (
                product_id, calories_per_100g, protein_g, carbs_g, fat_g, 
                fiber_g, sugar_g, sodium_mg, saturated_fat_g, trans_fat_g, cholesterol_mg
            )
            VALUES (
                <cfqueryparam value="#newProductId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.calories#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.protein#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.carbs#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.fat#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.fiber#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.sugar#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.sodium#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.saturatedFat#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.transFat#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#form.cholesterol#" cfsqltype="cf_sql_decimal">
            )
        </cfquery>
        
        <!--- Calculate nutrition score and grade using NutriScore Calculator --->
        <cfset gradeResult = nutriScoreCalculator.calculateGrade(
            val(form.calories),
            val(form.sugar),
            val(form.saturatedFat),
            val(form.fiber),
            val(form.protein)
        )>
        
        <cfset nutritionGrade = gradeResult.grade>
        <cfset nutritionScore = gradeResult.nutritionalScore>
        
        <!--- Insert nutrition rating --->
        <cfquery name="insertRating" datasource="nutricheck">
            INSERT INTO product_ratings (product_id, nutrition_grade, nutrition_score)
            VALUES (
                <cfqueryparam value="#newProductId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#nutritionGrade#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#nutritionScore#" cfsqltype="cf_sql_decimal">
            )
        </cfquery>
        
        <cfset response = {
            "success" = true,
            "message" = "Product added successfully with grade #nutritionGrade#!",
            "productId" = newProductId,
            "nutritionGrade" = nutritionGrade
        }>
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error adding product: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "get">
    <!--- Get Single Product for Editing --->
    <cftry>
        <cfquery name="getProduct" datasource="nutricheck">
            SELECT 
                p.product_id, p.product_name, p.brand, p.category_id, p.description, p.price, p.serving_size,
                n.calories_per_100g, n.protein_g, n.carbs_g, n.fat_g, n.fiber_g, n.sugar_g, 
                n.sodium_mg, n.saturated_fat_g, n.trans_fat_g, n.cholesterol_mg,
                c.category_name
            FROM products p
            LEFT JOIN nutrition_data n ON p.product_id = n.product_id
            LEFT JOIN categories c ON p.category_id = c.category_id
            WHERE p.product_id = <cfqueryparam value="#url.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif getProduct.recordCount gt 0>
            <cfset productData = {
                "productId" = getProduct.product_id[1],
                "productName" = getProduct.product_name[1],
                "brand" = getProduct.brand[1],
                "categoryId" = toString(getProduct.category_id[1]),
                "categoryName" = getProduct.category_name[1],
                "description" = getProduct.description[1],
                "price" = getProduct.price[1],
                "servingSize" = getProduct.serving_size[1],
                "calories" = getProduct.calories_per_100g[1],
                "protein" = getProduct.protein_g[1],
                "carbs" = getProduct.carbs_g[1],
                "fat" = getProduct.fat_g[1],
                "fiber" = getProduct.fiber_g[1],
                "sugar" = getProduct.sugar_g[1],
                "sodium" = getProduct.sodium_mg[1],
                "saturatedFat" = getProduct.saturated_fat_g[1],
                "transFat" = getProduct.trans_fat_g[1],
                "cholesterol" = getProduct.cholesterol_mg[1]
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
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error retrieving product: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "update">
    <!--- Update Existing Product --->
    <cfparam name="form.productId" default="0">
    <cfparam name="form.productName" default="">
    <cfparam name="form.brand" default="">
    <cfparam name="form.categoryId" default="0">
    <cfparam name="form.description" default="">
    <cfparam name="form.price" default="0">
    <cfparam name="form.servingSize" default="">
    <cfparam name="form.calories" default="0">
    <cfparam name="form.protein" default="0">
    <cfparam name="form.carbs" default="0">
    <cfparam name="form.fat" default="0">
    <cfparam name="form.fiber" default="0">
    <cfparam name="form.sugar" default="0">
    <cfparam name="form.sodium" default="0">
    <cfparam name="form.saturatedFat" default="0">
    <cfparam name="form.transFat" default="0">
    <cfparam name="form.cholesterol" default="0">
    
    <!--- Debug: Log the received data --->
    <cfset debugInfo = {
        "productId" = form.productId,
        "productName" = form.productName,
        "categoryId" = form.categoryId,
        "action" = "update",
        "allFormKeys" = structKeyList(form)
    }>
    <cflog file="product_update" text="Update request: #serializeJSON(debugInfo)#">
    
    <!--- Also log all form data for debugging --->
    <cfset formData = {}>
    <cfloop collection="#form#" item="key">
        <cfset formData[key] = form[key]>
    </cfloop>
    <cflog file="product_update" text="All form data: #serializeJSON(formData)#">
    
    <!--- Ensure all nutrition values are numeric and default to 0 if empty --->
    <cfset form.calories = val(form.calories)>
    <cfset form.protein = val(form.protein)>
    <cfset form.carbs = val(form.carbs)>
    <cfset form.fat = val(form.fat)>
    <cfset form.fiber = val(form.fiber)>
    <cfset form.sugar = val(form.sugar)>
    <cfset form.sodium = val(form.sodium)>
    <cfset form.saturatedFat = val(form.saturatedFat)>
    <cfset form.transFat = val(form.transFat)>
    <cfset form.cholesterol = val(form.cholesterol)>
    
    <cfif val(form.productId) eq 0>
        <cfset response = { "success" = false, "message" = "Missing or invalid productId" }>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Initialize nutrition variables with default values --->
    <cfset nutritionGrade = "N/A">
    <cfset nutritionScore = 0>
    
    <cftry>
        <!--- First check if the product exists --->
        <cfquery name="checkProduct" datasource="nutricheck">
            SELECT product_id, product_name FROM products 
            WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif checkProduct.recordCount eq 0>
            <cfset response = { "success" = false, "message" = "Product with ID #form.productId# not found" }>
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>
        
        <cflog file="product_update" text="Updating product ID #form.productId# (found: #checkProduct.product_name[1]#)">
        
        <!--- Update product --->
        <cfquery datasource="nutricheck">
            UPDATE products 
            SET product_name = <cfqueryparam value="#form.productName#" cfsqltype="cf_sql_varchar">,
                brand = <cfqueryparam value="#form.brand#" cfsqltype="cf_sql_varchar">,
                category_id = <cfqueryparam value="#form.categoryId#" cfsqltype="cf_sql_integer">,
                description = <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">,
                price = <cfqueryparam value="#form.price#" cfsqltype="cf_sql_decimal">,
                serving_size = <cfqueryparam value="#form.servingSize#" cfsqltype="cf_sql_varchar">,
                updated_at = NOW()
            WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cflog file="product_update" text="Product update query executed successfully">
        <cflog file="product_update" text="About to calculate nutrition score">
        
        <!--- Check if nutrition data exists for this product --->
        <cfquery name="checkNutrition" datasource="nutricheck">
            SELECT COUNT(*) as recordCount
            FROM nutrition_data
            WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif checkNutrition.recordCount gt 0>
            <!--- Update existing nutrition data --->
            <cfquery name="updateNutrition" datasource="nutricheck">
                UPDATE nutrition_data 
                SET calories_per_100g = <cfqueryparam value="#form.calories#" cfsqltype="cf_sql_decimal">,
                    protein_g = <cfqueryparam value="#form.protein#" cfsqltype="cf_sql_decimal">,
                    carbs_g = <cfqueryparam value="#form.carbs#" cfsqltype="cf_sql_decimal">,
                    fat_g = <cfqueryparam value="#form.fat#" cfsqltype="cf_sql_decimal">,
                    fiber_g = <cfqueryparam value="#form.fiber#" cfsqltype="cf_sql_decimal">,
                    sugar_g = <cfqueryparam value="#form.sugar#" cfsqltype="cf_sql_decimal">,
                    sodium_mg = <cfqueryparam value="#form.sodium#" cfsqltype="cf_sql_decimal">,
                    saturated_fat_g = <cfqueryparam value="#form.saturatedFat#" cfsqltype="cf_sql_decimal">,
                    trans_fat_g = <cfqueryparam value="#form.transFat#" cfsqltype="cf_sql_decimal">,
                    cholesterol_mg = <cfqueryparam value="#form.cholesterol#" cfsqltype="cf_sql_decimal">,
                    updated_at = NOW()
                WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
            </cfquery>
        <cfelse>
            <!--- Insert new nutrition data --->
            <cfquery name="insertNutrition" datasource="nutricheck">
                INSERT INTO nutrition_data (
                    product_id, calories_per_100g, protein_g, carbs_g, fat_g, 
                    fiber_g, sugar_g, sodium_mg, saturated_fat_g, trans_fat_g, cholesterol_mg
                )
                VALUES (
                    <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#form.calories#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.protein#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.carbs#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.fat#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.fiber#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.sugar#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.sodium#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.saturatedFat#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.transFat#" cfsqltype="cf_sql_decimal">,
                    <cfqueryparam value="#form.cholesterol#" cfsqltype="cf_sql_decimal">
                )
            </cfquery>
        </cfif>
        
        <!--- Recalculate nutrition score and grade using NutriScore Calculator --->
        <cftry>
            <cfset gradeResult = nutriScoreCalculator.calculateGrade(
                form.calories,
                form.sugar,
                form.fat,
                form.fiber,
                form.protein
            )>
            
            <cfset nutritionGrade = gradeResult.grade>
            <cfset nutritionScore = gradeResult.nutritionalScore>
        <cfcatch type="any">
            <cflog file="product_update" text="Error calculating nutrition score: #cfcatch.type# - #cfcatch.detail#">
            <cfset nutritionScore = 0>
            <cfset nutritionGrade = "E">
        </cfcatch>
        </cftry>
        
        <!--- Check if rating exists for this product --->
        <cfquery name="checkRating" datasource="nutricheck">
            SELECT COUNT(*) as recordCount
            FROM product_ratings
            WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif checkRating.recordCount gt 0>
            <!--- Update existing rating --->
            <cfquery name="updateRating" datasource="nutricheck">
                UPDATE product_ratings 
                SET nutrition_grade = <cfqueryparam value="#nutritionGrade#" cfsqltype="cf_sql_varchar">,
                    nutrition_score = <cfqueryparam value="#nutritionScore#" cfsqltype="cf_sql_float">,
                    calculated_at = NOW()
                WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
            </cfquery>
        <cfelse>
            <!--- Insert new rating --->
            <cfquery name="insertRating" datasource="nutricheck">
                INSERT INTO product_ratings (product_id, nutrition_grade, nutrition_score, calculated_at)
                VALUES (
                    <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#nutritionGrade#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#nutritionScore#" cfsqltype="cf_sql_float">,
                    NOW()
                )
            </cfquery>
        </cfif>
        
        <!--- Verify the update was successful --->
        <!--- Temporarily disabled for debugging
        <cfquery name="verifyUpdate" datasource="nutricheck">
            SELECT product_name, brand, category_id FROM products 
            WHERE product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cflog file="product_update" text="Verification - Product after update: #verifyUpdate.product_name[1]#, Brand: #verifyUpdate.brand[1]#, Category: #verifyUpdate.category_id[1]#">
        --->
        
        <cfset response = {
            "success" = true,
            "message" = "Product updated successfully!"
        }>
        
        <cfcatch type="any">
            <cflog file="product_update" text="Database error: #cfcatch.type# - #cfcatch.message# - #cfcatch.detail#">
            <cfset response = {
                "success" = false,
                "message" = "Error updating product: #cfcatch.type# - #cfcatch.message#",
                "detail" = cfcatch.detail,
                "sql_state" = structKeyExists(cfcatch, "sql_state") ? cfcatch.sql_state : "N/A"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "delete">
    <!--- Delete Product --->
    <cftry>
        <cfquery name="deleteProduct" datasource="nutricheck">
            DELETE FROM products
            WHERE product_id = <cfqueryparam value="#url.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfset response = {
            "success" = true,
            "message" = "Product deleted successfully"
        }>
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error deleting product: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "list">
    <!--- List All Products --->
    <cfquery name="getAllProducts" datasource="nutricheck">
        SELECT 
            p.product_id, p.product_name, p.brand, p.price,
            c.category_name,
            r.nutrition_grade, r.nutrition_score
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.category_id
        LEFT JOIN product_ratings r ON p.product_id = r.product_id
        ORDER BY p.product_id DESC
    </cfquery>
    
    <cfset products = []>
    <cfloop query="getAllProducts">
        <cfset productData = {
            "productId" = product_id,
            "productName" = product_name,
            "brand" = brand,
            "price" = price,
            "categoryName" = category_name,
            "nutritionGrade" = nutrition_grade,
            "nutritionScore" = nutrition_score
        }>
        <cfset arrayAppend(products, productData)>
    </cfloop>
    
    <cfset response = {
        "success" = true,
        "products" = products
    }>
    
<cfelseif url.action eq "categories">
    <!--- Get All Categories --->
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
        "categories" = categories
    }>
    
<cfelseif url.action eq "addCategory">
    <!--- Add New Category --->
    <cfparam name="form.categoryName" default="">
    <cfparam name="form.description" default="">
    
    <cftry>
        <cfquery name="insertCategory" datasource="nutricheck">
            INSERT INTO categories (category_name, description)
            VALUES (
                <cfqueryparam value="#form.categoryName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        
        <cfset response = {
            "success" = true,
            "message" = "Category added successfully"
        }>
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error adding category: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "updateCategory">
    <!--- Update Category --->
    <cfparam name="form.categoryId" default="0">
    <cfparam name="form.categoryName" default="">
    <cfparam name="form.description" default="">
    
    <cftry>
        <cfquery name="updateCategory" datasource="nutricheck">
            UPDATE categories 
            SET category_name = <cfqueryparam value="#form.categoryName#" cfsqltype="cf_sql_varchar">,
                description = <cfqueryparam value="#form.description#" cfsqltype="cf_sql_varchar">
            WHERE category_id = <cfqueryparam value="#form.categoryId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfset response = {
            "success" = true,
            "message" = "Category updated successfully"
        }>
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error updating category: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelseif url.action eq "deleteCategory">
    <!--- Delete Category --->
    <cfparam name="url.categoryId" default="0">
    
    <cftry>
        <!--- Check if category is being used by any products --->
        <cfquery name="checkCategoryUsage" datasource="nutricheck">
            SELECT COUNT(*) as productCount
            FROM products
            WHERE category_id = <cfqueryparam value="#url.categoryId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif checkCategoryUsage.productCount[1] gt 0>
            <cfset response = {
                "success" = false,
                "message" = "Cannot delete category. It is being used by #checkCategoryUsage.productCount[1]# product(s). Please reassign or delete those products first."
            }>
        <cfelse>
            <cfquery name="deleteCategory" datasource="nutricheck">
                DELETE FROM categories
                WHERE category_id = <cfqueryparam value="#url.categoryId#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfset response = {
                "success" = true,
                "message" = "Category deleted successfully"
            }>
        </cfif>
        
        <cfcatch type="any">
            <cfset response = {
                "success" = false,
                "message" = "Error deleting category: #cfcatch.type# - #cfcatch.detail#"
            }>
        </cfcatch>
    </cftry>
    
<cfelse>
    <cfset response = {
        "success" = false,
        "message" = "Invalid action"
    }>
</cfif>

<cfoutput>#serializeJSON(response)#</cfoutput>