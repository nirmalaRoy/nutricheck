<!--- Temporarily disabled for testing --->
<!--- <cfif not session.user.loggedIn>
    <cflocation url="../auth/login.cfm" addtoken="false">
</cfif> --->

<cfparam name="url.id" default="0">
<cfparam name="url.format" default="">

<!--- Handle Email Sharing Request (must be before product query) --->
<cfif structKeyExists(form, "action") and form.action eq "sendEmail">
    <cftry>
        <cfparam name="form.recipientEmail" default="">
        <cfparam name="form.emailMessage" default="">
        <cfparam name="form.productId" default="0">
        
        <!--- Validate email address --->
        <cfif not isValid("email", form.recipientEmail)>
            <cfthrow message="Invalid email address">
        </cfif>
        
        <!--- Get product details for email --->
        <cfquery name="getProductForEmail" datasource="nutricheck">
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
            WHERE p.product_id = <cfqueryparam value="#form.productId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif getProductForEmail.recordCount gt 0>
            <!--- Create email content --->
            <cfset emailSubject = "Product Details: #getProductForEmail.product_name[1]# - NutriCheck">
            
            <!--- Send email using MailService --->
            <cfset mailService = createObject("component", "/nutricheck/components/MailService").init()>
            <cfset productData = {
                "product_name" = getProductForEmail.product_name[1],
                "brand" = getProductForEmail.brand[1],
                "category_name" = getProductForEmail.category_name[1],
                "serving_size" = getProductForEmail.serving_size[1],
                "price" = getProductForEmail.price[1],
                "description" = getProductForEmail.description[1],
                "nutrition_grade" = getProductForEmail.nutrition_grade[1],
                "nutrition_score" = getProductForEmail.nutrition_score[1],
                "calories_per_100g" = getProductForEmail.calories_per_100g[1],
                "protein_g" = getProductForEmail.protein_g[1],
                "carbs_g" = getProductForEmail.carbs_g[1],
                "fat_g" = getProductForEmail.fat_g[1],
                "saturated_fat_g" = getProductForEmail.saturated_fat_g[1],
                "trans_fat_g" = getProductForEmail.trans_fat_g[1],
                "fiber_g" = getProductForEmail.fiber_g[1],
                "sugar_g" = getProductForEmail.sugar_g[1],
                "sodium_mg" = getProductForEmail.sodium_mg[1],
                "cholesterol_mg" = getProductForEmail.cholesterol_mg[1]
            }>
            <cfset emailResult = mailService.sendProductShareEmail(form.recipientEmail, productData, form.emailMessage)>
            
            <!--- Return response based on email result --->
            <cfheader name="Content-Type" value="application/json">
            <cfif emailResult.success>
                <cfoutput>{"success": true, "message": "Email sent successfully"}</cfoutput>
            <cfelse>
                <cfoutput>{"success": false, "message": "#emailResult.message#", "error": "#emailResult.error#"}</cfoutput>
            </cfif>
            <cfabort>
        <cfelse>
            <cfthrow message="Product not found">
        </cfif>
        
        <cfcatch type="any">
            <!--- Return error response --->
            <cfheader name="Content-Type" value="application/json">
            <cfoutput>{"success": false, "message": "#cfcatch.message#", "detail": "#cfcatch.detail#", "type": "#cfcatch.type#"}</cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>
</cfif>

<!--- Check if PDF download is requested --->
<cfif url.format eq "pdf">
    <!--- Get product details for PDF --->
    <cfquery name="getProductForPDF" datasource="nutricheck">
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
        WHERE p.product_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfif getProductForPDF.recordCount gt 0>
        <cfset pdfProduct = {
            "productId" = getProductForPDF.product_id[1],
            "productName" = getProductForPDF.product_name[1],
            "brand" = getProductForPDF.brand[1],
            "description" = getProductForPDF.description[1],
            "price" = getProductForPDF.price[1],
            "servingSize" = getProductForPDF.serving_size[1],
            "categoryName" = getProductForPDF.category_name[1],
            "nutrition" = {
                "calories" = val(getProductForPDF.calories_per_100g[1]),
                "protein" = val(getProductForPDF.protein_g[1]),
                "carbs" = val(getProductForPDF.carbs_g[1]),
                "fat" = val(getProductForPDF.fat_g[1]),
                "fiber" = val(getProductForPDF.fiber_g[1]),
                "sugar" = val(getProductForPDF.sugar_g[1]),
                "sodium" = val(getProductForPDF.sodium_mg[1]),
                "saturatedFat" = val(getProductForPDF.saturated_fat_g[1]),
                "transFat" = val(getProductForPDF.trans_fat_g[1]),
                "cholesterol" = val(getProductForPDF.cholesterol_mg[1])
            },
            "nutritionGrade" = getProductForPDF.nutrition_grade[1],
            "nutritionScore" = getProductForPDF.nutrition_score[1]
        }>
        
        <cfheader name="Content-Disposition" value="attachment; filename=#pdfProduct.productName#_nutrition_report.pdf">
        <cfheader name="Content-Type" value="application/pdf">
        
        <cfdocument format="PDF" pagetype="A4" orientation="portrait" marginleft="0.5" marginright="0.5" margintop="0.5" marginbottom="0.5">
            <cfoutput>
            <!DOCTYPE html>
            <html>
            <head>
                <title>#pdfProduct.productName# - Nutrition Report</title>
                <style>
                    body { 
                        font-family: Arial, sans-serif; 
                        margin: 20px; 
                        line-height: 1.6;
                        color: ##333;
                    }
                    .header { 
                        text-align: center; 
                        border-bottom: 3px solid ##667eea; 
                        padding-bottom: 10px; 
                        margin-bottom: 15px; 
                        background: linear-gradient(135deg, ##667eea 0%, ##764ba2 100%);
                        color: white;
                        padding: 15px;
                        border-radius: 8px;
                    }
                    .product-info { 
                        background: ##f9f9f9; 
                        padding: 15px; 
                        margin: 10px 0; 
                        border-radius: 8px;
                        border-left: 4px solid ##667eea;
                    }
                    .nutrition-grade {
                        width: 80px;
                        height: 80px;
                        border-radius: 50%;
                        display: inline-block;
                        text-align: center;
                        line-height: 80px;
                        font-size: 36px;
                        font-weight: bold;
                        color: white;
                        margin: 10px 0;
                    }
                    .grade-A { background: linear-gradient(135deg, ##11998e 0%, ##38ef7d 100%); }
                    .grade-B { background: linear-gradient(135deg, ##2193b0 0%, ##6dd5ed 100%); }
                    .grade-C { background: linear-gradient(135deg, ##f7b733 0%, ##fc4a1a 100%); }
                    .grade-D { background: linear-gradient(135deg, ##ee0979 0%, ##ff6a00 100%); }
                    .grade-E { background: linear-gradient(135deg, ##c31432 0%, ##240b36 100%); }
                    .nutrition-table {
                        width: 100%;
                        border-collapse: collapse;
                        margin: 15px 0;
                        background: white;
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    }
                    .nutrition-table th {
                        background: ##667eea;
                        color: white;
                        padding: 12px;
                        text-align: left;
                        font-weight: bold;
                    }
                    .nutrition-table td {
                        padding: 10px 12px;
                        border-bottom: 1px solid ##eee;
                    }
                    .nutrition-table tr:nth-child(even) {
                        background: ##f8f9fa;
                    }
                    .price-display {
                        font-size: 24px;
                        font-weight: bold;
                        color: ##667eea;
                        margin: 10px 0;
                    }
                    .footer {
                        margin-top: 20px;
                        padding-top: 15px;
                        border-top: 2px solid ##eee;
                        text-align: center;
                        color: ##666;
                        font-size: 12px;
                    }
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>NutriCheck Nutrition Report</h1>
                    <h2>#pdfProduct.productName#</h2>
                </div>
                
                <div class="product-info">
                    <h2>#pdfProduct.productName#</h2>
                    <p><strong>Brand:</strong> #pdfProduct.brand#</p>
                    <p><strong>Category:</strong> #pdfProduct.categoryName#</p>
                    <p><strong>Serving Size:</strong> #pdfProduct.servingSize#</p>
                    <div class="price-display">₹#numberFormat(pdfProduct.price, "0.00")#</div>
                    <p><strong>Description:</strong> #pdfProduct.description#</p>
                </div>
                
                <div style="text-align: center; margin: 20px 0;">
                    <h3>Nutrition Grade</h3>
                    <div class="nutrition-grade grade-#pdfProduct.nutritionGrade#">
                        #pdfProduct.nutritionGrade#
                    </div>
                    <p><strong>Score:</strong> 
                    <cfif isNumeric(pdfProduct.nutritionScore)>
                        #numberFormat(pdfProduct.nutritionScore, "0.0")#/100
                    <cfelse>
                        Not Available
                    </cfif>
                    </p>
                </div>
                
                <h3>Detailed Nutrition Information (per 100g)</h3>
                <table class="nutrition-table">
                    <thead>
                        <tr>
                            <th>Nutrient</th>
                            <th>Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Calories</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.calories, "0.0")# kcal</td>
                        </tr>
                        <tr>
                            <td><strong>Protein</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.protein, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Carbohydrates</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.carbs, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Total Fat</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.fat, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Saturated Fat</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.saturatedFat, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Trans Fat</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.transFat, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Fiber</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.fiber, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Sugar</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.sugar, "0.0")# g</td>
                        </tr>
                        <tr>
                            <td><strong>Sodium</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.sodium, "0.0")# mg</td>
                        </tr>
                        <tr>
                            <td><strong>Cholesterol</strong></td>
                            <td>#numberFormat(pdfProduct.nutrition.cholesterol, "0.0")# mg</td>
                        </tr>
                    </tbody>
                </table>
                
                <div class="footer">
                    <p>Generated by NutriCheck on #dateFormat(now(), 'mm/dd/yyyy')# at #timeFormat(now(), 'hh:mm tt')#</p>
                    <p>Product ID: #pdfProduct.productId# | Report ID: #getTickCount()#</p>
                </div>
            </body>
            </html>
            </cfoutput>
        </cfdocument>
        <cfabort>
    <cfelse>
        <cfheader name="Content-Type" value="application/json">
        <cfoutput>{"success": false, "message": "Product not found"}</cfoutput>
        <cfabort>
    </cfif>
</cfif>

<!--- Get product details directly from database --->
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
    WHERE p.product_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif getProductDetail.recordCount gt 0>
    <cfset product = {
        "productId" = getProductDetail.product_id[1],
        "productName" = getProductDetail.product_name[1],
        "brand" = getProductDetail.brand[1],
        "description" = getProductDetail.description[1],
        "price" = getProductDetail.price[1],
        "servingSize" = getProductDetail.serving_size[1],
        "categoryName" = getProductDetail.category_name[1],
        "nutrition" = {
            "calories" = val(getProductDetail.calories_per_100g[1]),
            "protein" = val(getProductDetail.protein_g[1]),
            "carbs" = val(getProductDetail.carbs_g[1]),
            "fat" = val(getProductDetail.fat_g[1]),
            "fiber" = val(getProductDetail.fiber_g[1]),
            "sugar" = val(getProductDetail.sugar_g[1]),
            "sodium" = val(getProductDetail.sodium_mg[1]),
            "saturatedFat" = val(getProductDetail.saturated_fat_g[1]),
            "transFat" = val(getProductDetail.trans_fat_g[1]),
            "cholesterol" = val(getProductDetail.cholesterol_mg[1])
        },
        "nutritionGrade" = getProductDetail.nutrition_grade[1],
        "nutritionScore" = getProductDetail.nutrition_score[1]
    }>
<cfelse>
    <cflocation url="dashboard.cfm" addtoken="false">
</cfif>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#product.productName#</cfoutput> - NutriCheck</title>
    <link rel="stylesheet" href="../assets/css/style.css?v=<cfoutput>#getTickCount()#</cfoutput>">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, ##667eea 0%, ##764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            margin: 0;
        }
        
        .product-detail-container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 30px;
        }
        
        .product-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid ##f0f0f0;
        }
        
        .product-info {
            flex: 1;
        }
        
        .product-title {
            font-size: 32px;
            color: ##333;
            margin-bottom: 10px;
        }
        
        .product-meta {
            color: ##666;
            font-size: 16px;
            margin-bottom: 5px;
        }
        
        .nutrition-grade-large {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            font-weight: 700;
            color: white;
            box-shadow: 0 5px 20px rgba(0,0,0,0.3);
            margin-left: 20px;
        }
        
        .nutrition-facts-section {
            margin-top: 30px;
            margin-bottom: 30px;
        }
        
        .nutrition-breakdown-section {
            margin-top: 30px;
            margin-bottom: 30px;
        }
        
        .nutrition-table {
            background: ##f9f9f9;
            border-radius: 10px;
            padding: 20px;
        }
        
        .nutrition-table h3 {
            color: ##667eea;
            margin-bottom: 20px;
            font-size: 20px;
        }
        
        .nutrition-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid ##e0e0e0;
        }
        
        .nutrition-row:last-child {
            border-bottom: none;
        }
        
        .nutrition-label {
            font-weight: 600;
            color: ##333;
        }
        
        .nutrition-value {
            color: ##666;
        }
        
        .chart-container {
            background: ##f9f9f9;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            width: 100%;
            max-width: 100%;
        }
        
        .chart-container h3 {
            color: ##667eea;
            margin-bottom: 20px;
            font-size: 20px;
        }
        
        .back-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 24px;
            background: #667eea !important;
            color: white !important;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            border: none;
            font-size: 16px;
            line-height: 1;
            height: 48px;
            box-sizing: border-box;
        }
        
        .back-button:hover {
            background: #764ba2 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .pdf-download-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 24px;
            background: #dc3545 !important;
            color: white !important;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(220, 53, 69, 0.3);
            border: none;
            cursor: pointer;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            font-size: 16px;
            line-height: 1;
            height: 48px;
            box-sizing: border-box;
        }
        
        .pdf-download-button:hover {
            background: #c82333 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4);
        }
        
        .email-share-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 24px;
            background: #28a745 !important;
            color: white !important;
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(40, 167, 69, 0.3);
            border: none;
            cursor: pointer;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            font-size: 16px;
            line-height: 1;
            height: 48px;
            box-sizing: border-box;
        }
        
        .email-share-button:hover {
            background: #218838 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
        }
        
        /* Email Modal Styles */
        .email-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .email-modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 30px;
            border-radius: 15px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            position: relative;
        }
        
        .email-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid ##f0f0f0;
        }
        
        .email-modal-title {
            font-size: 24px;
            color: ##333;
            margin: 0;
        }
        
        .close-modal {
            color: ##aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: color 0.3s;
        }
        
        .close-modal:hover {
            color: ##333;
        }
        
        .email-form-group {
            margin-bottom: 20px;
        }
        
        .email-form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: ##333;
        }
        
        .email-form-input {
            width: 100%;
            padding: 12px;
            border: 2px solid ##e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        .email-form-input:focus {
            outline: none;
            border-color: ##667eea;
        }
        
        .email-form-textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid ##e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            min-height: 100px;
            resize: vertical;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        .email-form-textarea:focus {
            outline: none;
            border-color: ##667eea;
        }
        
        .email-form-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 25px;
        }
        
        .email-form-button {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .email-form-button.primary {
            background: #667eea !important;
            color: white !important;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            box-shadow: 0 2px 4px rgba(102, 126, 234, 0.3);
        }
        
        .email-form-button.primary:hover {
            background: #764ba2 !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(102, 126, 234, 0.4);
        }
        
        .email-form-button.secondary {
            background: #6c757d !important;
            color: white !important;
            border: 2px solid #6c757d !important;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
            box-shadow: 0 2px 4px rgba(108, 117, 125, 0.3);
        }
        
        .email-form-button.secondary:hover {
            background: #5a6268 !important;
            border-color: #5a6268 !important;
            transform: translateY(-1px);
            box-shadow: 0 3px 6px rgba(108, 117, 125, 0.4);
        }
        
        .email-success-message {
            display: none;
            background: ##d4edda;
            color: ##155724;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid ##c3e6cb;
        }
        
        .email-error-message {
            display: none;
            background: ##f8d7da;
            color: ##721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid ##f5c6cb;
        }
        
        .button-group {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .button-group > * {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            vertical-align: middle;
            line-height: 1;
        }
        
        .price-display {
            font-size: 24px;
            color: ##667eea;
            font-weight: 700;
            margin-top: 10px;
        }
        
        .nutrition-breakdown {
            text-align: center;
            padding: 20px;
            background: ##f9f9f9;
            border-radius: 8px;
        }
        
        .nutrition-chart {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 20px 0;
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 100%;
        }
        
        .nutrition-chart img {
            width: 100%;
            max-width: 900px;
            height: auto;
            object-fit: contain;
        }
        
        .nutrition-values {
            background: ##f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-top: 15px;
        }
        
        .nutrition-values div {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
        }
        
        .nutrition-values span {
            margin-right: 8px;
            font-size: 16px;
        }
        
        .nutrition-score-info {
            margin-top: 30px;
            padding: 20px;
            background: ##f0f8ff;
            border-radius: 10px;
            border-left: 4px solid ##667eea;
        }
        
        .nutrition-score-info h3 {
            color: ##667eea;
            margin-bottom: 15px;
        }
        
        .score-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .grade-description {
            color: ##11998e;
            font-weight: 600;
        }
        
        /* Grade color classes */
        .grade-A {
            background: linear-gradient(135deg, ##11998e 0%, ##38ef7d 100%);
        }
        
        .grade-B {
            background: linear-gradient(135deg, ##2193b0 0%, ##6dd5ed 100%);
        }
        
        .grade-C {
            background: linear-gradient(135deg, ##f7b733 0%, ##fc4a1a 100%);
        }
        
        .grade-D {
            background: linear-gradient(135deg, ##ee0979 0%, ##ff6a00 100%);
        }
        
        .grade-E {
            background: linear-gradient(135deg, ##c31432 0%, ##240b36 100%);
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .product-detail-container {
                padding: 20px;
            }
            
            .product-header {
                flex-direction: column;
                text-align: center;
            }
            
            .nutrition-grade-large {
                margin: 20px 0 0 0;
            }
            
            .button-group {
                justify-content: center;
                gap: 10px;
            }
            
            .back-button,
            .pdf-download-button,
            .email-share-button {
                padding: 10px 16px;
                font-size: 14px;
                min-width: auto;
                flex: 1;
                text-align: center;
                max-width: 120px;
            }
            
            .score-details {
                grid-template-columns: 1fr;
            }
            
            .nutrition-chart {
                padding: 10px;
            }
            
            .nutrition-chart img {
                width: 100%;
                max-width: 600px;
                height: auto;
            }
            
            .nutrition-values div {
                flex-direction: column;
                align-items: flex-start;
                margin-bottom: 10px;
            }
        }
        
        /* Extra small screens */
        @media (max-width: 480px) {
            .button-group {
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
            }
            
            .back-button,
            .pdf-download-button,
            .email-share-button {
                width: 100%;
                max-width: none;
                text-align: center;
                padding: 12px 20px;
                font-size: 16px;
            }
        }
    </style>
</head>
<body>
    <cfoutput>
    <div class="container">
        <div class="button-group">
            <a href="dashboard.cfm" class="back-button">← Back to Products</a>
            <a href="product-detail.cfm?id=#url.id#&format=pdf" class="pdf-download-button">📄 Download PDF</a>
            <button onclick="openEmailModal()" class="email-share-button">📧 Share to Email</button>
        </div>
        
        <div class="product-detail-container">
            <div class="product-header">
                <div class="product-info">
                    <h1 class="product-title">#product.productName#</h1>
                    <div class="product-meta">Brand: #product.brand#</div>
                    <div class="product-meta">Category: #product.categoryName#</div>
                    <div class="product-meta">Serving Size: #product.servingSize#</div>
                    <div class="price-display">₹#numberFormat(product.price, "0.00")#</div>
                </div>
                <div class="nutrition-grade-large grade-#product.nutritionGrade#">
                    #product.nutritionGrade#
                </div>
            </div>
            
            <!-- Section 1: Nutrition Facts (per 100g) -->
            <div class="nutrition-facts-section">
                <div class="nutrition-table">
                    <h3>Nutrition Facts (per 100g)</h3>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Calories</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.calories, "0.0")# kcal</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Protein</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.protein, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Carbohydrates</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.carbs, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Total Fat</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.fat, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Saturated Fat</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.saturatedFat, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Trans Fat</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.transFat, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Fiber</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.fiber, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Sugar</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.sugar, "0.0")# g</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Sodium</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.sodium, "0.0")# mg</span>
                    </div>
                    <div class="nutrition-row">
                        <span class="nutrition-label">Cholesterol</span>
                        <span class="nutrition-value">#numberFormat(product.nutrition.cholesterol, "0.0")# mg</span>
                    </div>
                </div>
            </div>
            
            <!-- Section 2: Nutrition Breakdown Chart -->
            <div class="nutrition-breakdown-section">
                <div class="chart-container">
                    <h3>Nutrition Breakdown</h3>
                    <div class="nutrition-chart">
                        <cftry>
                            <cfchart format="png" chartwidth="900" chartheight="500" show3d="true" showlegend="true" showborder="false" backgroundcolor="white" title="Macronutrient Distribution (per 100g)" foregroundColor="black">
                                <cfchartseries type="pie" serieslabel="Nutrition Breakdown" paintstyle="plain">
                                    <cfchartdata item="Protein" value="#product.nutrition.protein#">
                                    <cfchartdata item="Carbohydrates" value="#product.nutrition.carbs#">
                                    <cfchartdata item="Fat" value="#product.nutrition.fat#">
                                    <cfchartdata item="Fiber" value="#product.nutrition.fiber#">
                                    <cfchartdata item="Sugar" value="#product.nutrition.sugar#">
                                </cfchartseries>
                            </cfchart>
                            <cfcatch type="any">
                                <div style="padding: 20px; text-align: center; color: ##666; background: ##f8f9fa; border-radius: 8px;">
                                    <h4>📊 Nutrition Breakdown</h4>
                                    <p>Chart temporarily unavailable. Showing nutrition breakdown below.</p>
                                </div>
                            </cfcatch>
                        </cftry>
                    </div>
                </div>
            </div>
            
            <div class="nutrition-score-info">
                <h3>Nutrition Score Information</h3>
                <div class="score-details">
                    <div>
                        <strong>Nutrition Grade:</strong> #product.nutritionGrade#<br>
                        <strong>Nutrition Score:</strong> 
                        <cfif isNumeric(product.nutritionScore)>
                            #numberFormat(product.nutritionScore, "0.0")#/100
                        <cfelse>
                            Not Available
                        </cfif>
                    </div>
                    <div>
                        <span class="grade-description">
                            <cfif product.nutritionGrade eq "A">
                                Excellent nutritional quality
                            <cfelseif product.nutritionGrade eq "B">
                                Good nutritional quality
                            <cfelseif product.nutritionGrade eq "C">
                                Fair nutritional quality
                            <cfelseif product.nutritionGrade eq "D">
                                Poor nutritional quality
                            <cfelseif product.nutritionGrade eq "E">
                                Very poor nutritional quality
                            <cfelse>
                                Nutritional quality not assessed
                            </cfif>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Email Share Modal -->
    <div id="emailModal" class="email-modal">
        <div class="email-modal-content">
            <div class="email-modal-header">
                <h2 class="email-modal-title">📧 Share Product Details</h2>
                <span class="close-modal" onclick="closeEmailModal()">&times;</span>
            </div>
            
            <div id="emailSuccessMessage" class="email-success-message">
                ✅ Email sent successfully! The recipient will receive the product details shortly.
            </div>
            
            <div id="emailErrorMessage" class="email-error-message">
                ❌ Failed to send email. Please check the email address and try again.
            </div>
            
            <form id="emailShareForm" onsubmit="sendEmail(event)">
                <div class="email-form-group">
                    <label for="recipientEmail" class="email-form-label">Recipient Email Address:</label>
                    <input type="email" id="recipientEmail" name="recipientEmail" class="email-form-input" 
                           placeholder="Enter email address" required>
                </div>
                
                <div class="email-form-group">
                    <label for="emailMessage" class="email-form-label">Personal Message (Optional):</label>
                    <textarea id="emailMessage" name="emailMessage" class="email-form-textarea" 
                              placeholder="Add a personal message..."></textarea>
                </div>
                
                <div class="email-form-buttons">
                    <button type="button" class="email-form-button secondary" onclick="closeEmailModal()">Cancel</button>
                    <button type="submit" class="email-form-button primary">Send Email</button>
                </div>
            </form>
        </div>
    </div>
    </cfoutput>
    
    <script>
        // Store product ID in a variable for JavaScript use
        var currentProductId = <cfoutput>#url.id#</cfoutput>;
        
        function openEmailModal() {
            document.getElementById('emailModal').style.display = 'block';
            document.getElementById('emailSuccessMessage').style.display = 'none';
            document.getElementById('emailErrorMessage').style.display = 'none';
            document.getElementById('emailShareForm').reset();
        }
        
        function closeEmailModal() {
            document.getElementById('emailModal').style.display = 'none';
        }
        
        // Close modal when clicking outside of it
        window.onclick = function(event) {
            var modal = document.getElementById('emailModal');
            if (event.target == modal) {
                closeEmailModal();
            }
        }
        
        function sendEmail(event) {
            event.preventDefault();
            
            var recipientEmail = document.getElementById('recipientEmail').value;
            var emailMessage = document.getElementById('emailMessage').value;
            var productId = currentProductId;
            
            // Show loading state
            var submitButton = event.target.querySelector('button[type="submit"]');
            var originalText = submitButton.textContent;
            submitButton.textContent = 'Sending...';
            submitButton.disabled = true;
            
            // Create form data
            var formData = new FormData();
            formData.append('action', 'sendEmail');
            formData.append('recipientEmail', recipientEmail);
            formData.append('emailMessage', emailMessage);
            formData.append('productId', productId);
            
            // Send AJAX request
            fetch('product-detail.cfm', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('emailSuccessMessage').style.display = 'block';
                    document.getElementById('emailErrorMessage').style.display = 'none';
                    // Close modal after 2 seconds
                    setTimeout(function() {
                        closeEmailModal();
                    }, 2000);
                } else {
                    document.getElementById('emailErrorMessage').style.display = 'block';
                    document.getElementById('emailSuccessMessage').style.display = 'none';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('emailErrorMessage').style.display = 'block';
                document.getElementById('emailSuccessMessage').style.display = 'none';
            })
            .finally(() => {
                // Reset button state
                submitButton.textContent = originalText;
                submitButton.disabled = false;
            });
        }
    </script>
</body>
</html>
