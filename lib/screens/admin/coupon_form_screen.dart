import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';

class CouponFormScreen extends StatefulWidget {
  final Coupon? coupon; // For editing
  final Coupon? couponToDuplicate; // For duplicating

  const CouponFormScreen({
    Key? key,
    this.coupon,
    this.couponToDuplicate,
  }) : super(key: key);

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _maximumDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();

  String _selectedType = 'percentage';
  DateTime? _expiryDate;
  bool _isActive = true;
  bool _isFirstTimeOnly = false;
  bool _hasUsageLimit = false;
  bool _hasMinimumOrder = false;
  bool _hasMaximumDiscount = false;
  
  List<String> _selectedProductIds = [];
  List<String> _selectedCategoryIds = [];
  List<String> _excludedProductIds = [];
  List<String> _excludedCategoryIds = [];
  
  Color _bannerColor = Colors.purple;
  
  final List<String> _couponTypes = [
    'percentage',
    'fixed_amount',
    'free_shipping',
  ];

  final List<Color> _colorOptions = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final couponToEdit = widget.coupon ?? widget.couponToDuplicate;
    
    if (couponToEdit != null) {
      _codeController.text = widget.couponToDuplicate != null 
          ? '${couponToEdit.code}_COPY' 
          : couponToEdit.code;
      _titleController.text = couponToEdit.title;
      _descriptionController.text = couponToEdit.description;
      _selectedType = couponToEdit.type;
      _valueController.text = couponToEdit.value.toString();
      
      if (couponToEdit.minimumOrderAmount != null) {
        _hasMinimumOrder = true;
        _minimumOrderController.text = couponToEdit.minimumOrderAmount!.toString();
      }
      
      if (couponToEdit.maximumDiscountAmount != null) {
        _hasMaximumDiscount = true;
        _maximumDiscountController.text = couponToEdit.maximumDiscountAmount!.toString();
      }
      
      _expiryDate = couponToEdit.expiryDate;
      
      if (couponToEdit.usageLimit != null) {
        _hasUsageLimit = true;
        _usageLimitController.text = couponToEdit.usageLimit!.toString();
      }
      
      _isActive = couponToEdit.isActive;
      _isFirstTimeOnly = couponToEdit.isFirstTimeOnly;
      _selectedProductIds = List.from(couponToEdit.applicableProductIds);
      _selectedCategoryIds = List.from(couponToEdit.applicableCategoryIds);
      _excludedProductIds = List.from(couponToEdit.excludedProductIds);
      _excludedCategoryIds = List.from(couponToEdit.excludedCategoryIds);
      
      if (couponToEdit.bannerColor != null) {
        _bannerColor = Color(int.parse(couponToEdit.bannerColor!.replaceFirst('#', '0xFF')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coupon != null ? 'Edit Coupon' : 'Create Coupon'),
        backgroundColor: _bannerColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _saveCoupon,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              _buildPreviewCard(),
              const SizedBox(height: 24),
              
              // Basic Information Section
              _buildSectionHeader('Basic Information', Icons.info),
              const SizedBox(height: 16),
              _buildBasicInfoFields(),
              const SizedBox(height: 24),
              
              // Discount Configuration Section
              _buildSectionHeader('Discount Configuration', Icons.percent),
              const SizedBox(height: 16),
              _buildDiscountFields(),
              const SizedBox(height: 24),
              
              // Usage Restrictions Section
              _buildSectionHeader('Usage Restrictions', Icons.security),
              const SizedBox(height: 16),
              _buildUsageRestrictions(),
              const SizedBox(height: 24),
              
              // Product/Category Targeting Section
              _buildSectionHeader('Product & Category Targeting', Icons.category),
              const SizedBox(height: 16),
              _buildTargetingOptions(),
              const SizedBox(height: 24),
              
              // Design Customization Section
              _buildSectionHeader('Design Customization', Icons.palette),
              const SizedBox(height: 16),
              _buildDesignOptions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_bannerColor, _bannerColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _codeController.text.isEmpty ? 'PREVIEW' : _codeController.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _bannerColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isActive ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isActive ? 'Active' : 'Draft',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _titleController.text.isEmpty ? 'Coupon Title' : _titleController.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _descriptionController.text.isEmpty 
                ? 'Coupon description will appear here' 
                : _descriptionController.text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getCouponIcon(_selectedType),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getDiscountPreviewText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _bannerColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _bannerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Coupon Code',
            hintText: 'e.g., SAVE20, WELCOME10',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a coupon code';
            }
            if (value.length < 3) {
              return 'Code must be at least 3 characters';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'e.g., Summer Sale, Welcome Offer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your coupon offer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDiscountFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Discount Type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.percent),
          ),
          items: _couponTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_getCouponIcon(type), size: 20),
                  const SizedBox(width: 8),
                  Text(_getTypeDisplayName(type)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        if (_selectedType != 'free_shipping')
          TextFormField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: _selectedType == 'percentage' ? 'Percentage' : 'Amount',
              hintText: _selectedType == 'percentage' ? 'e.g., 20' : 'e.g., 10.00',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_selectedType == 'percentage' ? Icons.percent : Icons.attach_money),
              suffixText: _selectedType == 'percentage' ? '%' : '\$',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_selectedType == 'free_shipping') return null;
              
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              final numValue = double.tryParse(value);
              if (numValue == null || numValue <= 0) {
                return 'Please enter a valid positive number';
              }
              if (_selectedType == 'percentage' && numValue > 100) {
                return 'Percentage cannot exceed 100%';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        if (_selectedType != 'free_shipping') const SizedBox(height: 16),
        
        // Maximum discount amount (for percentage coupons)
        if (_selectedType == 'percentage') ...[
          SwitchListTile(
            title: const Text('Set Maximum Discount Amount'),
            subtitle: const Text('Limit the maximum discount this coupon can provide'),
            value: _hasMaximumDiscount,
            onChanged: (value) {
              setState(() {
                _hasMaximumDiscount = value;
                if (!value) _maximumDiscountController.clear();
              });
            },
          ),
          if (_hasMaximumDiscount) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _maximumDiscountController,
              decoration: const InputDecoration(
                labelText: 'Maximum Discount Amount',
                hintText: 'e.g., 50.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
                suffixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (!_hasMaximumDiscount) return null;
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum discount amount';
                }
                final numValue = double.tryParse(value);
                if (numValue == null || numValue <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildUsageRestrictions() {
    return Column(
      children: [
        // Minimum order amount
        SwitchListTile(
          title: const Text('Minimum Order Amount'),
          subtitle: const Text('Require a minimum order value to use this coupon'),
          value: _hasMinimumOrder,
          onChanged: (value) {
            setState(() {
              _hasMinimumOrder = value;
              if (!value) _minimumOrderController.clear();
            });
          },
        ),
        if (_hasMinimumOrder) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _minimumOrderController,
            decoration: const InputDecoration(
              labelText: 'Minimum Order Amount',
              hintText: 'e.g., 100.00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_cart),
              suffixText: '\$',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_hasMinimumOrder) return null;
              if (value == null || value.isEmpty) {
                return 'Please enter minimum order amount';
              }
              final numValue = double.tryParse(value);
              if (numValue == null || numValue <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        // Usage limit
        SwitchListTile(
          title: const Text('Usage Limit'),
          subtitle: const Text('Limit how many times this coupon can be used'),
          value: _hasUsageLimit,
          onChanged: (value) {
            setState(() {
              _hasUsageLimit = value;
              if (!value) _usageLimitController.clear();
            });
          },
        ),
        if (_hasUsageLimit) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _usageLimitController,
            decoration: const InputDecoration(
              labelText: 'Usage Limit',
              hintText: 'e.g., 100',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_hasUsageLimit) return null;
              if (value == null || value.isEmpty) {
                return 'Please enter usage limit';
              }
              final numValue = int.tryParse(value);
              if (numValue == null || numValue <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        // Expiry date
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Expiry Date'),
          subtitle: Text(_expiryDate == null 
              ? 'No expiry date set' 
              : 'Expires on ${_formatDate(_expiryDate!)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_expiryDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _expiryDate = null),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _selectExpiryDate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // First time users only
        SwitchListTile(
          title: const Text('First-time Customers Only'),
          subtitle: const Text('Restrict this coupon to new customers only'),
          value: _isFirstTimeOnly,
          onChanged: (value) {
            setState(() {
              _isFirstTimeOnly = value;
            });
          },
        ),

        // Active status
        SwitchListTile(
          title: const Text('Active'),
          subtitle: const Text('Enable or disable this coupon'),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTargetingOptions() {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProvider, categoryProvider, child) {
        return Column(
          children: [
            // Applicable Products
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Applicable Products'),
              subtitle: Text(_selectedProductIds.isEmpty 
                  ? 'All products (tap to select specific products)' 
                  : '${_selectedProductIds.length} products selected'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showProductSelector(productProvider.products, false),
            ),
            const Divider(),

            // Applicable Categories
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Applicable Categories'),
              subtitle: Text(_selectedCategoryIds.isEmpty 
                  ? 'All categories (tap to select specific categories)' 
                  : '${_selectedCategoryIds.length} categories selected'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCategorySelector(categoryProvider.categories, false),
            ),
            const Divider(),

            // Excluded Products
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Excluded Products'),
              subtitle: Text(_excludedProductIds.isEmpty 
                  ? 'No products excluded' 
                  : '${_excludedProductIds.length} products excluded'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showProductSelector(productProvider.products, true),
            ),
            const Divider(),

            // Excluded Categories
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Excluded Categories'),
              subtitle: Text(_excludedCategoryIds.isEmpty 
                  ? 'No categories excluded' 
                  : '${_excludedCategoryIds.length} categories excluded'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCategorySelector(categoryProvider.categories, true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesignOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colorOptions.map((color) {
            final isSelected = _bannerColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _bannerColor = color;
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  void _showProductSelector(List<Product> products, bool isExcluded) {
    final selectedIds = isExcluded ? _excludedProductIds : _selectedProductIds;
    final tempSelected = List<String>.from(selectedIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isExcluded ? 'Exclude Products' : 'Select Products'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempSelected.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempSelected.clear();
                          tempSelected.addAll(products.map((p) => p.id));
                        });
                      },
                      child: const Text('Select All'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isSelected = tempSelected.contains(product.id);
                      
                      return CheckboxListTile(
                        title: Text(product.name),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(product.id);
                            } else {
                              tempSelected.remove(product.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isExcluded) {
                    _excludedProductIds = tempSelected;
                  } else {
                    _selectedProductIds = tempSelected;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector(List<Category> categories, bool isExcluded) {
    final selectedIds = isExcluded ? _excludedCategoryIds : _selectedCategoryIds;
    final tempSelected = List<String>.from(selectedIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isExcluded ? 'Exclude Categories' : 'Select Categories'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempSelected.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempSelected.clear();
                          tempSelected.addAll(categories.map((c) => c.id));
                        });
                      },
                      child: const Text('Select All'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = tempSelected.contains(category.id);
                      
                      return CheckboxListTile(
                        title: Text(category.name),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(category.id);
                            } else {
                              tempSelected.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isExcluded) {
                    _excludedCategoryIds = tempSelected;
                  } else {
                    _selectedCategoryIds = tempSelected;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCouponIcon(String type) {
    switch (type) {
      case 'percentage':
        return Icons.percent;
      case 'fixed_amount':
        return Icons.attach_money;
      case 'free_shipping':
        return Icons.local_shipping;
      default:
        return Icons.confirmation_number;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'percentage':
        return 'Percentage Discount';
      case 'fixed_amount':
        return 'Fixed Amount Discount';
      case 'free_shipping':
        return 'Free Shipping';
      default:
        return type;
    }
  }

  String _getDiscountPreviewText() {
    if (_valueController.text.isEmpty && _selectedType != 'free_shipping') {
      return 'DISCOUNT';
    }
    
    switch (_selectedType) {
      case 'percentage':
        final value = double.tryParse(_valueController.text) ?? 0;
        return '${value.toStringAsFixed(0)}% OFF';
      case 'fixed_amount':
        final value = double.tryParse(_valueController.text) ?? 0;
        return '\$${value.toStringAsFixed(2)} OFF';
      case 'free_shipping':
        return 'FREE SHIPPING';
      default:
        return 'DISCOUNT';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveCoupon() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final now = DateTime.now();
    
    final coupon = Coupon(
      id: widget.coupon?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeController.text.toUpperCase(),
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      value: _selectedType == 'free_shipping' ? 0 : double.parse(_valueController.text),
      minimumOrderAmount: _hasMinimumOrder ? double.tryParse(_minimumOrderController.text) : null,
      maximumDiscountAmount: _hasMaximumDiscount ? double.tryParse(_maximumDiscountController.text) : null,
      expiryDate: _expiryDate,
      usageLimit: _hasUsageLimit ? int.tryParse(_usageLimitController.text) : null,
      usedCount: widget.coupon?.usedCount ?? 0,
      isActive: _isActive,
      applicableProductIds: _selectedProductIds,
      applicableCategoryIds: _selectedCategoryIds,
      excludedProductIds: _excludedProductIds,
      excludedCategoryIds: _excludedCategoryIds,
      isFirstTimeOnly: _isFirstTimeOnly,
      allowedUserIds: const [],
      createdAt: widget.coupon?.createdAt ?? now,
      updatedAt: now,
      bannerColor: '#${_bannerColor.value.toRadixString(16).substring(2)}',
    );

    try {
      if (widget.coupon != null) {
        couponProvider.updateCoupon(coupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        couponProvider.addCoupon(coupon);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving coupon: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minimumOrderController.dispose();
    _maximumDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }
}