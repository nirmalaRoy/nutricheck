<cfif not session.user.loggedIn or session.user.role neq "admin">
    <cflocation url="../auth/login.cfm" addtoken="false">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - NutriCheck</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔧 Admin Panel</h1>
            <div class="nav">
                <a href="../pages/dashboard.cfm">Dashboard</a>
                <a href="../api/auth.cfm?action=logout" onclick="handleLogout(event)">Logout</a>
            </div>
        </div>
        
        
        <div class="admin-panel">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>Product Management</h2>
                <button type="button" id="toggleAddForm" class="btn btn-primary">+ Add New Product</button>
            </div>
            
            <div id="addProductSection" style="display: none;">
                <h3>Add New Product</h3>
                <p style="color: #666; font-size: 14px; margin-bottom: 20px;">
                    <span style="color: red;">*</span> Required fields. Other fields are optional and can be filled later.
                </p>
                <form id="addProductForm">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label for="productName">Product Name: <span style="color: red;">*</span></label>
                        <input type="text" id="productName" name="productName" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="brand">Brand:</label>
                        <input type="text" id="brand" name="brand">
                    </div>
                    
                    <div class="form-group">
                        <label for="category">Category: <span style="color: red;">*</span></label>
                        <select id="category" name="categoryId" required>
                            <option value="">Select Category</option>
                            <!-- Categories will be loaded dynamically -->
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="price">Price (₹):</label>
                        <input type="number" id="price" name="price" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="servingSize">Serving Size:</label>
                        <input type="text" id="servingSize" name="servingSize" placeholder="e.g., 100g">
                    </div>
                    
                    <div class="form-group">
                        <label for="calories">Calories (per 100g):</label>
                        <input type="number" id="calories" name="calories" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="protein">Protein (g):</label>
                        <input type="number" id="protein" name="protein" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="carbs">Carbohydrates (g):</label>
                        <input type="number" id="carbs" name="carbs" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="fat">Fat (g):</label>
                        <input type="number" id="fat" name="fat" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="fiber">Fiber (g):</label>
                        <input type="number" id="fiber" name="fiber" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="sugar">Sugar (g):</label>
                        <input type="number" id="sugar" name="sugar" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="sodium">Sodium (mg):</label>
                        <input type="number" id="sodium" name="sodium" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="saturatedFat">Saturated Fat (g):</label>
                        <input type="number" id="saturatedFat" name="saturatedFat" step="0.01">
                    </div>
                    
                    <div class="form-group">
                        <label for="transFat">Trans Fat (g):</label>
                        <input type="number" id="transFat" name="transFat" step="0.01" value="0">
                    </div>
                    
                    <div class="form-group">
                        <label for="cholesterol">Cholesterol (mg):</label>
                        <input type="number" id="cholesterol" name="cholesterol" step="0.01" value="0">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description:</label>
                    <textarea id="description" name="description" rows="3"></textarea>
                </div>
                
                    <button type="submit" class="btn">Add Product</button>
                    <button type="button" class="btn btn-secondary" onclick="cancelAdd()">Cancel</button>
                </form>
            </div>
            
            <div id="message" style="margin-top: 20px;"></div>
        </div>
        
        <div class="admin-panel" style="margin-top: 30px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>All Products</h2>
                <button type="button" id="toggleCategoryManagement" class="btn btn-secondary">Manage Categories</button>
            </div>
            
            <!-- Filter Controls -->
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                <div style="display: grid; grid-template-columns: 1fr 1fr auto; gap: 15px; align-items: end;">
                    <div class="form-group">
                        <label for="categoryFilter">Filter by Category:</label>
                        <select id="categoryFilter" style="width: 100%;">
                            <option value="">All Categories</option>
                            <!-- Categories will be loaded dynamically -->
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="gradeFilter">Filter by Grade:</label>
                        <select id="gradeFilter" style="width: 100%;">
                            <option value="">All Grades</option>
                            <option value="A">Grade A</option>
                            <option value="B">Grade B</option>
                            <option value="C">Grade C</option>
                            <option value="D">Grade D</option>
                            <option value="E">Grade E</option>
                        </select>
                    </div>
                    
                    <div>
                        <button type="button" id="clearFilters" class="btn btn-secondary">Clear Filters</button>
                    </div>
                </div>
                
                <div style="margin-top: 10px; font-size: 14px; color: #666;">
                    <span id="filterResults">Showing all products</span>
                </div>
            </div>
            
            <div id="productsTable"></div>
        </div>
        
        <div class="admin-panel" style="margin-top: 30px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>Category Management</h2>
                <button type="button" id="toggleAddCategoryForm" class="btn btn-primary">+ Add New Category</button>
            </div>
            
            <div id="addCategorySection" style="display: none;">
                <h3>Add New Category</h3>
                <form id="addCategoryForm">
                    <div class="form-group">
                        <label for="categoryName">Category Name:</label>
                        <input type="text" id="categoryName" name="categoryName" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="categoryDescription">Description:</label>
                        <textarea id="categoryDescription" name="description" rows="3"></textarea>
                    </div>
                    
                    <button type="submit" class="btn">Add Category</button>
                    <button type="button" class="btn btn-secondary" onclick="cancelAddCategory()">Cancel</button>
                </form>
            </div>
            
            <div id="categoriesTable"></div>
        </div>
    </div>
    
    <script>
        // Global variables for filtering
        let allProducts = [];
        let filteredProducts = [];
        
        window.addEventListener('DOMContentLoaded', () => {
            console.log('Admin panel loaded - version with category management');
            loadCategories();
            loadAllProducts();
            loadCategoriesTable();
            setupSearchAndFilters();
            
            // Toggle add form visibility
            document.getElementById('toggleAddForm').addEventListener('click', function() {
                const addSection = document.getElementById('addProductSection');
                if (addSection.style.display === 'none') {
                    addSection.style.display = 'block';
                    this.textContent = 'Cancel Add';
                    this.className = 'btn btn-secondary';
                    
                    // Scroll to the add form smoothly
                    setTimeout(() => {
                        addSection.scrollIntoView({ 
                            behavior: 'smooth', 
                            block: 'start' 
                        });
                    }, 100);
                } else {
                    addSection.style.display = 'none';
                    this.textContent = '+ Add New Product';
                    this.className = 'btn btn-primary';
                    document.getElementById('addProductForm').reset();
                }
            });
            
            // Toggle add category form visibility
            document.getElementById('toggleAddCategoryForm').addEventListener('click', function() {
                const addSection = document.getElementById('addCategorySection');
                if (addSection.style.display === 'none') {
                    addSection.style.display = 'block';
                    this.textContent = 'Cancel Add';
                    this.className = 'btn btn-secondary';
                    
                    // Scroll to the add category form smoothly
                    setTimeout(() => {
                        addSection.scrollIntoView({ 
                            behavior: 'smooth', 
                            block: 'start' 
                        });
                    }, 100);
                } else {
                    addSection.style.display = 'none';
                    this.textContent = '+ Add New Category';
                    this.className = 'btn btn-primary';
                    document.getElementById('addCategoryForm').reset();
                }
            });
            
            // Toggle category management visibility
            document.getElementById('toggleCategoryManagement').addEventListener('click', function() {
                const categoryPanel = document.querySelector('.admin-panel:last-child');
                if (categoryPanel.style.display === 'none') {
                    categoryPanel.style.display = 'block';
                    this.textContent = 'Hide Categories';
                    
                    // Scroll to the category section smoothly
                    setTimeout(() => {
                        categoryPanel.scrollIntoView({ 
                            behavior: 'smooth', 
                            block: 'start' 
                        });
                    }, 100);
                } else {
                    categoryPanel.style.display = 'none';
                    this.textContent = 'Manage Categories';
                }
            });
            
            // Show category management section by default
            const categoryPanel = document.querySelector('.admin-panel:last-child');
            console.log('Category panel found:', categoryPanel);
            if (categoryPanel) {
                categoryPanel.style.display = 'block';
                document.getElementById('toggleCategoryManagement').textContent = 'Hide Categories';
                console.log('Category management section made visible');
            } else {
                console.error('Category panel not found!');
            }
            
            // Check if all required elements exist
            const requiredElements = [
                'categoriesTable',
                'toggleCategoryManagement',
                'toggleAddCategoryForm',
                'addCategorySection'
            ];
            
            requiredElements.forEach(elementId => {
                const element = document.getElementById(elementId);
                console.log(`Element ${elementId}:`, element ? 'Found' : 'NOT FOUND');
            });
        });
        
        document.getElementById('addProductForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const productId = this.getAttribute('data-product-id');
            const isEdit = productId !== null;
            
            console.log('Form submission - Product ID:', productId, 'Is Edit:', isEdit);
            
            // Add product ID to form data for updates
            if (isEdit) {
                formData.append('productId', productId);
                console.log('Added productId to form data:', productId);
                
                // Verify the productId is actually in the form data
                console.log('Form data verification:');
                for (let [key, value] of formData.entries()) {
                    console.log(`  ${key}: ${value}`);
                }
            }
            
            const action = isEdit ? 'update' : 'add';
            console.log('Action:', action);
            
            fetch(`products.cfm?action=${action}`, {
                method: 'POST',
                body: formData
            })
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response headers:', response.headers);
                return response.json();
            })
            .then(data => {
                console.log('Update response:', data);
                if (data.success) {
                    showMessage(data.message, 'success');
                    
                    // Log the updated product info if available
                    if (data.updatedProduct) {
                        console.log('Updated product:', data.updatedProduct);
                    }
                    
                    loadAllProducts();
                    // Refresh filters after product changes
                    applyFilters();
                    
                    if (isEdit) {
                        // For updates, just hide the form without resetting
                        document.getElementById('addProductSection').style.display = 'none';
                        document.getElementById('toggleAddForm').textContent = '+ Add New Product';
                        document.getElementById('toggleAddForm').className = 'btn btn-primary';
                        this.removeAttribute('data-product-id');
                        console.log('Form reset for edit mode');
                    } else {
                        // For new products, reset the form
                        this.reset();
                        document.getElementById('addProductSection').style.display = 'none';
                        document.getElementById('toggleAddForm').textContent = '+ Add New Product';
                        document.getElementById('toggleAddForm').className = 'btn btn-primary';
                        console.log('Form reset for add mode');
                    }
                } else {
                    console.error('Update failed:', data.message);
                    showMessage(data.message, 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showMessage('An error occurred', 'error');
            });
        });
        
        // Category form submission
        document.getElementById('addCategoryForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const categoryId = this.getAttribute('data-category-id');
            const isEdit = categoryId !== null;
            
            // Add category ID to form data for updates
            if (isEdit) {
                formData.append('categoryId', categoryId);
            }
            
            const action = isEdit ? 'updateCategory' : 'addCategory';
            
            fetch(`products.cfm?action=${action}`, {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showMessage(data.message, 'success');
                    this.reset();
                    loadCategories();
                    loadCategoriesTable();
                    // Hide the form after successful submission
                    document.getElementById('addCategorySection').style.display = 'none';
                    document.getElementById('toggleAddCategoryForm').textContent = '+ Add New Category';
                    document.getElementById('toggleAddCategoryForm').className = 'btn btn-primary';
                    this.removeAttribute('data-category-id');
                } else {
                    showMessage(data.message, 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showMessage('An error occurred', 'error');
            });
        });
        
        function loadCategories() {
            fetch('products.cfm?action=categories&t=' + Date.now())
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        populateCategorySelect(data.categories);
                    } else {
                        console.error('Error loading categories:', data.message);
                    }
                })
                .catch(error => {
                    console.error('Error loading categories:', error);
                });
        }
        
        function populateCategorySelect(categories) {
            const categorySelect = document.getElementById('category');
            if (categorySelect) {
                // Clear existing options except the first one
                categorySelect.innerHTML = '<option value="">Select Category</option>';
                
                // Add categories from database
                categories.forEach(category => {
                    const option = document.createElement('option');
                    option.value = category.categoryId;
                    option.textContent = category.categoryName;
                    categorySelect.appendChild(option);
                });
                
                console.log('Loaded categories:', categories);
            }
        }
        
        function loadCategoriesTable() {
            console.log('Loading categories table...');
            const url = 'products.cfm?action=categories&t=' + Date.now();
            console.log('Fetching from URL:', url);
            
            fetch(url)
                .then(response => {
                    console.log('Response status:', response.status);
                    console.log('Response headers:', response.headers);
                    return response.json();
                })
                .then(data => {
                    console.log('Categories table data:', data);
                    if (data.success) {
                        console.log('Categories loaded successfully:', data.categories);
                        displayCategoriesTable(data.categories);
                    } else {
                        console.error('Failed to load categories:', data.message);
                        // Show error message in UI
                        const categoriesTableDiv = document.getElementById('categoriesTable');
                        if (categoriesTableDiv) {
                            categoriesTableDiv.innerHTML = '<p style="color: red;">Error loading categories: ' + data.message + '</p>';
                        }
                    }
                })
                .catch(error => {
                    console.error('Error loading categories table:', error);
                    // Show error message in UI
                    const categoriesTableDiv = document.getElementById('categoriesTable');
                    if (categoriesTableDiv) {
                        categoriesTableDiv.innerHTML = '<p style="color: red;">Error loading categories: ' + error.message + '</p>';
                    }
                });
        }
        
        function displayCategoriesTable(categories) {
            console.log('Displaying categories table with', categories.length, 'categories');
            
            const table = document.createElement('table');
            table.className = 'table';
            
            // Create header
            const thead = document.createElement('thead');
            const headerRow = document.createElement('tr');
            ['ID', 'Category Name', 'Description', 'Actions'].forEach(headerText => {
                const th = document.createElement('th');
                th.textContent = headerText;
                headerRow.appendChild(th);
            });
            thead.appendChild(headerRow);
            table.appendChild(thead);
            
            // Create body
            const tbody = document.createElement('tbody');
            categories.forEach(category => {
                const row = document.createElement('tr');
                
                // ID
                const idCell = document.createElement('td');
                idCell.textContent = category.categoryId;
                row.appendChild(idCell);
                
                // Category Name
                const nameCell = document.createElement('td');
                nameCell.textContent = category.categoryName;
                row.appendChild(nameCell);
                
                // Description
                const descCell = document.createElement('td');
                descCell.textContent = category.description || 'N/A';
                row.appendChild(descCell);
                
                // Actions
                const actionsCell = document.createElement('td');
                
                const editBtn = document.createElement('button');
                editBtn.className = 'btn btn-primary btn-small';
                editBtn.textContent = 'Edit';
                editBtn.style.marginRight = '5px';
                editBtn.onclick = () => editCategory(category.categoryId, category.categoryName, category.description || '');
                actionsCell.appendChild(editBtn);
                
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'btn btn-danger btn-small';
                deleteBtn.textContent = 'Delete';
                deleteBtn.onclick = () => deleteCategory(category.categoryId);
                actionsCell.appendChild(deleteBtn);
                
                row.appendChild(actionsCell);
                tbody.appendChild(row);
            });
            
            table.appendChild(tbody);
            
            const categoriesTableDiv = document.getElementById('categoriesTable');
            if (categoriesTableDiv) {
                categoriesTableDiv.innerHTML = '';
                categoriesTableDiv.appendChild(table);
                console.log('Categories table rendered successfully');
            } else {
                console.error('categoriesTable element not found!');
            }
        }
        
        function editCategory(categoryId, categoryName, description) {
            // Hide add form if open
            document.getElementById('addCategorySection').style.display = 'none';
            document.getElementById('toggleAddCategoryForm').textContent = '+ Add New Category';
            document.getElementById('toggleAddCategoryForm').className = 'btn btn-primary';
            
            // Populate the form with category data
            document.getElementById('categoryName').value = categoryName;
            document.getElementById('categoryDescription').value = description;
            
            // Store the category ID for update
            document.getElementById('addCategoryForm').setAttribute('data-category-id', categoryId);
            
            // Show the form
            showEditCategoryForm();
            
            // Scroll to the category edit form smoothly
            setTimeout(() => {
                const addCategorySection = document.getElementById('addCategorySection');
                if (addCategorySection) {
                    addCategorySection.scrollIntoView({ 
                        behavior: 'smooth', 
                        block: 'start' 
                    });
                }
            }, 100);
        }
        
        function showEditCategoryForm() {
            const addSection = document.getElementById('addCategorySection');
            const formTitle = addSection.querySelector('h3');
            const submitBtn = addSection.querySelector('button[type="submit"]');
            const cancelBtn = addSection.querySelector('button[type="button"]');
            
            formTitle.textContent = 'Edit Category';
            submitBtn.textContent = 'Update Category';
            cancelBtn.textContent = 'Cancel Edit';
            cancelBtn.setAttribute('onclick', 'cancelEditCategory()');
            
            addSection.style.display = 'block';
        }
        
        function cancelAddCategory() {
            document.getElementById('addCategorySection').style.display = 'none';
            document.getElementById('toggleAddCategoryForm').textContent = '+ Add New Category';
            document.getElementById('toggleAddCategoryForm').className = 'btn btn-primary';
            document.getElementById('addCategoryForm').reset();
        }
        
        function cancelEditCategory() {
            document.getElementById('addCategorySection').style.display = 'none';
            document.getElementById('toggleAddCategoryForm').textContent = '+ Add New Category';
            document.getElementById('toggleAddCategoryForm').className = 'btn btn-primary';
            document.getElementById('addCategoryForm').reset();
            document.getElementById('addCategoryForm').removeAttribute('data-category-id');
        }
        
        function deleteCategory(categoryId) {
            if (!confirm('Are you sure you want to delete this category?')) {
                return;
            }
            
            fetch(`products.cfm?action=deleteCategory&categoryId=${categoryId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        loadCategories();
                        loadCategoriesTable();
                    } else {
                        showMessage(data.message, 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred', 'error');
                });
        }
        
        function loadAllProducts() {
            fetch('products.cfm?action=list')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        allProducts = data.products;
                        filteredProducts = [...allProducts];
                        
                        // Always display all products initially
                        displayProductsTable(allProducts);
                        updateFilterResults();
                        
                        // Apply any existing filters
                        setTimeout(() => {
                            applyFilters();
                        }, 100);
                    }
                })
                .catch(error => {
                    console.error('Error loading products:', error);
                });
        }
        
        function displayProductsTable(products) {
            const tableHtml = `
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Product Name</th>
                            <th>Brand</th>
                            <th>Category</th>
                            <th>Grade</th>
                            <th>Price</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${products.map(p => `
                            <tr>
                                <td>${p.productId}</td>
                                <td>${p.productName}</td>
                                <td>${p.brand || 'N/A'}</td>
                                <td>${p.categoryName}</td>
                                <td><span class="nutrition-grade grade-${p.nutritionGrade}" 
                                    style="position: static; width: 30px; height: 30px; font-size: 14px;">
                                    ${p.nutritionGrade}
                                </span></td>
                                <td>₹${p.price ? p.price.toFixed(2) : 'N/A'}</td>
                                <td>
                                    <button class="btn btn-primary btn-small" 
                                            onclick="editProduct(${p.productId})" style="margin-right: 5px;">Edit</button>
                                    <button class="btn btn-danger btn-small" 
                                            onclick="deleteProduct(${p.productId})">Delete</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
            
            document.getElementById('productsTable').innerHTML = tableHtml;
        }
        
        function editProduct(productId) {
            // Hide add form if open
            document.getElementById('addProductSection').style.display = 'none';
            document.getElementById('toggleAddForm').textContent = '+ Add New Product';
            document.getElementById('toggleAddForm').className = 'btn btn-primary';
            
            // Fetch product data with cache busting
            fetch(`products.cfm?action=get&productId=${productId}&t=${Date.now()}`)
                .then(response => response.json())
                .then(data => {
                    console.log('Edit product response:', data);
                    if (data.success) {
                        // Show the form first
                        showEditForm();
                        
                        // Scroll to the edit form smoothly
                        setTimeout(() => {
                            const addProductSection = document.getElementById('addProductSection');
                            if (addProductSection) {
                                addProductSection.scrollIntoView({ 
                                    behavior: 'smooth', 
                                    block: 'start' 
                                });
                            }
                        }, 100);
                        
                        // Wait for the form to be fully rendered and then populate
                        setTimeout(() => {
                            console.log('About to populate form with product:', data.product);
                            populateEditForm(data.product);
                            
                            // Double-check the category after a short delay
                            setTimeout(() => {
                                const categorySelect = document.getElementById('category');
                                const expectedValue = String(data.product.categoryId || '');
                                if (categorySelect && categorySelect.value !== expectedValue) {
                                    console.log('Category not set correctly, forcing retry...');
                                    categorySelect.value = expectedValue;
                                    console.log('Final category value:', categorySelect.value);
                                }
                            }, 200);
                        }, 150);
                    } else {
                        showMessage(data.message, 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred', 'error');
                });
        }
        
        function populateEditForm(product) {
            console.log('Populating edit form with product:', product);
            
            // Store the product ID for update FIRST
            document.getElementById('addProductForm').setAttribute('data-product-id', product.productId);
            
            // Set basic fields with safe defaults
            document.getElementById('productName').value = product.productName || '';
            document.getElementById('brand').value = product.brand || '';
            document.getElementById('description').value = product.description || '';
            document.getElementById('price').value = product.price || '';
            document.getElementById('servingSize').value = product.servingSize || '';
            document.getElementById('calories').value = product.calories || '';
            document.getElementById('protein').value = product.protein || '';
            document.getElementById('carbs').value = product.carbs || '';
            document.getElementById('fat').value = product.fat || '';
            document.getElementById('fiber').value = product.fiber || '';
            document.getElementById('sugar').value = product.sugar || '';
            document.getElementById('sodium').value = product.sodium || '';
            document.getElementById('saturatedFat').value = product.saturatedFat || '';
            document.getElementById('transFat').value = product.transFat || '';
            document.getElementById('cholesterol').value = product.cholesterol || '';
            
            // Set category immediately and with multiple retries
            console.log('Setting category immediately...');
            setCategoryValue(product.categoryId);
            
            // Retry category setting with delays
            setTimeout(() => {
                console.log('Setting category after 100ms delay...');
                setCategoryValue(product.categoryId);
            }, 100);
            
            setTimeout(() => {
                console.log('Setting category after 300ms delay...');
                setCategoryValue(product.categoryId);
            }, 300);
            
            setTimeout(() => {
                console.log('Final category set attempt after 500ms...');
                setCategoryValue(product.categoryId);
            }, 500);
        }
        
        function setCategoryValue(categoryId) {
            const categoryIdStr = String(categoryId || '');
            console.log('Setting category value to:', categoryIdStr);
            
            const categorySelect = document.getElementById('category');
            if (!categorySelect) {
                console.error('Category select element not found!');
                return;
            }
            
            // Debug: Log available options
            const availableOptions = Array.from(categorySelect.options).map(opt => ({ value: opt.value, text: opt.text }));
            console.log('Available category options:', availableOptions);
            
            // Check if the target category exists in the options
            const targetOption = categorySelect.querySelector(`option[value="${categoryIdStr}"]`);
            if (!targetOption) {
                console.error(`Category option with value "${categoryIdStr}" not found in dropdown!`);
                console.log('Available values:', availableOptions.map(opt => opt.value));
                return;
            }
            
            // Try to set the category value
            categorySelect.value = categoryIdStr;
            
            // Verify it was set correctly
            const selectedValue = categorySelect.value;
            const selectedText = categorySelect.selectedOptions[0]?.text;
            
            console.log('Category value after setting:', selectedValue);
            console.log('Selected option text:', selectedText);
            
            // If it didn't work, try multiple approaches
            if (selectedValue !== categoryIdStr) {
                console.log('Category not set correctly, trying alternative methods...');
                
                // Method 1: Try setting selectedIndex
                for (let i = 0; i < categorySelect.options.length; i++) {
                    if (categorySelect.options[i].value === categoryIdStr) {
                        categorySelect.selectedIndex = i;
                        console.log('Set via selectedIndex:', categorySelect.value);
                        break;
                    }
                }
                
                // Method 2: Try again with a delay
                setTimeout(() => {
                    categorySelect.value = categoryIdStr;
                    console.log('Retry - Category value:', categorySelect.value);
                    
                    // Final verification
                    if (categorySelect.value !== categoryIdStr) {
                        console.error('Failed to set category after all attempts!');
                        console.log('Expected:', categoryIdStr, 'Got:', categorySelect.value);
                    } else {
                        console.log('✅ Category successfully set!');
                    }
                }, 100);
            } else {
                console.log('✅ Category set successfully on first attempt!');
            }
        }
        
        function testCategorySetting() {
            console.log('🧪 Testing category setting...');
            
            // Test setting category to different values
            const testValues = ['1', '2', '3', '4', '5'];
            let currentIndex = 0;
            
            function testNext() {
                if (currentIndex < testValues.length) {
                    const testValue = testValues[currentIndex];
                    console.log(`Testing category value: ${testValue}`);
                    setCategoryValue(testValue);
                    
                    setTimeout(() => {
                        const categorySelect = document.getElementById('category');
                        console.log(`Result for ${testValue}:`, categorySelect.value);
                        currentIndex++;
                        testNext();
                    }, 1000);
                } else {
                    console.log('🧪 Category testing complete!');
                }
            }
            
            testNext();
        }
        
        function testFormSubmission() {
            console.log('📝 Testing form submission...');
            
            const form = document.getElementById('addProductForm');
            const productId = form.getAttribute('data-product-id');
            const isEdit = productId !== null;
            
            console.log('Form data:');
            console.log('- Product ID:', productId);
            console.log('- Is Edit:', isEdit);
            console.log('- Product Name:', document.getElementById('productName').value);
            console.log('- Category:', document.getElementById('category').value);
            console.log('- Brand:', document.getElementById('brand').value);
            
            // Test form data collection
            const formData = new FormData(form);
            console.log('FormData contents:');
            for (let [key, value] of formData.entries()) {
                console.log(`  ${key}: ${value}`);
            }
            
            if (isEdit) {
                console.log('✅ Form is in EDIT mode - should UPDATE existing product');
            } else {
                console.log('⚠️ Form is in ADD mode - will CREATE new product');
            }
        }
        
        function showEditForm() {
            const addSection = document.getElementById('addProductSection');
            const formTitle = addSection.querySelector('h3');
            const formNote = addSection.querySelector('p');
            const submitBtn = addSection.querySelector('button[type="submit"]');
            const cancelBtn = addSection.querySelector('button[type="button"]');
            
            formTitle.textContent = 'Edit Product';
            formNote.innerHTML = '<span style="color: red;">*</span> Required fields. You can leave optional fields empty.';
            submitBtn.textContent = 'Update Product';
            cancelBtn.textContent = 'Cancel Edit';
            cancelBtn.setAttribute('onclick', 'cancelEdit()');
            
            addSection.style.display = 'block';
        }
        
        function cancelAdd() {
            document.getElementById('addProductSection').style.display = 'none';
            document.getElementById('toggleAddForm').textContent = '+ Add New Product';
            document.getElementById('toggleAddForm').className = 'btn btn-primary';
            document.getElementById('addProductForm').reset();
            resetFormTitle();
        }
        
        function cancelEdit() {
            document.getElementById('addProductSection').style.display = 'none';
            document.getElementById('toggleAddForm').textContent = '+ Add New Product';
            document.getElementById('toggleAddForm').className = 'btn btn-primary';
            document.getElementById('addProductForm').reset();
            document.getElementById('addProductForm').removeAttribute('data-product-id');
            resetFormTitle();
        }
        
        function resetFormTitle() {
            const addSection = document.getElementById('addProductSection');
            const formTitle = addSection.querySelector('h3');
            const formNote = addSection.querySelector('p');
            
            formTitle.textContent = 'Add New Product';
            formNote.innerHTML = '<span style="color: red;">*</span> Required fields. Other fields are optional and can be filled later.';
        }
        
        function deleteProduct(productId) {
            if (!confirm('Are you sure you want to delete this product?')) {
                return;
            }
            
            fetch(`products.cfm?action=delete&productId=${productId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        loadAllProducts();
                        // Refresh filters after product deletion
                        applyFilters();
                    } else {
                        showMessage(data.message, 'error');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showMessage('An error occurred', 'error');
                });
        }
        
        function showMessage(message, type) {
            const messageDiv = document.getElementById('message');
            messageDiv.innerHTML = `<div class="alert alert-${type}">${message}</div>`;
            setTimeout(() => {
                messageDiv.innerHTML = '';
            }, 3000);
        }
        
        function setupSearchAndFilters() {
            // Category filter event listener
            document.getElementById('categoryFilter').addEventListener('change', applyFilters);
            
            // Grade filter event listener
            document.getElementById('gradeFilter').addEventListener('change', applyFilters);
            
            // Clear filters button
            document.getElementById('clearFilters').addEventListener('click', clearAllFilters);
            
            // Populate category filter dropdown
            populateCategoryFilter();
        }
        
        function populateCategoryFilter() {
            fetch('products.cfm?action=categories&t=' + Date.now())
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const categoryFilter = document.getElementById('categoryFilter');
                        // Clear existing options except "All Categories"
                        categoryFilter.innerHTML = '<option value="">All Categories</option>';
                        
                        // Add categories from database
                        data.categories.forEach(category => {
                            const option = document.createElement('option');
                            option.value = category.categoryName;
                            option.textContent = category.categoryName;
                            categoryFilter.appendChild(option);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading categories for filter:', error);
                });
        }
        
        function applyFilters() {
            // Check if products are loaded
            if (!allProducts || allProducts.length === 0) {
                return;
            }
            
            const selectedCategory = document.getElementById('categoryFilter').value;
            const selectedGrade = document.getElementById('gradeFilter').value;
            
            // Start with all products
            let results = [...allProducts];
            
            // Apply category filter
            if (selectedCategory) {
                results = results.filter(product => 
                    product.categoryName === selectedCategory
                );
            }
            
            // Apply grade filter
            if (selectedGrade) {
                results = results.filter(product => 
                    product.nutritionGrade === selectedGrade
                );
            }
            
            filteredProducts = results;
            displayProductsTable(filteredProducts);
            updateFilterResults();
        }
        
        function clearAllFilters() {
            document.getElementById('categoryFilter').value = '';
            document.getElementById('gradeFilter').value = '';
            
            if (allProducts && allProducts.length > 0) {
                filteredProducts = [...allProducts];
                displayProductsTable(filteredProducts);
                updateFilterResults();
            }
        }
        
        function updateFilterResults() {
            const filterResults = document.getElementById('filterResults');
            const totalProducts = allProducts ? allProducts.length : 0;
            const filteredCount = filteredProducts ? filteredProducts.length : 0;
            
            if (filteredCount === totalProducts) {
                filterResults.textContent = `Showing all ${totalProducts} products`;
            } else {
                filterResults.textContent = `Showing ${filteredCount} of ${totalProducts} products`;
            }
        }
        
        function handleLogout(event) {
            event.preventDefault();
            fetch('../api/auth.cfm?action=logout')
                .then(() => {
                    window.location.href = '../auth/login.cfm';
                });
        }
    </script>
</body>
</html>
