<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - NutriCheck</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="login-container">
        <h2>🍎 Reset Your Password</h2>
        
        <div id="message"></div>
        
        <cfparam name="url.token" default="">
        
        <cfif len(trim(url.token))>
            <!--- Validate token --->
            <cfquery name="validateToken" datasource="nutricheck">
                SELECT email, expires_at
                FROM password_reset_tokens
                WHERE token = <cfqueryparam value="#url.token#" cfsqltype="cf_sql_varchar">
                AND is_active = 1
                AND expires_at > <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            </cfquery>
            
            <cfif validateToken.recordCount eq 1>
                <form id="resetPasswordForm" method="post" action="../api/auth.cfm?action=resetPassword">
                    <input type="hidden" name="token" value="<cfoutput>#url.token#</cfoutput>">
                    
                    <div class="form-group">
                        <label for="password">New Password:</label>
                        <input type="password" id="password" name="password" required minlength="6">
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password:</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6">
                    </div>
                    
                    <button type="submit" class="btn" style="width: 100%;">Reset Password</button>
                </form>
                
                <p style="text-align: center; margin-top: 20px;">
                    <a href="login.cfm" style="color: #667eea;">Back to Login</a>
                </p>
            <cfelse>
                <div class="alert alert-error">
                    <h3>Invalid or Expired Link</h3>
                    <p>This password reset link is invalid or has expired. Please request a new password reset.</p>
                </div>
                
                <div style="text-align: center; margin-top: 20px;">
                    <a href="login.cfm" class="btn">Back to Login</a>
                </div>
            </cfif>
        <cfelse>
            <div class="alert alert-error">
                <h3>Invalid Link</h3>
                <p>No reset token provided. Please use the link from your email.</p>
            </div>
            
            <div style="text-align: center; margin-top: 20px;">
                <a href="login.cfm" class="btn">Back to Login</a>
            </div>
        </cfif>
    </div>
    
    <script>
        <cfif len(trim(url.token)) and validateToken.recordCount eq 1>
            document.getElementById('resetPasswordForm').addEventListener('submit', function(e) {
                e.preventDefault();
                
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirmPassword').value;
                
                if (password !== confirmPassword) {
                    document.getElementById('message').innerHTML = 
                        '<div class="alert alert-error">Passwords do not match</div>';
                    return;
                }
                
                if (password.length < 6) {
                    document.getElementById('message').innerHTML = 
                        '<div class="alert alert-error">Password must be at least 6 characters long</div>';
                    return;
                }
                
                const formData = new FormData(this);
                
                fetch('../api/auth.cfm?action=resetPassword', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    const messageDiv = document.getElementById('message');
                    
                    if (data.SUCCESS) {
                        messageDiv.innerHTML = '<div class="alert alert-success">' + data.MESSAGE + '</div>';
                        document.getElementById('resetPasswordForm').style.display = 'none';
                        setTimeout(() => {
                            window.location.href = 'login.cfm';
                        }, 3000);
                    } else {
                        messageDiv.innerHTML = '<div class="alert alert-error">' + data.MESSAGE + '</div>';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('message').innerHTML = 
                        '<div class="alert alert-error">An error occurred. Please try again.</div>';
                });
            });
        </cfif>
    </script>
</body>
</html>
