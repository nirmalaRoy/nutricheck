<cfcomponent>
    <cffunction name="init" returnType="MailService" output="false">
        <!--- Use ColdFusion Administrator mail settings instead of overriding them --->
        <cfset this.fromEmail = "testnaina02@gmail.com">
        <cfset this.fromName = "NutriCheck">
        <cfset this.smtpConfigured = true>
        <cfreturn this>
    </cffunction>
    
    <cffunction name="sendEmail" returnType="struct" output="false">
        <cfargument name="to" type="string" required="true">
        <cfargument name="subject" type="string" required="true">
        <cfargument name="body" type="string" required="true">
        <cfargument name="isHtml" type="boolean" default="true">
        
        <cfset var result = {}>
        <cfset result.success = false>
        <cfset result.message = "">
        <cfset result.error = "">
        
        <cftry>
            <!--- Use ColdFusion Administrator configured mail settings --->
            <cfmail to="#arguments.to#" 
                    from="#this.fromName# <#this.fromEmail#>" 
                    subject="#arguments.subject#" 
                    type="#arguments.isHtml ? 'html' : 'text'#"
                    timeout="30">
                <cfoutput>#arguments.body#</cfoutput>
            </cfmail>
            
            <cfset result.success = true>
            <cfset result.message = "Email sent successfully using ColdFusion Administrator mail settings">
            
            <cfcatch type="any">
                <cfset result.success = false>
                <cfset result.message = "Email delivery failed">
                <cfset result.error = "Failed to send email. Please verify ColdFusion Administrator mail settings are correct. Error: " & cfcatch.message>
            </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>
    
    <cffunction name="sendPasswordResetEmail" returnType="struct" output="false">
        <cfargument name="email" type="string" required="true">
        <cfargument name="firstName" type="string" required="true">
        <cfargument name="resetUrl" type="string" required="true">
        
        <cfset var subject = "Password Reset Request - NutriCheck">
        <cfset var body = "">
        
        <cfsavecontent variable="body">
            <cfoutput>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: ##333; }
                        .header { background: linear-gradient(135deg, ##667eea 0%, ##764ba2 100%); color: white; padding: 20px; text-align: center; }
                        .content { padding: 20px; }
                        .button { display: inline-block; background: ##667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 15px 0; }
                        .footer { background: ##f8f9fa; padding: 15px; text-align: center; color: ##666; font-size: 12px; }
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h2>🍎 NutriCheck Password Reset</h2>
                    </div>
                    <div class="content">
                        <p>Hello #arguments.firstName#,</p>
                        <p>We received a request to reset your password for your NutriCheck account.</p>
                        <p>Click the button below to reset your password:</p>
                        <p><a href="#arguments.resetUrl#" class="button">Reset My Password</a></p>
                        <p>Or copy and paste this link into your browser:</p>
                        <p>#arguments.resetUrl#</p>
                        <p><strong>This link will expire in 1 hour for security reasons.</strong></p>
                        <p>If you didn't request this password reset, please ignore this email.</p>
                    </div>
                    <div class="footer">
                        <p>This email was sent from NutriCheck Application</p>
                        <p>Generated on #dateFormat(now(), 'mm/dd/yyyy')# at #timeFormat(now(), 'hh:mm tt')#</p>
                    </div>
                </body>
                </html>
            </cfoutput>
        </cfsavecontent>
        
        <cfreturn sendEmail(arguments.email, subject, body, true)>
    </cffunction>
    
    <cffunction name="sendProductShareEmail" returnType="struct" output="false">
        <cfargument name="recipientEmail" type="string" required="true">
        <cfargument name="productData" type="struct" required="true">
        <cfargument name="personalMessage" type="string" default="">
        
        <cfset var subject = "Product Details: #arguments.productData.product_name# - NutriCheck">
        <cfset var body = "">
        
        <cfsavecontent variable="body">
            <cfoutput>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: ##333; }
                        .header { background: linear-gradient(135deg, ##667eea 0%, ##764ba2 100%); color: white; padding: 20px; text-align: center; }
                        .content { padding: 20px; }
                        .product-info { background: ##f9f9f9; padding: 15px; border-radius: 8px; margin: 15px 0; }
                        .nutrition-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
                        .nutrition-table th, .nutrition-table td { border: 1px solid ##ddd; padding: 8px; text-align: left; }
                        .nutrition-table th { background-color: ##667eea; color: white; }
                        .grade-badge { display: inline-block; width: 40px; height: 40px; border-radius: 50%; text-align: center; line-height: 40px; font-weight: bold; color: white; margin: 10px 0; }
                        .grade-A { background: linear-gradient(135deg, ##11998e 0%, ##38ef7d 100%); }
                        .grade-B { background: linear-gradient(135deg, ##2193b0 0%, ##6dd5ed 100%); }
                        .grade-C { background: linear-gradient(135deg, ##f7b733 0%, ##fc4a1a 100%); }
                        .grade-D { background: linear-gradient(135deg, ##ee0979 0%, ##ff6a00 100%); }
                        .grade-E { background: linear-gradient(135deg, ##c31432 0%, ##240b36 100%); }
                        .footer { background: ##f8f9fa; padding: 15px; text-align: center; color: ##666; font-size: 12px; }
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h2>🍎 NutriCheck Product Details</h2>
                    </div>
                    <div class="content">
                        <h2>#arguments.productData.product_name#</h2>
                        <div class="product-info">
                            <p><strong>Brand:</strong> #arguments.productData.brand#</p>
                            <p><strong>Category:</strong> #arguments.productData.category_name#</p>
                            <p><strong>Serving Size:</strong> #arguments.productData.serving_size#</p>
                            <p><strong>Price:</strong> ₹#numberFormat(arguments.productData.price, "0.00")#</p>
                            <p><strong>Description:</strong> #arguments.productData.description#</p>
                        </div>
                        
                        <h3>Nutrition Grade</h3>
                        <div class="grade-badge grade-#arguments.productData.nutrition_grade#">
                            #arguments.productData.nutrition_grade#
                        </div>
                        <cfif isNumeric(arguments.productData.nutrition_score)>
                            <p>Score: #numberFormat(arguments.productData.nutrition_score, "0.0")#/100</p>
                        </cfif>
                        
                        <h3>Nutrition Information (per 100g)</h3>
                        <table class="nutrition-table">
                            <tr>
                                <td>Calories</td>
                                <td>#numberFormat(arguments.productData.calories_per_100g, "0.0")# kcal</td>
                            </tr>
                            <tr>
                                <td>Protein</td>
                                <td>#numberFormat(arguments.productData.protein_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Carbohydrates</td>
                                <td>#numberFormat(arguments.productData.carbs_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Fat</td>
                                <td>#numberFormat(arguments.productData.fat_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Saturated Fat</td>
                                <td>#numberFormat(arguments.productData.saturated_fat_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Trans Fat</td>
                                <td>#numberFormat(arguments.productData.trans_fat_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Fiber</td>
                                <td>#numberFormat(arguments.productData.fiber_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Sugar</td>
                                <td>#numberFormat(arguments.productData.sugar_g, "0.0")# g</td>
                            </tr>
                            <tr>
                                <td>Sodium</td>
                                <td>#numberFormat(arguments.productData.sodium_mg, "0.0")# mg</td>
                            </tr>
                            <tr>
                                <td>Cholesterol</td>
                                <td>#numberFormat(arguments.productData.cholesterol_mg, "0.0")# mg</td>
                            </tr>
                        </table>
                        
                        <cfif trim(arguments.personalMessage) neq "">
                            <h3>Personal Message</h3>
                            <div class="product-info">
                                <p>#arguments.personalMessage#</p>
                            </div>
                        </cfif>
                    </div>
                    
                    <div class="footer">
                        <p>This email was sent from NutriCheck Application</p>
                        <p>Generated on #dateFormat(now(), 'mm/dd/yyyy')# at #timeFormat(now(), 'hh:mm tt')#</p>
                    </div>
                </body>
                </html>
            </cfoutput>
        </cfsavecontent>
        
        <cfreturn sendEmail(arguments.recipientEmail, subject, body, true)>
    </cffunction>
</cfcomponent>
