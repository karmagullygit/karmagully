import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_address.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';

class AddEditAddressScreen extends StatefulWidget {
  final UserAddress? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  bool _isDefault = false;
  bool _isSaving = false;

  // Indian states list for validation
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _fullNameController = TextEditingController(text: widget.address?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _addressLine1Controller = TextEditingController(text: widget.address?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: widget.address?.addressLine2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
    _countryController = TextEditingController(text: widget.address?.country ?? 'India');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Validate phone number based on country
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    
    final phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      // Indian phone validation: 10 digits, starting with 6-9
      final indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
      if (!indianPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit Indian phone (starts with 6-9)';
      }
    } else if (country.contains('usa') || country.contains('united states') || country == 'us') {
      // USA phone: 10 digits
      final usPhoneRegex = RegExp(r'^\d{10}$');
      if (!usPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit US phone number';
      }
    } else if (country.contains('uk') || country.contains('united kingdom') || country.contains('britain')) {
      // UK phone: 10-11 digits
      if (phone.length < 10 || phone.length > 11 || !RegExp(r'^\d+$').hasMatch(phone)) {
        return 'Enter valid UK phone (10-11 digits)';
      }
    } else {
      // General validation: 7-15 digits with optional + prefix
      final generalPhoneRegex = RegExp(r'^\+?\d{7,15}$');
      if (!generalPhoneRegex.hasMatch(phone)) {
        return 'Enter valid phone number (7-15 digits)';
      }
    }
    
    return null;
  }

  // Validate postal code based on country
  String? _validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter postal code';
    }
    
    final postalCode = value.trim();
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      // Indian PIN code: exactly 6 digits
      final indianPinRegex = RegExp(r'^\d{6}$');
      if (!indianPinRegex.hasMatch(postalCode)) {
        return 'Enter valid 6-digit PIN code';
      }
    } else if (country.contains('usa') || country.contains('united states') || country == 'us') {
      // USA ZIP: 5 digits or 5+4 digits
      final usZipRegex = RegExp(r'^\d{5}(-\d{4})?$');
      if (!usZipRegex.hasMatch(postalCode)) {
        return 'Enter valid US ZIP (12345 or 12345-6789)';
      }
    } else if (country.contains('uk') || country.contains('united kingdom') || country.contains('britain')) {
      // UK postcode format
      final ukPostcodeRegex = RegExp(r'^[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}$', caseSensitive: false);
      if (!ukPostcodeRegex.hasMatch(postalCode)) {
        return 'Enter valid UK postcode';
      }
    } else if (country.contains('canada') || country == 'ca') {
      // Canadian postal code: A1A 1A1
      final canadaPostalRegex = RegExp(r'^[A-Z]\d[A-Z]\s?\d[A-Z]\d$', caseSensitive: false);
      if (!canadaPostalRegex.hasMatch(postalCode)) {
        return 'Enter valid Canadian postal code (A1A 1A1)';
      }
    } else {
      // General validation: 3-10 alphanumeric characters
      if (postalCode.length < 3 || postalCode.length > 10) {
        return 'Enter valid postal code (3-10 characters)';
      }
    }
    
    return null;
  }

  // Validate state based on country
  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter state/province';
    }
    
    final state = value.trim();
    final country = _countryController.text.trim().toLowerCase();
    
    if (country == 'india' || country == 'ind' || country == 'in') {
      // Check if it's a valid Indian state (case-insensitive)
      final isValidIndianState = _indianStates.any(
        (s) => s.toLowerCase() == state.toLowerCase()
      );
      
      if (!isValidIndianState) {
        return 'Enter valid Indian state/UT';
      }
    } else if (state.length < 2) {
      return 'State name too short';
    }
    
    return null;
  }

  // Show Indian states picker dialog
  void _showIndianStatesPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select State/UT'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _indianStates.length,
            itemBuilder: (context, index) {
              final state = _indianStates[index];
              return ListTile(
                title: Text(state),
                onTap: () {
                  setState(() {
                    _stateController.text = state;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';

    try {
      if (widget.address == null) {
        // Add new address
        await addressProvider.addAddress(
          userId: userId,
          label: _labelController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        // Update existing address
        await addressProvider.updateAddress(
          id: widget.address!.id,
          label: _labelController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.address == null 
              ? 'Address added successfully' 
              : 'Address updated successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card for Indian addresses
            if (_countryController.text.toLowerCase().contains('india') ||
                _countryController.text.toLowerCase() == 'ind' ||
                _countryController.text.toLowerCase() == 'in')
              Card(
                color: Colors.blue[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Phone: 10 digits (6-9 first) • PIN: 6 digits • Valid state required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_countryController.text.toLowerCase().contains('india') ||
                _countryController.text.toLowerCase() == 'ind' ||
                _countryController.text.toLowerCase() == 'in')
              const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Label *',
                hintText: 'e.g., Home, Work, Other',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a label';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: _validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: InputDecoration(
                labelText: 'Address Line 1 *',
                hintText: 'House No., Building Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: InputDecoration(
                labelText: 'Address Line 2 (Optional)',
                hintText: 'Road name, Area, Colony',
                helperText: 'Optional field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _stateController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'State/Province *',
                          hintText: _countryController.text.toLowerCase().contains('india') 
                              ? 'e.g., Maharashtra' 
                              : 'State',
                          suffixIcon: (_countryController.text.toLowerCase().contains('india') ||
                                  _countryController.text.toLowerCase() == 'ind' ||
                                  _countryController.text.toLowerCase() == 'in')
                              ? IconButton(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onPressed: _showIndianStatesPicker,
                                  tooltip: 'Select from list',
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: _validateState,
                        onChanged: (value) {
                          // Re-validate when country changes
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Postal/PIN Code *',
                      hintText: _countryController.text.toLowerCase().contains('india') 
                          ? '6-digit PIN' 
                          : 'Postal code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: _validatePostalCode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Country *',
                      hintText: 'e.g., India',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (value.trim().length < 2) {
                        return 'Invalid country';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Trigger re-validation of phone, postal code, and state
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: SwitchListTile(
                title: const Text('Set as default address'),
                subtitle: const Text('This will be your primary delivery address'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: Colors.pink[300],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.address == null ? 'Add Address' : 'Update Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
