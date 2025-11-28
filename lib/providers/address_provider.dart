import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_address.dart';

class AddressProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final List<UserAddress> _addresses = [];
  UserAddress? _selectedAddress;
  final List<UserAddress> _presetAddresses = [
    UserAddress(
      id: 'preset_1',
      userId: 'preset',
      label: 'Quick Office',
      fullName: 'Office Building',
      phone: '+1 (555) 123-4567',
      addressLine1: '123 Business Park Drive',
      addressLine2: 'Suite 100',
      city: 'New York',
      state: 'NY',
      postalCode: '10001',
      country: 'USA',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserAddress(
      id: 'preset_2',
      userId: 'preset',
      label: 'Quick Home',
      fullName: 'Residential Address',
      phone: '+1 (555) 987-6543',
      addressLine1: '456 Elm Street',
      addressLine2: 'Apartment 5B',
      city: 'Los Angeles',
      state: 'CA',
      postalCode: '90210',
      country: 'USA',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    UserAddress(
      id: 'preset_3',
      userId: 'preset',
      label: 'Quick Mall',
      fullName: 'Shopping Center',
      phone: '+1 (555) 456-7890',
      addressLine1: '789 Commerce Boulevard',
      addressLine2: 'Near Food Court',
      city: 'Chicago',
      state: 'IL',
      postalCode: '60601',
      country: 'USA',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  List<UserAddress> get addresses => List.unmodifiable(_addresses);
  List<UserAddress> get presetAddresses => List.unmodifiable(_presetAddresses);
  UserAddress? get selectedAddress => _selectedAddress;

  AddressProvider() {
    loadAddresses();
  }

  // Load addresses from SharedPreferences
  Future<void> loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString('user_addresses');

      if (addressesJson != null) {
        final List<dynamic> decoded = json.decode(addressesJson);
        _addresses.clear();
        _addresses.addAll(decoded.map((item) => UserAddress.fromJson(item)).toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  // Save addresses to SharedPreferences
  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = json.encode(_addresses.map((addr) => addr.toJson()).toList());
      await prefs.setString('user_addresses', addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  // Select address for checkout
  void selectAddress(UserAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// Get addresses for a specific user
  List<UserAddress> getAddressesByUserId(String userId) {
    return _addresses.where((address) => address.userId == userId).toList();
  }

  /// Get default address for a user
  UserAddress? getDefaultAddress(String userId) {
    try {
      return _addresses.firstWhere(
        (address) => address.userId == userId && address.isDefault,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get address by ID
  UserAddress? getAddressById(String id) {
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new address
  Future<String> addAddress({
    required String userId,
    required String label,
    required String fullName,
    required String phone,
    required String addressLine1,
    String addressLine2 = '',
    required String city,
    required String state,
    required String postalCode,
    required String country,
    bool isDefault = false,
  }) async {
    final addressId = _uuid.v4();
    final now = DateTime.now();

    // If this is set as default, remove default from other addresses
    if (isDefault) {
      _removeDefaultFromOtherAddresses(userId);
    }

    final address = UserAddress(
      id: addressId,
      userId: userId,
      label: label,
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );

    _addresses.add(address);
    await _saveAddresses();
    notifyListeners();

    return addressId;
  }

  /// Update an existing address
  Future<void> updateAddress({
    required String id,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) async {
    final index = _addresses.indexWhere((address) => address.id == id);
    if (index == -1) return;

    final currentAddress = _addresses[index];
    
    // If this is set as default, remove default from other addresses
    if (isDefault == true) {
      _removeDefaultFromOtherAddresses(currentAddress.userId);
    }

    final updatedAddress = currentAddress.copyWith(
      label: label,
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      isDefault: isDefault,
      updatedAt: DateTime.now(),
    );

    _addresses[index] = updatedAddress;
    await _saveAddresses();
    notifyListeners();
  }

  /// Delete an address
  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((address) => address.id == id);
    await _saveAddresses();
    notifyListeners();
  }

  /// Set an address as default
  Future<void> setAsDefault(String id) async {
    final address = getAddressById(id);
    if (address == null) return;

    // Remove default from other addresses for this user
    _removeDefaultFromOtherAddresses(address.userId);

    // Set this address as default
    await updateAddress(id: id, isDefault: true);
  }

  /// Remove default status from other addresses of the same user
  void _removeDefaultFromOtherAddresses(String userId) {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].userId == userId && _addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: false,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  /// Load sample addresses (for demonstration)
  Future<void> loadSampleAddresses(String userId) async {
    final sampleAddresses = [
      UserAddress(
        id: _uuid.v4(),
        userId: userId,
        label: 'Home',
        fullName: 'John Doe',
        phone: '+1234567890',
        addressLine1: '123 Main Street',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        postalCode: '10001',
        country: 'USA',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserAddress(
        id: _uuid.v4(),
        userId: userId,
        label: 'Work',
        fullName: 'John Doe',
        phone: '+1234567890',
        addressLine1: '456 Business Ave',
        addressLine2: 'Suite 200',
        city: 'New York',
        state: 'NY',
        postalCode: '10002',
        country: 'USA',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    _addresses.addAll(sampleAddresses);
    await _saveAddresses();
    notifyListeners();
  }

  /// Add a preset address to user's addresses
  Future<String> addPresetAddress({
    required String userId,
    required String presetId,
    bool isDefault = false,
  }) async {
    final preset = _presetAddresses.firstWhere(
      (address) => address.id == presetId,
      orElse: () => throw Exception('Preset address not found'),
    );

    final addressId = _uuid.v4();
    final now = DateTime.now();

    // If this is set as default, remove default from other addresses
    if (isDefault) {
      _removeDefaultFromOtherAddresses(userId);
    }

    final address = UserAddress(
      id: addressId,
      userId: userId,
      label: preset.label,
      fullName: preset.fullName,
      phone: preset.phone,
      addressLine1: preset.addressLine1,
      addressLine2: preset.addressLine2,
      city: preset.city,
      state: preset.state,
      postalCode: preset.postalCode,
      country: preset.country,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );

    _addresses.add(address);
    await _saveAddresses();
    notifyListeners();

    return addressId;
  }

  /// Clear all addresses (for testing)
  Future<void> clearAddresses() async {
    _addresses.clear();
    await _saveAddresses();
    notifyListeners();
  }
}