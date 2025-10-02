# 🍎 NutriCheck - Nutrition Product Rating System

A comprehensive Adobe ColdFusion application for rating food products based on nutritional content with intelligent product recommendations.

## 🌟 Overview

NutriCheck helps users make healthier food choices by:
- Rating products from A (Best) to E (Worst) based on nutrition
- Providing smart suggestions for better alternatives
- Progressive recommendations guiding users to the healthiest options

## 📁 Project Structure

```
nutricheck/
├── db/                          # Database files
│   ├── nutricheck_schema.sql    # Complete database schema with sample data
│   ├── calculate_grade.sql      # Grade recalculation script
│   └── README.md               # Database documentation
├── info/                        # Documentation and guides
│   ├── APPLICATION_SUMMARY.md   # Application overview
│   ├── NUTRIScore_IMPLEMENTATION.md  # Nutri-Score system guide
│   ├── SETUP_INSTRUCTIONS.md   # Detailed setup guide
│   └── README.md               # Information files guide
├── api/                         # API endpoints
├── admin/                       # Admin interface
├── components/                  # ColdFusion components
└── assets/                      # CSS and static files
```

## ⚡ Quick Start

### Prerequisites
- Adobe ColdFusion 2025 (running on port 8501)
- MySQL Server
- Web browser

### Setup (3 Steps)

1. **Create Database**
   ```bash
   mysql -u root -p < db/nutricheck_schema.sql
   ```

2. **Configure ColdFusion Datasource**
   - Open CF Administrator: `http://localhost:8501/CFIDE/administrator/`
   - Add datasource named `nutricheck` pointing to the database

3. **Deploy Application**
   - Copy `nutricheck` folder to ColdFusion webroot
   - Access: `http://localhost:8501/nutricheck/`

### Login
- **Admin:** admin@nutricheck.com / admin123
- **User:** Register via UI

## ✨ Features

### For End Users
- 🔍 Search products by name, brand, or category
- 📊 View nutrition grades (A-E) with color coding
- 💡 Get better product suggestions
- 🏆 See best alternatives in each category
- 📱 Responsive modern UI

### For Administrators
- ➕ Add new products with nutrition data
- 🤖 Automatic nutrition scoring and grading
- 🗑️ Delete products
- 📋 View complete product catalog

## 📊 Grading System

| Grade | Score | Description |
|-------|-------|-------------|
| A | 80-100 | Best - Excellent nutrition |
| B | 60-79 | Better - Good nutrition |
| C | 40-59 | Good - Moderate nutrition |
| D | 20-39 | Bad - Poor nutrition |
| E | 0-19 | Worst - Very poor nutrition |

## 🎯 Product Categories

1. 🍿 **Popcorn** - Various popcorn products
2. 🥔 **Chips** - Potato chips and snacks
3. 🍫 **Chocolates** - Chocolate bars and confections
4. 💪 **Protein Supplements** - Protein powders
5. 🍪 **Biscuits** - Cookies and biscuits

## 🔄 How It Works

1. User searches for a product
2. System displays nutrition grade
3. For non-A products, user clicks "Show Better Products"
4. System suggests next grade level (E→D→C→B)
5. User can view best (Grade A) products

## 📁 Project Structure

```
nutricheck/
├── Application.cfc              # App configuration
├── login.cfm / register.cfm     # Authentication pages
├── dashboard.cfm                # Main user interface
├── api/
│   ├── auth.cfm                # Auth endpoints
│   └── products.cfm            # Product endpoints
├── admin/
│   ├── index.cfm               # Admin panel
│   └── products.cfm            # Admin API
└── assets/css/style.css         # Styling
```

## 🛠️ Technology Stack

- **Backend:** Adobe ColdFusion 2025 (CFML Tags)
- **Database:** MySQL
- **Frontend:** HTML5, CSS3, JavaScript
- **Server:** Built-in ColdFusion Server (Port 8501)

## 📚 Documentation

- `QUICK_START.txt` - Quick setup guide
- `SETUP_INSTRUCTIONS.md` - Detailed setup
- `DEPLOYMENT_CHECKLIST.md` - Verification checklist
- `NUTRITION_SCORING_GUIDE.md` - Scoring algorithm
- `APPLICATION_SUMMARY.md` - Complete overview

## 🧪 Sample Data

Includes pre-populated data:
- 1 admin user
- 5 product categories
- 5 sample products with nutrition data
- Calculated ratings

## 🔒 Security

- SHA-256 password hashing
- Session-based authentication
- Role-based access control
- SQL injection prevention
- Protected admin routes

## 🎨 UI Features

- Modern gradient design
- Color-coded nutrition grades
- Responsive card layout
- Modal popups for suggestions
- Smooth animations

## 📱 Screenshots

### Dashboard
Clean, modern interface with product cards and nutrition grades

### Search
Instant product search with filtering

### Suggestions
Progressive recommendations guiding to better choices

### Admin Panel
Easy product management with auto-grading

## 🚀 Getting Started

See `QUICK_START.txt` for the fastest way to get running!

## 📞 Support

For issues:
1. Check browser console for errors
2. Review ColdFusion logs
3. Verify database connection
4. Check documentation files

## 📝 License

Educational/Demo purposes

## 🎓 Learning Outcomes

This project demonstrates:
- CFML tag-based programming
- Database integration
- User authentication
- API development
- Responsive design
- Algorithm implementation

---

**Version:** 1.0  
**Created:** September 30, 2025  
**Framework:** Adobe ColdFusion 2025  
**Port:** 8501

**Ready to run!** 🚀
