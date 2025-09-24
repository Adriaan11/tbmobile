import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // Uncomment when implementing actual API
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  // Replace with actual API endpoint
  // static const String _baseUrl = 'https://api.tailorblend.co.za'; // Uncomment when implementing actual API
  
  String? _authToken;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  String? get authToken => _authToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authToken != null;

  AuthService() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _currentUser = jsonDecode(userJson);
    }
    notifyListeners();
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
    _authToken = token;
    _currentUser = user;
    notifyListeners();
  }

  // Quick login for development - no validation
  Future<void> quickLogin({required String email}) async {
    final mockUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'firstName': email.split('@')[0].replaceAll('.', ' ').split(' ')[0],
      'lastName': '',
      'profileComplete': true,
    };
    
    final mockToken = 'dev_token_${DateTime.now().millisecondsSinceEpoch}';
    await _saveAuthData(mockToken, mockUser);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _authToken = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call - replace with actual endpoint
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful response
      if (email.isNotEmpty && password.isNotEmpty) {
        final mockUser = {
          'id': '123',
          'email': email,
          'firstName': email.split('@')[0],
          'lastName': '',
          'profileComplete': false,
        };
        
        final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        
        await _saveAuthData(mockToken, mockUser);
        
        return {
          'success': true,
          'message': 'Login successful',
          'user': mockUser,
        };
      } else {
        throw Exception('Invalid credentials');
      }

      // Actual API implementation would look like:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return {
          'success': true,
          'message': 'Login successful',
          'user': data['user'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception:', '').trim(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    int? age,
    String? activityLevel,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call - replace with actual endpoint
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful response
      if (email.isNotEmpty && password.length >= 8) {
        final mockUser = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'age': age,
          'activityLevel': activityLevel,
          'profileComplete': false,
        };
        
        final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        
        await _saveAuthData(mockToken, mockUser);
        
        return {
          'success': true,
          'message': 'Account created successfully',
          'user': mockUser,
        };
      } else {
        throw Exception('Invalid signup data');
      }

      // Actual API implementation would look like:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'age': age,
          'activityLevel': activityLevel,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return {
          'success': true,
          'message': 'Account created successfully',
          'user': data['user'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Signup failed');
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception:', '').trim(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'success': true,
        'message': 'Password reset instructions sent to $email',
      };

      // Actual API implementation:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset instructions sent to $email',
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send reset email');
      }
      */
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception:', '').trim(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<bool> validateToken() async {
    if (_authToken == null) return false;

    try {
      // Simulate token validation
      await Future.delayed(const Duration(seconds: 1));
      return true;

      // Actual API implementation:
      /*
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        await _clearAuthData();
        return false;
      }
      */
    } catch (e) {
      await _clearAuthData();
      return false;
    }
  }
}