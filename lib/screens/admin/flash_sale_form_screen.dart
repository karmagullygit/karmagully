import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/flash_sale.dart';

class FlashSaleFormScreen extends StatefulWidget {
  final FlashSale? flashSale;
  
  const FlashSaleFormScreen({super.key, this.flashSale});

  @override
  State<FlashSaleFormScreen> createState() => _FlashSaleFormScreenState();
}

class _FlashSaleFormScreenState extends State<FlashSaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _discountController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _maxItemsController = TextEditingController();
  
  DateTime? _startTime;
  DateTime? _endTime;
  String _selectedType = 'percentage';
  String _selectedColor = '#FF6B6B';
  List<String> _selectedProductIds = [];
  List<String> _selectedCategoryIds = [];
  bool _isLoading = false;

  final List<String> _colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Add listener to image URL controller for live preview
    _imageUrlController.addListener(() {
      setState(() {}); // Update the UI when image URL changes
    });
    
    if (widget.flashSale != null) {
      _populateFields();
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  void _populateFields() {
    final flashSale = widget.flashSale!;
    _titleController.text = flashSale.title;
    _descriptionController.text = flashSale.description;
    _imageUrlController.text = flashSale.imageUrl;
    _discountController.text = flashSale.discountPercentage.toString();
    _maxDiscountController.text = flashSale.maxDiscountAmount?.toString() ?? '';
    _maxItemsController.text = flashSale.maxItems?.toString() ?? '';
    _startTime = flashSale.startTime;
    _endTime = flashSale.endTime;
    _selectedType = flashSale.type;
    _selectedColor = flashSale.bannerColor ?? '#FF6B6B';
    _selectedProductIds = List.from(flashSale.productIds);
    _selectedCategoryIds = List.from(flashSale.categoryIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    _maxDiscountController.dispose();
    _maxItemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: Text(widget.flashSale == null ? 'Create Flash Sale' : 'Edit Flash Sale'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveFlashSale,
                child: Text(
                  widget.flashSale == null ? 'CREATE' : 'UPDATE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBasicInfoCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildBannerDesignCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildDiscountCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildTimeCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildProductsCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildCategoriesCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildSettingsCard(isDarkMode),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBasicInfoCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Weekend Mega Sale',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your flash sale...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Banner Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey, width: 1),
                    ),
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerDesignCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Banner Design',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Banner Image URL
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Banner Image URL *',
                hintText: 'https://example.com/flash-sale-banner.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                helperText: 'Recommended size: 800x400px',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a banner image URL';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Banner Preview
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                      Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  Text('Invalid Image URL', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                      
                      // Color Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(int.parse(_selectedColor.replaceFirst('#', '0xff'))).withOpacity(0.3),
                              Color(int.parse(_selectedColor.replaceFirst('#', '0xff'))).withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Sample Text Overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'LIVE NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _titleController.text.isEmpty ? 'Flash Sale Title' : _titleController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black54),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'UP TO ${_discountController.text.isEmpty ? '50' : _discountController.text}% OFF',
                                style: TextStyle(
                                  color: Color(int.parse(_selectedColor.replaceFirst('#', '0xff'))),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Preview Label
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PREVIEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Banner Color Selection
            const Text(
              'Banner Accent Color',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This banner will be displayed at the top of your flash sale detail page and in promotional cards.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Discount Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_offer),
              ),
              items: const [
                DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                DropdownMenuItem(value: 'fixed_amount', child: Text('Fixed Amount')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: _selectedType == 'percentage' ? 'Discount Percentage *' : 'Discount Amount *',
                hintText: _selectedType == 'percentage' ? 'e.g., 50' : 'e.g., 100',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_selectedType == 'percentage' ? Icons.percent : Icons.currency_rupee),
                suffixText: _selectedType == 'percentage' ? '%' : '₹',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter discount value';
                }
                final num? discount = num.tryParse(value);
                if (discount == null || discount <= 0) {
                  return 'Please enter a valid discount value';
                }
                if (_selectedType == 'percentage' && discount > 100) {
                  return 'Percentage cannot exceed 100%';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxDiscountController,
              decoration: const InputDecoration(
                labelText: 'Maximum Discount Amount (Optional)',
                hintText: 'e.g., 500',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
                suffixText: '₹',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num? maxDiscount = num.tryParse(value);
                  if (maxDiscount == null || maxDiscount <= 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxItemsController,
              decoration: const InputDecoration(
                labelText: 'Maximum Items (Optional)',
                hintText: 'e.g., 100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
                suffixText: 'items',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num? maxItems = num.tryParse(value);
                  if (maxItems == null || maxItems <= 0) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sale Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_startTime?.toString() ?? 'Select start time'),
              leading: const Icon(Icons.play_arrow),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(true),
            ),
            const Divider(),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_endTime?.toString() ?? 'Select end time'),
              leading: const Icon(Icons.stop),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Applicable Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedProductIds.length} selected',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Leave empty to apply to all products',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      final isSelected = _selectedProductIds.contains(product.id);
                      
                      return CheckboxListTile(
                        title: Text(product.name),
                        subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedProductIds.add(product.id);
                            } else {
                              _selectedProductIds.remove(product.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Applicable Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedCategoryIds.length} selected',
                  style: TextStyle(
                    color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Leave empty to apply to all categories',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                
                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      final isSelected = _selectedCategoryIds.contains(category.id);
                      
                      return CheckboxListTile(
                        title: Text(category.name),
                        subtitle: Text(category.description ?? ''),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedCategoryIds.add(category.id);
                            } else {
                              _selectedCategoryIds.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDarkMode) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('Auto-activate'),
              subtitle: Text('Automatically activate when start time is reached'),
              leading: Icon(Icons.auto_awesome),
              trailing: Switch(value: true, onChanged: null),
            ),
            const ListTile(
              title: Text('Auto-deactivate'),
              subtitle: Text('Automatically deactivate when end time is reached'),
              leading: Icon(Icons.auto_delete),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        
        setState(() {
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _saveFlashSale() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final flashSale = FlashSale(
        id: widget.flashSale?.id ?? 'flash_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        discountPercentage: int.parse(_discountController.text),
        maxDiscountAmount: _maxDiscountController.text.isNotEmpty 
            ? double.parse(_maxDiscountController.text) 
            : null,
        productIds: _selectedProductIds,
        categoryIds: _selectedCategoryIds,
        createdAt: widget.flashSale?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        maxItems: _maxItemsController.text.isNotEmpty 
            ? int.parse(_maxItemsController.text) 
            : null,
        soldItems: widget.flashSale?.soldItems ?? 0,
        bannerColor: _selectedColor,
        type: _selectedType,
      );

      final provider = Provider.of<FlashSaleProvider>(context, listen: false);
      bool success;
      
      if (widget.flashSale == null) {
        success = await provider.createFlashSale(flashSale);
      } else {
        success = await provider.updateFlashSale(flashSale);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.flashSale == null 
                    ? 'Flash sale created successfully!'
                    : 'Flash sale updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save flash sale'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}