# NutriCheck Quick Setup Guide

## Step 1: Database Setup

Run the following command to create the database:

```bash
mysql -u root -p < database_schema.sql
```

Or import via MySQL Workbench/phpMyAdmin using the `database_schema.sql` file.

The script will:
- Create the `nutricheck` database
- Create all necessary tables
- Insert sample categories
- Insert admin user (admin@nutricheck.com / admin123)
- Insert 5 sample products with nutrition data

## Step 2: Configure ColdFusion Datasource

1. Open ColdFusion Administrator: `http://localhost:8501/CFIDE/administrator/`

2. Navigate to: **Data & Services > Datasources**

3. Add new datasource:
   - **CF Data Source Name:** `nutricheck`
   - **Database:** `nutricheck`
   - **Server:** `localhost`
   - **Port:** `3306`
   - **Username:** `root`
   - **Password:** (your MySQL password)

4. Click **Submit** and verify connection

## Step 3: Deploy Application

1. Copy the `nutricheck` folder to your ColdFusion webroot:
   - Default location: `/opt/coldfusion/cfusion/wwwroot/` (Linux)
   - Or: `C:\ColdFusion2025\cfusion\wwwroot\` (Windows)
   - Or your custom webroot directory

2. Ensure proper permissions (read/execute for ColdFusion process)

## Step 4: Access the Application

1. Open browser and navigate to:
   ```
   http://localhost:8501/nutricheck/
   ```

2. You will be redirected to the login page

3. Login with demo credentials:
   - **Email:** admin@nutricheck.com
   - **Password:** admin123

## Step 5: Test Features

### As Admin:
1. Login with admin credentials
2. Click "Admin Panel"
3. Add a new product
4. Verify automatic grade calculation

### As User:
1. Register a new user account
2. Login with new credentials
3. Search for products
4. Click "Show Better Products" on non-A grade items
5. Test the suggestion system

## Troubleshooting

### Database Connection Failed
- Verify MySQL is running: `mysql -u root -p`
- Check datasource configuration in CF Administrator
- Verify database exists: `SHOW DATABASES;`

### 404 Error
- Check application path: `http://localhost:8501/nutricheck/`
- Verify files are in correct webroot directory
- Check ColdFusion is running on port 8501

### Login Issues
- Clear browser cache and cookies
- Verify admin user exists in database:
  ```sql
  SELECT * FROM nutricheck.users WHERE role = 'admin';
  ```
- Check session management in Application.cfc

### No Products Showing
- Verify sample data was inserted:
  ```sql
  SELECT COUNT(*) FROM nutricheck.products;
  ```
- Check browser console for JavaScript errors
- Verify API endpoints are accessible

## Default Credentials

**Admin Account:**
- Email: admin@nutricheck.com
- Password: admin123

**Test User (create via registration):**
- Register through the UI

## Database Configuration

If you need to change database credentials:

1. Edit `Application.cfc`:
   ```cfml
   <cfset application.dsn = "nutricheck">
   ```

2. Update ColdFusion datasource in Administrator

## Port Configuration

Application runs on port **8501** (default ColdFusion port).

To change:
1. Modify ColdFusion server configuration
2. Update all URLs in documentation

## Next Steps

1. Add more products via Admin Panel
2. Test search functionality
3. Try the product suggestion system
4. Create user accounts
5. Customize CSS in `assets/css/style.css`

## Support

For issues or questions:
- Check browser console for errors
- Review ColdFusion logs
- Verify database connections
- Check file permissions

Enjoy using NutriCheck! 🍎
