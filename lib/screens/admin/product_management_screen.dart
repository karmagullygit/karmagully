import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../models/product_variant.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/image_upload_widget.dart';
import 'admin_product_section_assignment_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStockFilter = 'all'; // all, in_stock, low_stock, out_of_stock
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Stock filter
      final matchesStock = _selectedStockFilter == 'all' ||
          (_selectedStockFilter == 'in_stock' && product.stock > 10) ||
          (_selectedStockFilter == 'low_stock' && product.stock > 0 && product.stock <= 10) ||
          (_selectedStockFilter == 'out_of_stock' && product.stock == 0);

      // Category filter
      final matchesCategory = _selectedCategory == null ||
          product.category == _selectedCategory;

      return matchesSearch && matchesStock && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = productProvider.products;
          final products = _filterProducts(allProducts);

          if (allProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No products found', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Add your first product to get started!'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context),
                ),
                child: Row(
                  children: [
                    // Stock Filter
                    FilterChip(
                      label: const Text('All Stock'),
                      selected: _selectedStockFilter == 'all',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStockFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('In Stock'),
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      selected: _selectedStockFilter == 'in_stock',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStockFilter = 'in_stock';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Low Stock'),
                      avatar: const Icon(Icons.warning, size: 18, color: Colors.orange),
                      selected: _selectedStockFilter == 'low_stock',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStockFilter = 'low_stock';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Out of Stock'),
                      avatar: const Icon(Icons.cancel, size: 18, color: Colors.red),
                      selected: _selectedStockFilter == 'out_of_stock',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStockFilter = 'out_of_stock';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    // Category Filter
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, child) {
                        return PopupMenuButton<String?>(
                          child: Chip(
                            label: Text(
                              _selectedCategory == null
                                  ? 'All Categories'
                                  : _selectedCategory!,
                            ),
                            avatar: const Icon(Icons.category, size: 18),
                            deleteIcon: _selectedCategory != null
                                ? const Icon(Icons.close, size: 18)
                                : null,
                            onDeleted: _selectedCategory != null
                                ? () {
                                    setState(() {
                                      _selectedCategory = null;
                                    });
                                  }
                                : null,
                          ),
                          onSelected: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String?>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categoryProvider.categories.map(
                              (category) => PopupMenuItem<String>(
                                value: category.name,
                                child: Text(category.name),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Results count
              if (_searchQuery.isNotEmpty || _selectedStockFilter != 'all' || _selectedCategory != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getHorizontalPadding(context),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${products.length} product${products.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // Product List
              if (products.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No products match your filters',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedStockFilter = 'all';
                              _selectedCategory = null;
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getHorizontalPadding(context),
                      vertical: ResponsiveUtils.getVerticalPadding(context),
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getVerticalSpacing(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        child: Row(
          children: [
            // Product Image - Compact size
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: isMobile ? 60 : 70,
                height: isMobile ? 60 : 70,
                child: _buildProductImage(product),
              ),
            ),
            
            SizedBox(width: isMobile ? 10 : 12),
            
            // Product Info - Takes remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: isMobile ? 14 : 15,
                        color: product.stock > 10
                            ? Colors.green
                            : product.stock > 0
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.stock}',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: product.stock > 10
                              ? Colors.green
                              : product.stock > 0
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Menu - Popup menu for space efficiency
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey[700],
                size: isMobile ? 22 : 24,
              ),
              padding: EdgeInsets.zero,
              offset: const Offset(-10, 40),
              onSelected: (value) {
                if (value == 'category') {
                  _showSectionAssignment(context, product);
                } else if (value == 'edit') {
                  _showProductDialog(context, product);
                } else if (value == 'delete') {
                  _deleteProduct(context, product);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'category',
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.purple, size: 20),
                      const SizedBox(width: 12),
                      const Text('Assign Sections'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      const Text('Edit Product'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      const Text('Delete Product'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, [Product? product]) {
    showDialog(
      context: context,
      builder: (context) => ProductDialog(product: product),
    );
  }

  void _showSectionAssignment(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductSectionAssignmentScreen(product: product),
      ),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safePopDialog(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(product.id);
              NavigationHelper.safePopDialog(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    // Get the first image URL/path
    String? imagePath;
    if (product.imageUrls.isNotEmpty) {
      imagePath = product.imageUrls.first;
    } else if (product.imageUrl.isNotEmpty) {
      imagePath = product.imageUrl;
    }

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }

    // Check if it's a local file path
    if (imagePath.startsWith('/') || imagePath.contains('\\') || imagePath.startsWith('file://')) {
      final file = File(imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported),
          ),
        );
      }
    }

    // It's a URL, use cached network image
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}

class ProductDialog extends StatefulWidget {
  final Product? product;

  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String _selectedCategory = '';
  List<String> _selectedImagePaths = [];
  List<ProductVariant> _variants = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    
    // Load categories and set default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      if (widget.product != null) {
        _selectedCategory = widget.product!.category;
      }
    });
    
    // Load existing images if editing a product
    if (widget.product != null) {
      if (widget.product!.imageUrls.isNotEmpty) {
        _selectedImagePaths = List<String>.from(widget.product!.imageUrls);
      } else if (widget.product!.imageUrl.isNotEmpty) {
        _selectedImagePaths = [widget.product!.imageUrl];
      }
      
      // Load existing variants
      if (widget.product!.variants.isNotEmpty) {
        _variants = List<ProductVariant>.from(widget.product!.variants);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid stock';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Category dropdown with CategoryProvider
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    final categories = categoryProvider.categories;
                    
                    if (categories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('No categories available. Please add categories first.'),
                      );
                    }
                    
                    // Set default category if not set
                    if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                      _selectedCategory = categories.first.name;
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Product Variants Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category_outlined),
                            const SizedBox(width: 8),
                            const Text(
                              'Product Variants',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.blue),
                              onPressed: _addVariant,
                              tooltip: 'Add Variant',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_variants.isEmpty)
                          const Text(
                            'No variants added. Tap + to add variants like size, color, etc.',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _variants.length,
                            itemBuilder: (context, index) {
                              final variant = _variants[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(variant.name),
                                  subtitle: Text('Price: \$${variant.price.toStringAsFixed(2)} | Stock: ${variant.stock}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeVariant(index),
                                  ),
                                  onTap: () => _editVariant(index),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Replace URL input with image upload widget
                const Text(
                  'Product Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ImageUploadWidget(
                  imagePaths: _selectedImagePaths,
                  onImagesChanged: (List<String> imagePaths) {
                    setState(() {
                      _selectedImagePaths = imagePaths;
                    });
                  },
                  maxImages: 5,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => NavigationHelper.safePopDialog(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.product == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one image is selected
    if (_selectedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate category selection
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      imageUrls: _selectedImagePaths,
      category: _selectedCategory,
      stock: int.parse(_stockController.text),
      variants: _variants,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (widget.product == null) {
      productProvider.addProduct(product);
    } else {
      productProvider.updateProduct(product);
    }

    NavigationHelper.safePopDialog(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.product == null 
            ? 'Product added successfully'
            : 'Product updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addVariant() {
    _showVariantDialog();
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  void _editVariant(int index) {
    _showVariantDialog(_variants[index], index);
  }

  void _showVariantDialog([ProductVariant? variant, int? index]) {
    final nameController = TextEditingController(text: variant?.name ?? '');
    final priceController = TextEditingController(text: variant?.price.toString() ?? '');
    final stockController = TextEditingController(text: variant?.stock.toString() ?? '');
    final skuController = TextEditingController(text: variant?.sku ?? '');
    
    Map<String, String> attributes = Map<String, String>.from(variant?.attributes ?? {});
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(variant == null ? 'Add Variant' : 'Edit Variant'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Variant Name (e.g., Red-Large)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Attributes section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Attributes (e.g., Color, Size)'),
                          const SizedBox(height: 8),
                          ...attributes.entries.map((entry) => 
                            Row(
                              children: [
                                Expanded(child: Text('${entry.key}: ${entry.value}')),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () {
                                    setDialogState(() {
                                      attributes.remove(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ).toList(),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Attribute'),
                            onPressed: () => _showAddAttributeDialog(context, attributes, setDialogState),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    priceController.text.isNotEmpty && 
                    stockController.text.isNotEmpty) {
                  
                  final newVariant = ProductVariant(
                    id: variant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    productId: widget.product?.id ?? '',
                    name: nameController.text,
                    attributes: attributes,
                    price: double.parse(priceController.text),
                    stock: int.parse(stockController.text),
                    sku: skuController.text.isEmpty ? null : skuController.text,
                    createdAt: variant?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  setState(() {
                    if (index != null) {
                      _variants[index] = newVariant;
                    } else {
                      _variants.add(newVariant);
                    }
                  });
                  
                  Navigator.of(context).pop();
                }
              },
              child: Text(variant == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddAttributeDialog(BuildContext context, Map<String, String> attributes, StateSetter setDialogState) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Attribute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Attribute Name (e.g., Color)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Attribute Value (e.g., Red)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                setDialogState(() {
                  attributes[keyController.text] = valueController.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}