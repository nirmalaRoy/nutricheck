# User Management Feature Guide

## Overview
The NutriCheck admin panel now includes a comprehensive user management system that allows administrators to add, edit, and delete users with different role assignments.

## Features

### 1. User Management Page
- **Location**: `/admin/index.cfm` (integrated into main admin panel)
- **Access**: Only available to users with admin role
- **Navigation**: Accessible from the admin dashboard by clicking the "User Management" card

### 2. User Operations

#### Add New User
- Click the "+ Add New User" button
- Fill in all required fields:
  - Username (unique)
  - Email (unique, valid email format)
  - First Name
  - Last Name
  - Password
  - Role (User or Admin)
- Submit to create the new user

#### Edit User
- Click "Edit" button next to any user in the table
- Modify any fields as needed
- **Password field**: Leave blank to keep the current password, or enter a new one to change it
- Submit to update the user

#### Delete User
- Click "Delete" button next to any user
- Confirm the deletion
- **Note**: You cannot delete your own account (safety feature)

### 3. User Roles

#### User Role
- Can access the dashboard
- Can view products and their nutritional information
- Cannot access admin panels

#### Admin Role
- All user role permissions
- Can manage products (add, edit, delete)
- Can manage categories
- Can manage users (add, edit, delete)
- Can access admin panels

## API Endpoints

### User Management API (`/api/users.cfm`)

All endpoints require admin authentication.

#### List All Users
```
GET /api/users.cfm?action=list
```
Returns all users with their details.

#### Get Single User
```
GET /api/users.cfm?action=get&userId={id}
```
Returns details for a specific user.

#### Add New User
```
POST /api/users.cfm?action=add
Form Data:
  - username
  - email
  - password
  - firstName
  - lastName
  - role (user|admin)
```

#### Update User
```
POST /api/users.cfm?action=update
Form Data:
  - userId
  - username
  - email
  - password (optional - leave blank to keep current)
  - firstName
  - lastName
  - role (user|admin)
```

#### Delete User
```
GET /api/users.cfm?action=delete&userId={id}
```
Deletes the specified user (cannot delete yourself).

## Security Features

1. **Admin-Only Access**: All user management operations require admin role
2. **Self-Deletion Prevention**: Admins cannot delete their own accounts
3. **Password Hashing**: All passwords are hashed using SHA-256
4. **Unique Constraints**: Usernames and emails must be unique
5. **Email Validation**: Email addresses are validated for proper format
6. **Role Validation**: Only 'user' and 'admin' roles are accepted

## Database Schema

The user management system uses the existing `users` table:

```sql
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Default Users

The system comes with two default users:

1. **Admin User**
   - Email: admin@nutricheck.com
   - Password: admin123
   - Role: admin

2. **Regular User**
   - Email: john@example.com
   - Password: password123
   - Role: user

## User Interface

### Navigation
- Admin Panel (`/admin/index.cfm`) - Unified dashboard with three management sections:
  - Product Management
  - Category Management  
  - User Management
- Click on any card to access that management section
- Use "Back to Dashboard" button to return to the main dashboard

### Table Display
Users are displayed in a table showing:
- User ID
- Username
- Email
- First Name
- Last Name
- Role (with color-coded badges)
- Created At timestamp
- Action buttons (Edit/Delete)

### Form Features
- Responsive two-column layout for better UX
- Required field indicators (red asterisks)
- Password field becomes optional when editing
- Role dropdown with User/Admin options
- Smooth scrolling to forms
- Success/error message notifications
- Form validation

## Usage Examples

### Creating an Admin User
1. Log in as an admin
2. Navigate to Admin Panel and click the "User Management" card
3. Click "+ Add New User"
4. Fill in the form:
   - Username: jane_admin
   - Email: jane@nutricheck.com
   - First Name: Jane
   - Last Name: Admin
   - Password: SecurePass123
   - Role: Admin
5. Click "Add User"

### Updating User Role
1. Find the user in the table
2. Click "Edit" button
3. Change the Role dropdown from "User" to "Admin"
4. Click "Update User"

### Changing User Password
1. Find the user in the table
2. Click "Edit" button
3. Enter a new password in the Password field
4. Click "Update User"

### Updating User Without Changing Password
1. Find the user in the table
2. Click "Edit" button
3. Leave the Password field blank
4. Modify other fields as needed
5. Click "Update User"

## Error Handling

The system provides clear error messages for:
- Duplicate usernames
- Duplicate email addresses
- Invalid email formats
- Invalid role values
- Missing required fields
- Unauthorized access attempts
- Self-deletion attempts

## Best Practices

1. **Password Management**: Always use strong passwords for admin accounts
2. **Role Assignment**: Only assign admin role to trusted users
3. **Regular Audits**: Periodically review user list and remove inactive accounts
4. **Email Verification**: Ensure email addresses are valid for password reset functionality
5. **Backup**: Regular database backups before bulk user operations

## Troubleshooting

### Cannot Access User Management
- Ensure you're logged in as an admin user
- Check session is active
- Verify role in database is set to 'admin'

### Duplicate Username/Email Error
- Check if username or email already exists in the system
- Use a different username or email address

### Cannot Delete User
- Verify you're not trying to delete your own account
- Ensure user exists in the database
- Check admin permissions

## Future Enhancements

Potential improvements for future versions:
- Bulk user operations
- User activity logs
- Password strength requirements
- Email verification on registration
- User profile pictures
- Last login tracking
- Account suspension/activation
- Export user list to CSV
