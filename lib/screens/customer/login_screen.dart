import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/navigation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  
  // Additional fields for registration
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91'; // Default to India

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validate phone number with international support
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    
    final phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (_selectedCountryCode == '+91') {
      // India: 10 digits starting with 6-9
      final indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
      if (!indianPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit phone (starts with 6-9)';
      }
    } else if (_selectedCountryCode == '+1') {
      // USA/Canada: 10 digits
      final usPhoneRegex = RegExp(r'^\d{10}$');
      if (!usPhoneRegex.hasMatch(phone)) {
        return 'Enter valid 10-digit phone number';
      }
    } else if (_selectedCountryCode == '+44') {
      // UK: 10-11 digits
      if (phone.length < 10 || phone.length > 11 || !RegExp(r'^\d+$').hasMatch(phone)) {
        return 'Enter valid UK phone (10-11 digits)';
      }
    } else {
      // General: 7-15 digits
      final generalPhoneRegex = RegExp(r'^\d{7,15}$');
      if (!generalPhoneRegex.hasMatch(phone)) {
        return 'Enter valid phone number (7-15 digits)';
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('KarmaGully'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin ? AppLocalizations.of(context)!.welcomeBack : AppLocalizations.of(context)!.createAccount,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin 
                          ? AppLocalizations.of(context)!.signInToContinue
                          : AppLocalizations.of(context)!.joinKarmaShop,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.name,
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: DropdownButtonFormField<String>(
                                value: _selectedCountryCode,
                                decoration: const InputDecoration(
                                  labelText: 'Code',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                                  DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                                  DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                                  DropdownMenuItem(value: '+61', child: Text('🇦🇺 +61')),
                                  DropdownMenuItem(value: '+86', child: Text('🇨🇳 +86')),
                                  DropdownMenuItem(value: '+81', child: Text('🇯🇵 +81')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountryCode = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  hintText: _selectedCountryCode == '+91' ? '10-digit number' : 'Phone number',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: _validatePhoneNumber,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin 
                            ? 'Don\'t have an account? Sign Up' 
                            : 'Already have an account? Sign In',
                        ),
                      ),
                      
                      if (_isLogin) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text('Demo Accounts:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildDemoButton('Admin', 'admin@karma.com', 'admin123'),
                        const SizedBox(height: 8),
                        _buildDemoButton('Customer', 'user@karma.com', 'user123'),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton(String role, String email, String password) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _emailController.text = email;
          _passwordController.text = password;
        },
        child: Text('$role Login ($email)'),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success;

      if (_isLogin) {
        success = await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        success = await authProvider.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
        );
      }

      if (success && mounted) {
        final isAdmin = authProvider.isAdmin;
        if (isAdmin) {
          NavigationHelper.navigateToAdmin(context);
        } else {
          NavigationHelper.navigateToHome(context);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}