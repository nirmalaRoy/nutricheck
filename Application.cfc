<cfcomponent>
    <cfset this.name = "NutriCheck">
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0, 2, 0, 0)>
    <cfset this.applicationTimeout = createTimeSpan(1, 0, 0, 0)>
    <cfset this.datasource = "nutricheck">
    
    <cffunction name="onApplicationStart" returnType="boolean" output="false">
        <cfset application.dsn = "nutricheck">
        <cfreturn true>
    </cffunction>
    
    <cffunction name="onSessionStart" returnType="void" output="false">
        <cfset session.user = structNew()>
        <cfset session.user.loggedIn = false>
        <cfset session.user.userId = 0>
        <cfset session.user.username = "">
        <cfset session.user.role = "user">
    </cffunction>
    
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <cfargument name="targetPage" type="string" required="true">
        
        <!--- Define public pages that don't require authentication --->
        <cfset var publicPages = "login.cfm,register.cfm,reset-password.cfm">
        <cfset var currentPage = listLast(arguments.targetPage, "/")>
        
        <!--- Redirect to login if not logged in and not on a public page --->
        <cfif not session.user.loggedIn and not listFindNoCase(publicPages, currentPage)>
            <cflocation url="/nutricheck/auth/login.cfm" addtoken="false">
        </cfif>
        
        <cfreturn true>
    </cffunction>
</cfcomponent>
