# NutriCheck Deployment Checklist

## Pre-Deployment Checklist

### 1. Environment Verification
- [ ] Adobe ColdFusion 2025 is installed and running
- [ ] ColdFusion is accessible at `http://localhost:8501`
- [ ] MySQL Server is installed and running
- [ ] MySQL is accessible on port 3306

### 2. Database Setup
- [ ] Create database using `database_schema.sql`
- [ ] Verify tables created: users, products, categories, nutrition_data, product_ratings
- [ ] Verify sample data inserted (5 categories, 5 products)
- [ ] Verify admin user created (admin@nutricheck.com)

### 3. ColdFusion Configuration
- [ ] Create datasource named `nutricheck` in CF Administrator
- [ ] Test datasource connection
- [ ] Verify session management is enabled
- [ ] Check application timeout settings

### 4. Application Deployment
- [ ] Copy `nutricheck` folder to ColdFusion webroot
- [ ] Verify file permissions (read/execute)
- [ ] Check Application.cfc is present
- [ ] Verify all API endpoints exist

## Post-Deployment Testing

### 5. Basic Functionality
- [ ] Access application: `http://localhost:8501/nutricheck/`
- [ ] Login page loads successfully
- [ ] Registration page loads successfully
- [ ] CSS styles are applied correctly

### 6. Authentication Testing
- [ ] Register new user account
- [ ] Login with new user credentials
- [ ] Login with admin credentials (admin@nutricheck.com / admin123)
- [ ] Logout functionality works
- [ ] Session persistence works

### 7. User Features Testing
- [ ] Dashboard loads with products
- [ ] Search functionality works
- [ ] Product cards display correctly
- [ ] Nutrition grades display (A-E)
- [ ] Product details show correctly

### 8. Suggestion System Testing
- [ ] Click "Show Better Products" on D/E grade products
- [ ] Verify better alternatives appear
- [ ] Click "Show Best Products" button
- [ ] Verify Grade A products display
- [ ] Modal windows open and close properly

### 9. Admin Panel Testing
- [ ] Access admin panel (admin role only)
- [ ] Add new product form loads
- [ ] Submit new product with nutrition data
- [ ] Verify automatic grade calculation
- [ ] View all products table
- [ ] Delete product functionality

### 10. API Endpoints Testing
- [ ] `api/auth.cfm?action=login` - Test login
- [ ] `api/auth.cfm?action=register` - Test registration
- [ ] `api/auth.cfm?action=logout` - Test logout
- [ ] `api/products.cfm?action=list` - Test product listing
- [ ] `api/products.cfm?action=search` - Test search
- [ ] `api/products.cfm?action=getSuggestions` - Test suggestions
- [ ] `api/products.cfm?action=getBest` - Test best products
- [ ] `admin/products.cfm?action=add` - Test add product
- [ ] `admin/products.cfm?action=delete` - Test delete product
- [ ] `admin/products.cfm?action=list` - Test admin list

## Security Checklist

### 11. Security Verification
- [ ] Passwords are hashed (SHA-256)
- [ ] SQL injection protection (cfqueryparam used)
- [ ] Session-based authentication works
- [ ] Protected pages require login
- [ ] Admin routes require admin role
- [ ] Logout clears session properly

## Performance Checklist

### 12. Performance Testing
- [ ] Page load times are acceptable
- [ ] Database queries execute efficiently
- [ ] Search responds quickly
- [ ] No console errors in browser
- [ ] No ColdFusion errors in logs

## Browser Compatibility

### 13. Cross-Browser Testing
- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari
- [ ] Mobile responsive design

## Data Validation

### 14. Data Integrity
- [ ] Products have correct nutrition grades
- [ ] Nutrition scores calculated correctly
- [ ] Categories display properly
- [ ] Price formatting is correct
- [ ] Foreign key relationships work

## Documentation

### 15. Documentation Review
- [ ] README_NUTRIAPP.md is complete
- [ ] SETUP_INSTRUCTIONS.md is accurate
- [ ] API endpoints are documented
- [ ] Database schema is documented

## Troubleshooting Verification

### 16. Common Issues
- [ ] Tested 404 error handling
- [ ] Tested database connection failure
- [ ] Tested invalid login attempts
- [ ] Tested empty search results
- [ ] Tested adding product with missing data

## Production Readiness

### 17. Final Checks
- [ ] All sample data loads correctly
- [ ] No hardcoded credentials (except demos)
- [ ] Error messages are user-friendly
- [ ] Success messages appear correctly
- [ ] Application.cfc settings are correct

## Optional Enhancements

### 18. Future Improvements (Not Required)
- [ ] Add more sample products
- [ ] Customize CSS branding
- [ ] Add product images
- [ ] Implement product editing
- [ ] Add user profile management
- [ ] Export functionality
- [ ] Email notifications
- [ ] Password reset feature

## Sign-Off

**Deployment Date:** ___________

**Deployed By:** ___________

**Verified By:** ___________

**Notes:**
_____________________________________
_____________________________________
_____________________________________

## Quick Reference

### Default URLs
- Application: `http://localhost:8501/nutricheck/`
- Login: `http://localhost:8501/nutricheck/login.cfm`
- Dashboard: `http://localhost:8501/nutricheck/dashboard.cfm`
- Admin: `http://localhost:8501/nutricheck/admin/`

### Default Credentials
- Admin: admin@nutricheck.com / admin123

### Database Info
- Database: `nutricheck`
- Tables: 5 (users, products, categories, nutrition_data, product_ratings)
- Sample Data: 1 admin, 5 categories, 5 products

### Key Files
- Application.cfc - Main configuration
- login.cfm / register.cfm - Authentication UI
- dashboard.cfm - Main user interface
- admin/index.cfm - Admin panel
- api/auth.cfm - Authentication API
- api/products.cfm - Products API
- admin/products.cfm - Admin API

---

**Status:** ☐ Not Started | ☐ In Progress | ☐ Completed | ☐ Issues Found

**Overall Health:** ☐ Healthy | ☐ Needs Attention | ☐ Critical Issues
