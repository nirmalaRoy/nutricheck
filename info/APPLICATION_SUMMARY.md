# NutriCheck - Application Summary

## 🎯 Project Overview

**NutriCheck** is a complete nutrition product rating and recommendation system built with Adobe ColdFusion, running on port 8501 with MySQL database backend.

## ✨ Key Features

### User Features
- ✅ User registration and authentication
- ✅ Product search by name, brand, or category
- ✅ Nutrition information display with grades (A-E)
- ✅ Smart product suggestions (progressive improvement)
- ✅ View best products in each category

### Admin Features
- ✅ Add new products with automatic grading
- ✅ Delete products
- ✅ View all products
- ✅ Manage nutrition data

### Product Categories
1. 🍿 Popcorn
2. 🥔 Chips
3. 🍫 Chocolates
4. 💪 Protein Supplements
5. 🍪 Biscuits

## 📊 Nutrition Grading System

| Grade | Score | Description | Color |
|-------|-------|-------------|-------|
| A | 80-100 | Best | Green |
| B | 60-79 | Better | Blue |
| C | 40-59 | Good | Orange |
| D | 20-39 | Bad | Red |
| E | 0-19 | Worst | Dark Red |

## 🗂️ File Structure

```
nutricheck/
├── Application.cfc              # App configuration & session management
├── index.cfm                    # Entry point (redirects to login)
├── login.cfm                    # User login page
├── register.cfm                 # User registration page
├── dashboard.cfm                # Main user dashboard
│
├── api/
│   ├── auth.cfm                # Authentication API (login/register/logout)
│   └── products.cfm            # Products API (list/search/suggestions)
│
├── admin/
│   ├── index.cfm               # Admin panel UI
│   └── products.cfm            # Admin products API (add/delete/list)
│
├── assets/
│   └── css/
│       └── style.css           # Modern responsive CSS
│
├── database_schema.sql          # MySQL database schema
├── README_NUTRIAPP.md           # Complete documentation
├── SETUP_INSTRUCTIONS.md        # Quick setup guide
├── DEPLOYMENT_CHECKLIST.md      # Deployment verification
└── NUTRITION_SCORING_GUIDE.md   # Scoring algorithm details
```

## 🚀 Quick Start

### 1. Database Setup
```bash
mysql -u root -p < database_schema.sql
```

### 2. Configure ColdFusion Datasource
- Open CF Administrator: `http://localhost:8501/CFIDE/administrator/`
- Create datasource named: `nutricheck`
- Database: `nutricheck`
- Server: `localhost:3306`

### 3. Deploy Application
Copy `nutricheck` folder to ColdFusion webroot

### 4. Access Application
```
http://localhost:8501/nutricheck/
```

### 5. Login
- **Admin:** admin@nutricheck.com / admin123
- **User:** Register via UI

## 🔌 API Endpoints

### Authentication API (`api/auth.cfm`)
- `?action=login` - User login
- `?action=register` - User registration
- `?action=logout` - User logout

### Products API (`api/products.cfm`)
- `?action=list` - List all products
- `?action=search&search=term` - Search products
- `?action=getSuggestions&productId=X&currentGrade=X&categoryName=X`
- `?action=getBest&categoryName=X`

### Admin API (`admin/products.cfm`)
- `?action=add` - Add new product (POST)
- `?action=delete&productId=X` - Delete product
- `?action=list` - List all products

## 💾 Database Schema

### Tables
1. **users** - User accounts (id, username, email, password_hash, role)
2. **categories** - Product categories (id, name, description)
3. **products** - Product info (id, name, brand, category_id, price)
4. **nutrition_data** - Nutrition info (id, product_id, calories, protein, etc.)
5. **product_ratings** - Calculated grades (id, product_id, grade, score)

### Sample Data Included
- 1 admin user
- 5 product categories
- 5 sample products with full nutrition data
- Calculated nutrition ratings

## 🎨 UI Features

### Modern Design
- Gradient purple background
- Card-based product layout
- Responsive grid system
- Color-coded nutrition grades
- Modal popups for suggestions
- Smooth animations

### User Experience
- Search with instant results
- Progressive suggestion system
- Grade-based color coding
- Intuitive navigation
- Mobile responsive

## 🔒 Security Features

- Password hashing (SHA-256)
- Session-based authentication
- Role-based access control
- SQL injection prevention (cfqueryparam)
- Protected admin routes
- XSS prevention

## 🧮 Nutrition Scoring Algorithm

### Positive Factors (Add Points)
- High protein (>5g): +2 per gram
- High fiber (>3g): +3 per gram

### Negative Factors (Subtract Points)
- High calories (>300): -0.1 per kcal
- High sugar (>5g): -2 per gram
- High sodium (>200mg): -0.05 per mg
- High saturated fat (>2g): -3 per gram

### Suggestion Flow
```
E → D → C → B → A
(Worst) → (Best)
```

## 📱 User Journey

### End User Flow
1. Register account
2. Login to dashboard
3. Search for products
4. View nutrition grades
5. Click "Show Better Products"
6. See improved alternatives
7. Click "Show Best Products"
8. View Grade A options

### Admin Flow
1. Login with admin credentials
2. Access admin panel
3. Add new product with nutrition data
4. System calculates grade automatically
5. Product appears in user dashboard
6. Manage existing products

## 🧪 Testing Checklist

- ✅ User registration works
- ✅ User login works
- ✅ Admin login works
- ✅ Product search works
- ✅ Grades display correctly
- ✅ Suggestions work
- ✅ Admin can add products
- ✅ Admin can delete products
- ✅ Automatic grading works
- ✅ Session management works

## 📚 Documentation Files

1. **README_NUTRIAPP.md** - Complete user guide
2. **SETUP_INSTRUCTIONS.md** - Step-by-step setup
3. **DEPLOYMENT_CHECKLIST.md** - Verification checklist
4. **NUTRITION_SCORING_GUIDE.md** - Algorithm explanation
5. **APPLICATION_SUMMARY.md** - This file

## 🛠️ Technology Stack

- **Backend:** Adobe ColdFusion 2025 (CFML)
- **Database:** MySQL 8.0+
- **Frontend:** HTML5, CSS3, JavaScript (Vanilla)
- **Server:** Built-in ColdFusion Server (Port 8501)
- **Architecture:** Tag-based CFML with API endpoints

## 📈 Future Enhancements

- Product image upload
- Barcode scanner
- User favorites
- Nutrition goals tracking
- Product reviews
- Export to PDF
- REST API with tokens
- Mobile app
- Advanced filtering
- Comparison feature

## ⚙️ Configuration

### Application.cfc Settings
```cfml
this.name = "NutriCheck"
this.sessionManagement = true
this.sessionTimeout = 2 hours
this.datasource = "nutricheck"
```

### Database Connection
- Datasource: `nutricheck`
- Host: `localhost`
- Port: `3306`
- User: `root`

## 🐛 Troubleshooting

### Common Issues

**Database Connection Failed**
- Verify MySQL is running
- Check datasource in CF Admin
- Verify credentials

**404 Error**
- Check application path
- Verify webroot location
- Restart ColdFusion

**Login Issues**
- Clear browser cache
- Check session management
- Verify admin user exists

**No Products Showing**
- Verify sample data inserted
- Check API endpoints
- Check browser console

## 📞 Support Resources

- Check browser console for errors
- Review ColdFusion logs
- Verify database connections
- Check file permissions
- Review API responses

## 🎓 Learning Outcomes

This project demonstrates:
- CFML tag-based programming
- Database design and integration
- User authentication and sessions
- Role-based access control
- API endpoint creation
- Responsive web design
- Algorithm implementation
- Security best practices

## ✅ Project Completion Status

All required features implemented:
- ✅ User registration and login
- ✅ Admin panel
- ✅ Product categories (5 types)
- ✅ Nutrition grading (A-E)
- ✅ Search functionality
- ✅ Product suggestions
- ✅ Progressive recommendations (E→D→C→B→A)
- ✅ Best product display
- ✅ MySQL integration
- ✅ HTML/CSS UI
- ✅ CFML API endpoints

## 🏁 Ready for Production

The application is complete and ready to run on Adobe ColdFusion 2025 on port 8501!

---

**Version:** 1.0  
**Created:** September 30, 2025  
**Framework:** Adobe ColdFusion 2025  
**Database:** MySQL  
**Port:** 8501  

For detailed documentation, see `README_NUTRIAPP.md`  
For setup instructions, see `SETUP_INSTRUCTIONS.md`
