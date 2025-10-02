<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - NutriCheck</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="login-container">
        <h2>🍎 NutriCheck Login</h2>
        
        <div id="message"></div>
        
        <form id="loginForm" method="post" action="../api/auth.cfm?action=login">
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <button type="submit" class="btn" style="width: 100%;">Login</button>
        </form>
        
        <p style="text-align: center; margin-top: 20px;">
            Don't have an account? <a href="register.cfm" style="color: #667eea;">Register here</a>
        </p>
        
        <p style="text-align: center; margin-top: 10px;">
            <a href="#" id="forgotPasswordLink" style="color: #667eea; text-decoration: none;">Forgot your password?</a>
        </p>
        
        <p style="text-align: center; margin-top: 10px; font-size: 12px; color: #999;">
            Demo: admin@nutricheck.com / admin123
        </p>
    </div>
    
    <!-- Forgot Password Modal -->
    <div id="forgotPasswordModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
        <div style="background-color: #fefefe; margin: 15% auto; padding: 20px; border: 1px solid #888; width: 80%; max-width: 400px; border-radius: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h3 style="margin: 0;">Reset Password</h3>
                <span id="closeForgotModal" style="color: #aaa; font-size: 28px; font-weight: bold; cursor: pointer;">&times;</span>
            </div>
            
            <div id="forgotMessage"></div>
            
            <form id="forgotPasswordForm">
                <div class="form-group">
                    <label for="forgotEmail">Email:</label>
                    <input type="email" id="forgotEmail" name="email" required>
                </div>
                
                <div style="display: flex; gap: 10px; margin-top: 20px;">
                    <button type="submit" class="btn" style="flex: 1;">Send Reset Link</button>
                    <button type="button" id="cancelForgot" class="btn" style="flex: 1; background-color: #6c757d;">Cancel</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            
            fetch('../api/auth.cfm?action=login', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                console.log('Login response:', data);
                const messageDiv = document.getElementById('message');
                
                if (data.SUCCESS || data.success) {
                    console.log('Login successful, redirecting...');
                    messageDiv.innerHTML = '<div class="alert alert-success">' + (data.MESSAGE || data.message) + '</div>';
                    setTimeout(() => {
                        console.log('Redirecting to dashboard...');
                        window.location.href = '../pages/dashboard.cfm';
                    }, 1000);
                } else {
                    console.log('Login failed:', data.MESSAGE || data.message);
                    messageDiv.innerHTML = '<div class="alert alert-error">' + (data.MESSAGE || data.message) + '</div>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('message').innerHTML = 
                    '<div class="alert alert-error">An error occurred. Please try again.</div>';
            });
        });
        
        // Forgot Password Modal functionality
        document.getElementById('forgotPasswordLink').addEventListener('click', function(e) {
            e.preventDefault();
            document.getElementById('forgotPasswordModal').style.display = 'block';
        });
        
        document.getElementById('closeForgotModal').addEventListener('click', function() {
            document.getElementById('forgotPasswordModal').style.display = 'none';
        });
        
        document.getElementById('cancelForgot').addEventListener('click', function() {
            document.getElementById('forgotPasswordModal').style.display = 'none';
        });
        
        // Close modal when clicking outside
        window.addEventListener('click', function(event) {
            const modal = document.getElementById('forgotPasswordModal');
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        });
        
        // Forgot Password Form submission
        document.getElementById('forgotPasswordForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            
            fetch('../api/auth.cfm?action=forgotPassword', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                const messageDiv = document.getElementById('forgotMessage');
                
                if (data.SUCCESS || data.success) {
                    messageDiv.innerHTML = '<div class="alert alert-success">' + (data.MESSAGE || data.message) + '</div>';
                    document.getElementById('forgotPasswordForm').reset();
                    setTimeout(() => {
                        document.getElementById('forgotPasswordModal').style.display = 'none';
                        messageDiv.innerHTML = '';
                    }, 3000);
                } else {
                    messageDiv.innerHTML = '<div class="alert alert-error">' + (data.MESSAGE || data.message) + '</div>';
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('forgotMessage').innerHTML = 
                    '<div class="alert alert-error">An error occurred. Please try again.</div>';
            });
        });
    </script>
</body>
</html>
