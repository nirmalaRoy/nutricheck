<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="url.action" default="">
<cfparam name="form.email" default="">
<cfparam name="form.password" default="">

<cfset response = {}>

<cftry>
    <cfif url.action eq "login">
        <!--- Login --->
        <cfparam name="form.email" default="">
        <cfparam name="form.password" default="">
        
        <cfif len(trim(form.email)) and len(trim(form.password))>
            <cfquery name="checkUser" datasource="nutricheck">
                SELECT user_id, email, first_name, last_name, password_hash, role
                FROM users
                WHERE email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkUser.recordCount eq 1>
                <cfset hashedPassword = hash(form.password, "SHA-256")>
                <cfif checkUser.password_hash eq hashedPassword>
                    <cfset session.user.loggedIn = true>
                    <cfset session.user.userId = checkUser.user_id>
                    <cfset session.user.email = checkUser.email>
                    <cfset session.user.firstName = checkUser.first_name>
                    <cfset session.user.lastName = checkUser.last_name>
                    <cfset session.user.role = checkUser.role>
                    
                    <cfset response.success = true>
                    <cfset response.message = "Login successful">
                    <cfset response.user = {
                        "user_id" = checkUser.user_id,
                        "email" = checkUser.email,
                        "first_name" = checkUser.first_name,
                        "last_name" = checkUser.last_name,
                        "role" = checkUser.role
                    }>
                <cfelse>
                    <cfset response.success = false>
                    <cfset response.message = "Invalid email or password">
                </cfif>
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = "Invalid email or password">
            </cfif>
        <cfelse>
            <cfset response.success = false>
            <cfset response.message = "Email and password are required">
        </cfif>
    <cfelseif url.action eq "forgotPassword">
        <!--- Forgot Password --->
        <cfif len(trim(form.email))>
            <!--- Check if user exists --->
            <cfquery name="checkUser" datasource="nutricheck">
                SELECT user_id, email, first_name, last_name
                FROM users
                WHERE email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkUser.recordCount eq 1>
                <!--- Generate reset token --->
                <cfset resetToken = createUUID()>
                <cfset expiresAt = dateAdd("h", 1, now())>
                
                <!--- Deactivate any existing tokens for this email --->
                <cfquery name="deactivateTokens" datasource="nutricheck">
                    UPDATE password_reset_tokens 
                    SET is_active = 0 
                    WHERE email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <!--- Insert new reset token --->
                <cfquery name="insertToken" datasource="nutricheck">
                    INSERT INTO password_reset_tokens (email, token, expires_at)
                    VALUES (
                        <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#resetToken#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#expiresAt#" cfsqltype="cf_sql_timestamp">
                    )
                </cfquery>
                
                <!--- Create reset URL --->
                <cfset resetUrl = "http://" & cgi.server_name & ":" & cgi.server_port & "/nutricheck/auth/reset-password.cfm?token=" & resetToken>
                
                <!--- Send reset email using MailService --->
                <cfset mailService = createObject("component", "/nutricheck/components/MailService").init()>
                <cfset emailResult = mailService.sendPasswordResetEmail(form.email, checkUser.first_name, resetUrl)>
                <cfset emailSent = emailResult.success>
                <cfset emailError = emailResult.error>
                
                <cfset response.success = true>
                <cfif emailSent>
                    <cfset response.message = "Password reset link has been sent to your email">
                <cfelse>
                    <cfset response.message = "Password reset link generated. Email delivery failed, but you can use the reset URL directly: " & resetUrl>
                    <cfset response.emailError = emailError>
                </cfif>
                <cfset response.token = resetToken>
                <cfset response.resetUrl = resetUrl>
                <cfset response.expiresAt = expiresAt>
            <cfelse>
                <cfset response.success = true>
                <cfset response.message = "If an account with that email exists, a password reset link has been sent">
            </cfif>
        <cfelse>
            <cfset response.success = false>
            <cfset response.message = "Email address is required">
        </cfif>
    <cfelseif url.action eq "resetPassword">
        <!--- Reset Password --->
        <cfparam name="form.token" default="">
        <cfparam name="form.password" default="">
        <cfparam name="form.confirmPassword" default="">
        
        <cfif len(trim(form.token)) and len(trim(form.password)) and len(trim(form.confirmPassword))>
            <cfif form.password eq form.confirmPassword>
                <!--- Validate token --->
                <cfquery name="validateToken" datasource="nutricheck">
                    SELECT email, expires_at
                    FROM password_reset_tokens
                    WHERE token = <cfqueryparam value="#form.token#" cfsqltype="cf_sql_varchar">
                    AND is_active = 1
                    AND expires_at > <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                </cfquery>
                
                <cfif validateToken.recordCount eq 1>
                    <!--- Hash new password --->
                    <cfset newPasswordHash = hash(form.password, "SHA-256")>
                    
                    <!--- Update password --->
                    <cfquery name="updatePassword" datasource="nutricheck">
                        UPDATE users 
                        SET password_hash = <cfqueryparam value="#newPasswordHash#" cfsqltype="cf_sql_varchar">
                        WHERE email = <cfqueryparam value="#validateToken.email#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <!--- Mark token as used --->
                    <cfquery name="markTokenUsed" datasource="nutricheck">
                        UPDATE password_reset_tokens 
                        SET used_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            is_active = 0
                        WHERE token = <cfqueryparam value="#form.token#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <cfset response.success = true>
                    <cfset response.message = "Password has been reset successfully">
                <cfelse>
                    <cfset response.success = false>
                    <cfset response.message = "Invalid or expired reset token">
                </cfif>
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = "Passwords do not match">
            </cfif>
        <cfelse>
            <cfset response.success = false>
            <cfset response.message = "All fields are required">
        </cfif>
    <cfelseif url.action eq "register">
        <!--- Registration --->
        <cfparam name="form.username" default="">
        <cfparam name="form.firstName" default="">
        <cfparam name="form.lastName" default="">
        <cfparam name="form.email" default="">
        <cfparam name="form.password" default="">
        
        <cfif len(trim(form.username)) and len(trim(form.firstName)) and len(trim(form.lastName)) and len(trim(form.email)) and len(trim(form.password))>
            <!--- Validate email format --->
            <cfif isValid("email", form.email)>
                <!--- Check if username or email already exists --->
                <cfquery name="checkExisting" datasource="nutricheck">
                    SELECT user_id, username, email
                    FROM users
                    WHERE username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
                    OR email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif checkExisting.recordCount eq 0>
                    <!--- Hash the password --->
                    <cfset hashedPassword = hash(form.password, "SHA-256")>
                    
                    <!--- Insert new user --->
                    <cfquery name="insertUser" datasource="nutricheck" result="insertResult">
                        INSERT INTO users (username, email, password_hash, first_name, last_name, role)
                        VALUES (
                            <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                            'user'
                        )
                    </cfquery>
                    
                    <!--- Get the newly created user --->
                    <cfquery name="newUser" datasource="nutricheck">
                        SELECT user_id, username, email, first_name, last_name, role
                        FROM users
                        WHERE user_id = <cfqueryparam value="#insertResult.generatedKey#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    
                    <!--- Auto-login the user after successful registration --->
                    <cfset session.user.loggedIn = true>
                    <cfset session.user.userId = newUser.user_id>
                    <cfset session.user.email = newUser.email>
                    <cfset session.user.firstName = newUser.first_name>
                    <cfset session.user.lastName = newUser.last_name>
                    <cfset session.user.role = newUser.role>
                    
                    <cfset response.success = true>
                    <cfset response.message = "Registration successful">
                    <cfset response.user = {
                        "user_id" = newUser.user_id,
                        "username" = newUser.username,
                        "email" = newUser.email,
                        "first_name" = newUser.first_name,
                        "last_name" = newUser.last_name,
                        "role" = newUser.role
                    }>
                <cfelse>
                    <!--- Check which field is duplicate --->
                    <cfset duplicateField = "">
                    <cfloop query="checkExisting">
                        <cfif checkExisting.username eq form.username>
                            <cfset duplicateField = "username">
                        <cfelseif checkExisting.email eq form.email>
                            <cfset duplicateField = "email">
                        </cfif>
                    </cfloop>
                    
                    <cfset response.success = false>
                    <cfset response.message = "Registration failed: " & duplicateField & " already exists">
                </cfif>
            <cfelse>
                <cfset response.success = false>
                <cfset response.message = "Invalid email format">
            </cfif>
        <cfelse>
            <cfset response.success = false>
            <cfset response.message = "All fields are required (username, firstName, lastName, email, password)">
        </cfif>
    <cfelseif url.action eq "logout">
        <!--- Logout --->
        <cfset session.user.loggedIn = false>
        <cfset session.user.userId = 0>
        <cfset session.user.email = "">
        <cfset session.user.firstName = "">
        <cfset session.user.lastName = "">
        <cfset session.user.role = "user">
        
        <cfset response.success = true>
        <cfset response.message = "Logged out successfully">
    <cfelse>
        <cfset response.success = false>
        <cfset response.message = "Invalid action">
    </cfif>
    
<cfcatch type="any">
    <cfset response.success = false>
    <cfset response.message = "Error: " & cfcatch.message>
    <cfset response.error = cfcatch.detail>
    <cfset response.type = cfcatch.type>
</cfcatch>
</cftry>

<cfscript>
    // Ensure proper case for JSON keys
    finalResponse = {};
    finalResponse["success"] = response.success;
    finalResponse["message"] = response.message;
    if (structKeyExists(response, "user")) {
        finalResponse["user"] = response.user;
    }
    if (structKeyExists(response, "token")) {
        finalResponse["token"] = response.token;
    }
    if (structKeyExists(response, "resetUrl")) {
        finalResponse["resetUrl"] = response.resetUrl;
    }
    if (structKeyExists(response, "expiresAt")) {
        finalResponse["expiresAt"] = response.expiresAt;
    }
    if (structKeyExists(response, "emailError")) {
        finalResponse["emailError"] = response.emailError;
    }
    if (structKeyExists(response, "error")) {
        finalResponse["error"] = response.error;
    }
    if (structKeyExists(response, "type")) {
        finalResponse["type"] = response.type;
    }
</cfscript>

<cfoutput>#serializeJSON(finalResponse)#</cfoutput>