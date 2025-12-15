import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../config/admin_config.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if admin credentials exist in AdminConfig
    final adminCreds = AdminConfig.getAdminCredentials(email);
    if (adminCreds != null && adminCreds['password'] == password) {
      _currentUser = User(
        id: adminCreds['id'],
        name: adminCreds['name'],
        email: email,
        phone: adminCreds['phone'],
        address: 'KarmaGully HQ',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        karmaId: adminCreds['karmaId'],
        isSuperAdmin: AdminConfig.isSuperAdmin(email),
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    
    // Regular customer login
    if (email == 'user@karma.com' && password == 'user123') {
      _currentUser = User(
        id: '2',
        name: 'Customer User',
        email: email,
        phone: '+1234567890',
        address: 'Customer Address',
        role: UserRole.customer,
        createdAt: DateTime.now(),
        karmaId: 'karma19812938',
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentUser = User(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      address: '',  // Empty address, user can add it later from profile
      role: UserRole.customer,
      createdAt: DateTime.now(),
      karmaId: 'karma$userId',
    );
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = updatedUser;
    notifyListeners();
  }
}