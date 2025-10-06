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
    
</cfcomponent>
