import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication
    if (email == 'admin@karma.com' && password == 'admin123') {
      _currentUser = User(
        id: '1',
        name: 'Admin User',
        email: email,
        phone: '+1234567890',
        address: 'Admin Address',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else if (email == 'user@karma.com' && password == 'user123') {
      _currentUser = User(
        id: '2',
        name: 'Customer User',
        email: email,
        phone: '+1234567890',
        address: 'Customer Address',
        role: UserRole.customer,
        createdAt: DateTime.now(),
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
    
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      address: '',  // Empty address, user can add it later from profile
      role: UserRole.customer,
      createdAt: DateTime.now(),
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