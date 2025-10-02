<cfif not session.user.loggedIn>
    <cflocation url="../auth/login.cfm" addtoken="false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - NutriCheck</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🍎 NutriCheck</h1>
            <div class="nav">
                <cfoutput>
                    <span style="padding: 10px; color: ##667eea;">Welcome, #session.user.firstName#!</span>
                    <cfif session.user.role eq "admin">
                        <a href="../admin/index.cfm">Admin Panel</a>
                    </cfif>
                    <a href="../api/auth.cfm?action=logout" onclick="handleLogout(event)">Logout</a>
                </cfoutput>
            </div>
        </div>
        
        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="Search for products by name, brand, or category...">
            <button class="btn" onclick="searchProducts()">Search</button>
        </div>
        
        <div class="filters-bar">
            <select id="categoryFilter" onchange="applyFilters()">
                <option value="">All Categories</option>
            </select>
            <select id="gradeFilter" onchange="applyFilters()">
                <option value="">All Grades</option>
                <option value="A">Grade A</option>
                <option value="B">Grade B</option>
                <option value="C">Grade C</option>
                <option value="D">Grade D</option>
                <option value="E">Grade E</option>
            </select>
            <button class="btn" onclick="clearFilters()">Clear</button>
        </div>
        
        <div id="message"></div>
        
        <div id="productGrid" class="product-grid">
            <!-- Products will be loaded here -->
        </div>
    </div>
    
    <script>
        // Load all products and categories on page load
        window.addEventListener('DOMContentLoaded', () => {
            loadCategories();
            loadProducts();
        });
        
        // Search on Enter key
        document.getElementById('searchInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                searchProducts();
            }
        });
        
        function loadCategories() {
            fetch('../api/products.cfm?action=getCategories')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const categorySelect = document.getElementById('categoryFilter');
                        data.categories.forEach(category => {
                            const option = document.createElement('option');
                            option.value = category.categoryId;
                            option.textContent = category.categoryName;
                            categorySelect.appendChild(option);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading categories:', error);
                });
        }
        
        function loadProducts() {
            const categoryId = document.getElementById('categoryFilter').value;
            const grade = document.getElementById('gradeFilter').value;
            
            let url = '../api/products.cfm?action=list';
            if (categoryId) url += `&categoryId=${categoryId}`;
            if (grade) url += `&grade=${grade}`;
            
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayProducts(data.products);
                    } else {
                        showMessage('Error loading products', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred while loading products', 'error');
                });
        }
        
        function searchProducts() {
            const searchTerm = document.getElementById('searchInput').value;
            fetch(`../api/products.cfm?action=search&search=${encodeURIComponent(searchTerm)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayProducts(data.products);
                        if (data.count === 0) {
                            showMessage('No products found', 'error');
                        }
                    } else {
                        showMessage('Error searching products', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred while searching', 'error');
                });
        }
        
        function displayProducts(products) {
            const grid = document.getElementById('productGrid');
            
            if (products.length === 0) {
                grid.innerHTML = '<p style="text-align: center; grid-column: 1 / -1;">No products found</p>';
                return;
            }
            
            grid.innerHTML = products.map(product => `
                <div class="product-card">
                    <div class="nutrition-grade grade-${product.nutritionGrade}">
                        ${product.nutritionGrade}
                    </div>
                    
                    <div class="product-name">${product.productName}</div>
                    <div class="product-brand">${product.brand || 'N/A'}</div>
                    <div class="product-category">${product.categoryName}</div>
                    
                    <div style="margin-top: 15px;">
                        <strong>Price:</strong> ₹${product.price ? product.price.toFixed(2) : 'N/A'}
                    </div>
                    
                    <div style="margin-top: 15px;">
                        <button class="btn btn-primary" onclick="viewProductDetail(${product.productId})">
                            View Detail
                        </button>
                    </div>
                    
                    ${product.nutritionGrade !== 'A' ? `
                        <div class="suggestion" style="margin-top: 10px;">
                            <button class="btn btn-warning btn-small" 
                                    onclick="showSuggestions(${product.productId}, '${product.nutritionGrade}', '${product.categoryName}')">
                                Show Better Products
                            </button>
                        </div>
                    ` : ''}
                </div>
            `).join('');
        }
        
        function showSuggestions(productId, currentGrade, categoryName) {
            fetch(`../api/products.cfm?action=getSuggestions&productId=${productId}&currentGrade=${currentGrade}&categoryName=${encodeURIComponent(categoryName)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.suggestions.length > 0) {
                        displaySuggestionsModal(data.suggestions, data.targetGrade, categoryName, productId);
                    } else {
                        // Try to get best products
                        showBestProducts(productId, categoryName);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred while fetching suggestions', 'error');
                });
        }
        
        function showBestProducts(productId, categoryName) {
            fetch(`../api/products.cfm?action=getBest&productId=${productId}&categoryName=${encodeURIComponent(categoryName)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.products.length > 0) {
                        displayBestProductsModal(data.products, categoryName);
                    } else {
                        showMessage('No better alternatives available', 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
        
        function displaySuggestionsModal(suggestions, targetGrade, categoryName, productId) {
            const modalHtml = `
                <div style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); 
                            display: flex; align-items: center; justify-content: center; z-index: 1000;" 
                     onclick="this.remove()">
                    <div style="background: white; padding: 30px; border-radius: 15px; max-width: 600px; 
                                max-height: 80vh; overflow-y: auto;" onclick="event.stopPropagation()">
                        <h2 style="color: #667eea; margin-bottom: 20px;">Better ${categoryName} Products (Grade ${targetGrade})</h2>
                        
                        ${suggestions.map(s => `
                            <div style="padding: 15px; border: 2px solid #f0f0f0; border-radius: 10px; margin-bottom: 15px; cursor: pointer; transition: all 0.3s ease;" 
                                 onclick="viewProductDetail(${s.productId})" 
                                 onmouseover="this.style.borderColor='#667eea'; this.style.backgroundColor='#f8f9ff';" 
                                 onmouseout="this.style.borderColor='#f0f0f0'; this.style.backgroundColor='white';">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h3 style="color: #333; margin-bottom: 5px;">${s.productName}</h3>
                                        <p style="color: #666;">${s.brand}</p>
                                        <p style="color: #667eea; font-weight: 600;">₹${s.price ? s.price.toFixed(2) : 'N/A'}</p>
                                    </div>
                                    <div class="nutrition-grade grade-${s.nutritionGrade}" style="position: static;">
                                        ${s.nutritionGrade}
                                    </div>
                                </div>
                                <div style="font-size: 12px; color: #999; margin-top: 8px; text-align: center;">
                                    Click to view details
                                </div>
                            </div>
                        `).join('')}
                        
                        <button class="btn btn-green" onclick="showBestProducts(${productId}, '${categoryName}')">
                            Show Best Products (Grade A)
                        </button>
                        
                        <button class="btn" onclick="this.closest('div[style*=position]').remove()" 
                                style="margin-left: 10px;">Close</button>
                    </div>
                </div>
            `;
            
            document.body.insertAdjacentHTML('beforeend', modalHtml);
        }
        
        function displayBestProductsModal(products, categoryName) {
            // Close existing modal if any
            const existingModal = document.querySelector('div[style*="position: fixed"]');
            if (existingModal) {
                existingModal.remove();
            }
            
            const modalHtml = `
                <div style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); 
                            display: flex; align-items: center; justify-content: center; z-index: 1000;" 
                     onclick="this.remove()">
                    <div style="background: white; padding: 30px; border-radius: 15px; max-width: 600px; 
                                max-height: 80vh; overflow-y: auto;" onclick="event.stopPropagation()">
                        <h2 style="color: #11998e; margin-bottom: 20px;">🏆 Best ${categoryName} Products (Grade A)</h2>
                        
                        ${products.map(p => `
                            <div style="padding: 15px; border: 2px solid #11998e; border-radius: 10px; margin-bottom: 15px; cursor: pointer; transition: all 0.3s ease;" 
                                 onclick="viewProductDetail(${p.productId})" 
                                 onmouseover="this.style.borderColor='#0d7377'; this.style.backgroundColor='#f0fffe';" 
                                 onmouseout="this.style.borderColor='#11998e'; this.style.backgroundColor='white';">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h3 style="color: #333; margin-bottom: 5px;">${p.productName}</h3>
                                        <p style="color: #666;">${p.brand}</p>
                                        <p style="color: #667eea; font-weight: 600;">₹${p.price ? p.price.toFixed(2) : 'N/A'}</p>
                                        <div style="font-size: 12px; color: #666; margin-top: 10px;">
                                            <div>Calories: ${p.nutrition.calories} kcal</div>
                                            <div>Protein: ${p.nutrition.protein} g</div>
                                            <div>Sugar: ${p.nutrition.sugar} g</div>
                                        </div>
                                    </div>
                                    <div class="nutrition-grade grade-A" style="position: static;">
                                        A
                                    </div>
                                </div>
                                <div style="font-size: 12px; color: #999; margin-top: 8px; text-align: center;">
                                    Click to view details
                                </div>
                            </div>
                        `).join('')}
                        
                        <button class="btn" onclick="this.closest('div[style*=position]').remove()">Close</button>
                    </div>
                </div>
            `;
            
            document.body.insertAdjacentHTML('beforeend', modalHtml);
        }
        
function viewProductDetail(productId) {
    window.location.href = `product-detail.cfm?id=${productId}`;
}
        
        function applyFilters() {
            loadProducts();
        }
        
        function clearFilters() {
            document.getElementById('categoryFilter').value = '';
            document.getElementById('gradeFilter').value = '';
            loadProducts();
        }
        
        function showMessage(message, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = `<div class="alert alert-${type}">${message}</div>`;
            setTimeout(() => {
                messageDiv.innerHTML = '';
            }, 3000);
        }
        
        function handleLogout(event) {
            event.preventDefault();
            
            fetch('../api/auth.cfm?action=logout')
                .then(response => response.json())
                .then(data => {
                    window.location.href = '../auth/login.cfm';
                })
                .catch(error => {
                    console.error('Error:', error);
                    window.location.href = '../auth/login.cfm';
                });
        }
    </script>
</body>
</html>
