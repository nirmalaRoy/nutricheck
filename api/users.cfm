<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="url.action" default="list">
<cfparam name="url.userId" default="0">

<cfset response = {}>

<cftry>
    <!--- Check if user is admin --->
    <cfif not structKeyExists(session, "user")>
        <cfset response["success"] = false>
        <cfset response["message"] = "Session not found. Please log in.">
        <cfset response["debug"] = "session.user does not exist">
        <cfset response["sessionExists"] = false>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfif not structKeyExists(session.user, "loggedIn") or not session.user.loggedIn>
        <cfset response["success"] = false>
        <cfset response["message"] = "Not logged in. Please log in.">
        <cfset response["debug"] = "session.user.loggedIn is false or does not exist">
        <cfset response["sessionExists"] = true>
        <cfset response["loggedIn"] = structKeyExists(session.user, "loggedIn") ? session.user.loggedIn : "undefined">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfif not structKeyExists(session.user, "role") or session.user.role neq "admin">
        <cfset response["success"] = false>
        <cfset response["message"] = "Unauthorized access. Admin privileges required.">
        <cfset response["debug"] = structKeyExists(session.user, "role") ? "User role is: " & session.user.role : "Role not set in session">
        <cfset response["sessionExists"] = true>
        <cfset response["loggedIn"] = true>
        <cfset response["userRole"] = structKeyExists(session.user, "role") ? session.user.role : "undefined">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfif url.action eq "list">
        <!--- List All Users --->
        <cfquery name="getUsers" datasource="nutricheck">
            SELECT user_id, username, email, first_name, last_name, role, created_at, updated_at
            FROM users
            ORDER BY created_at DESC
        </cfquery>
        
        <cfset users = []>
        <cfloop query="getUsers">
            <cfset userData = {
                "userId" = user_id,
                "username" = username,
                "email" = email,
                "firstName" = first_name,
                "lastName" = last_name,
                "role" = role,
                "createdAt" = dateFormat(created_at, "yyyy-mm-dd") & " " & timeFormat(created_at, "HH:mm:ss"),
                "updatedAt" = dateFormat(updated_at, "yyyy-mm-dd") & " " & timeFormat(updated_at, "HH:mm:ss")
            }>
            <cfset arrayAppend(users, userData)>
        </cfloop>
        
        <cfset response["success"] = true>
        <cfset response["users"] = users>
        <cfset response["count"] = arrayLen(users)>
        
    <cfelseif url.action eq "get">
        <!--- Get Single User --->
        <cfquery name="getUser" datasource="nutricheck">
            SELECT user_id, username, email, first_name, last_name, role, created_at, updated_at
            FROM users
            WHERE user_id = <cfqueryparam value="#url.userId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif getUser.recordCount gt 0>
            <cfset userData = {
                "userId" = getUser.user_id,
                "username" = getUser.username,
                "email" = getUser.email,
                "firstName" = getUser.first_name,
                "lastName" = getUser.last_name,
                "role" = getUser.role
            }>
            
            <cfset response["success"] = true>
            <cfset response["user"] = userData>
        <cfelse>
            <cfset response["success"] = false>
            <cfset response["message"] = "User not found">
        </cfif>
        
    <cfelseif url.action eq "add">
        <!--- Add New User --->
        <cfparam name="form.username" default="">
        <cfparam name="form.email" default="">
        <cfparam name="form.password" default="">
        <cfparam name="form.firstName" default="">
        <cfparam name="form.lastName" default="">
        <cfparam name="form.role" default="user">
        
        <!--- Validate required fields --->
        <cfif len(trim(form.username)) and len(trim(form.email)) and len(trim(form.password)) and len(trim(form.firstName)) and len(trim(form.lastName))>
            <!--- Validate email format --->
            <cfif isValid("email", form.email)>
                <!--- Validate role --->
                <cfif form.role eq "user" or form.role eq "admin">
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
                                <cfqueryparam value="#form.role#" cfsqltype="cf_sql_varchar">
                            )
                        </cfquery>
                        
                        <cfset response["success"] = true>
                        <cfset response["message"] = "User added successfully">
                        <cfset response["userId"] = insertResult.generatedKey>
                    <cfelse>
                        <!--- Check which field is duplicate --->
                        <cfset duplicateField = "">
                        <cfloop query="checkExisting">
                            <cfif checkExisting.username eq form.username>
                                <cfset duplicateField = "Username">
                            <cfelseif checkExisting.email eq form.email>
                                <cfset duplicateField = "Email">
                            </cfif>
                        </cfloop>
                        
                        <cfset response["success"] = false>
                        <cfset response["message"] = duplicateField & " already exists">
                    </cfif>
                <cfelse>
                    <cfset response["success"] = false>
                    <cfset response["message"] = "Invalid role. Must be 'user' or 'admin'">
                </cfif>
            <cfelse>
                <cfset response["success"] = false>
                <cfset response["message"] = "Invalid email format">
            </cfif>
        <cfelse>
            <cfset response["success"] = false>
            <cfset response["message"] = "All fields are required">
        </cfif>
        
    <cfelseif url.action eq "update">
        <!--- Update User --->
        <cfparam name="form.userId" default="0">
        <cfparam name="form.username" default="">
        <cfparam name="form.email" default="">
        <cfparam name="form.firstName" default="">
        <cfparam name="form.lastName" default="">
        <cfparam name="form.role" default="user">
        <cfparam name="form.password" default="">
        
        <!--- Validate required fields --->
        <cfif val(form.userId) gt 0 and len(trim(form.username)) and len(trim(form.email)) and len(trim(form.firstName)) and len(trim(form.lastName))>
            <!--- Validate email format --->
            <cfif isValid("email", form.email)>
                <!--- Validate role --->
                <cfif form.role eq "user" or form.role eq "admin">
                    <!--- Check if username or email already exists for other users --->
                    <cfquery name="checkExisting" datasource="nutricheck">
                        SELECT user_id, username, email
                        FROM users
                        WHERE (username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">
                        OR email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">)
                        AND user_id != <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    
                    <cfif checkExisting.recordCount eq 0>
                        <!--- Update user --->
                        <cfif len(trim(form.password))>
                            <!--- Update with new password --->
                            <cfset hashedPassword = hash(form.password, "SHA-256")>
                            <cfquery name="updateUser" datasource="nutricheck">
                                UPDATE users
                                SET username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
                                    email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                                    password_hash = <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                                    first_name = <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                                    last_name = <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                                    role = <cfqueryparam value="#form.role#" cfsqltype="cf_sql_varchar">
                                WHERE user_id = <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_integer">
                            </cfquery>
                        <cfelse>
                            <!--- Update without changing password --->
                            <cfquery name="updateUser" datasource="nutricheck">
                                UPDATE users
                                SET username = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar">,
                                    email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                                    first_name = <cfqueryparam value="#form.firstName#" cfsqltype="cf_sql_varchar">,
                                    last_name = <cfqueryparam value="#form.lastName#" cfsqltype="cf_sql_varchar">,
                                    role = <cfqueryparam value="#form.role#" cfsqltype="cf_sql_varchar">
                                WHERE user_id = <cfqueryparam value="#form.userId#" cfsqltype="cf_sql_integer">
                            </cfquery>
                        </cfif>
                        
                        <cfset response["success"] = true>
                        <cfset response["message"] = "User updated successfully">
                    <cfelse>
                        <!--- Check which field is duplicate --->
                        <cfset duplicateField = "">
                        <cfloop query="checkExisting">
                            <cfif checkExisting.username eq form.username>
                                <cfset duplicateField = "Username">
                            <cfelseif checkExisting.email eq form.email>
                                <cfset duplicateField = "Email">
                            </cfif>
                        </cfloop>
                        
                        <cfset response["success"] = false>
                        <cfset response["message"] = duplicateField & " already exists">
                    </cfif>
                <cfelse>
                    <cfset response["success"] = false>
                    <cfset response["message"] = "Invalid role. Must be 'user' or 'admin'">
                </cfif>
            <cfelse>
                <cfset response["success"] = false>
                <cfset response["message"] = "Invalid email format">
            </cfif>
        <cfelse>
            <cfset response["success"] = false>
            <cfset response["message"] = "All fields are required">
        </cfif>
        
    <cfelseif url.action eq "delete">
        <!--- Delete User --->
        <cfif val(url.userId) gt 0>
            <!--- Prevent deleting yourself --->
            <cfif val(url.userId) eq session.user.userId>
                <cfset response["success"] = false>
                <cfset response["message"] = "You cannot delete your own account">
            <cfelse>
                <!--- Check if user exists --->
                <cfquery name="checkUser" datasource="nutricheck">
                    SELECT user_id
                    FROM users
                    WHERE user_id = <cfqueryparam value="#url.userId#" cfsqltype="cf_sql_integer">
                </cfquery>
                
                <cfif checkUser.recordCount gt 0>
                    <!--- Delete user --->
                    <cfquery name="deleteUser" datasource="nutricheck">
                        DELETE FROM users
                        WHERE user_id = <cfqueryparam value="#url.userId#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    
                    <cfset response["success"] = true>
                    <cfset response["message"] = "User deleted successfully">
                <cfelse>
                    <cfset response["success"] = false>
                    <cfset response["message"] = "User not found">
                </cfif>
            </cfif>
        <cfelse>
            <cfset response["success"] = false>
            <cfset response["message"] = "Invalid user ID">
        </cfif>
        
    <cfelse>
        <cfset response["success"] = false>
        <cfset response["message"] = "Invalid action">
    </cfif>
    
    <cfcatch type="any">
        <cfset response["success"] = false>
        <cfset response["message"] = "Error: " & cfcatch.message>
        <cfset response["error"] = cfcatch.detail>
        <cfset response["type"] = cfcatch.type>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
