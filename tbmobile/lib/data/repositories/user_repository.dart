import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all practitioners
  Future<List<User>> getAllPractitioners() async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['practitioner'],
      orderBy: 'first_name, last_name',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Get all patients
  Future<List<User>> getAllPatients() async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['patient'],
      orderBy: 'first_name, last_name',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Search patients by name or email
  Future<List<User>> searchPatients(String query) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ? AND (first_name LIKE ? OR last_name LIKE ? OR email LIKE ?)',
      whereArgs: ['patient', '%$query%', '%$query%', '%$query%'],
      orderBy: 'first_name, last_name',
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Get user by ID
  Future<User?> getUser(int userId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Create user
  Future<int> createUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Get patients for a practitioner
  Future<List<User>> getPatientsForPractitioner(int practitionerId) async {
    final db = await _dbHelper.database;
    
    // Get unique patient IDs from blends
    final List<Map<String, dynamic>> blendMaps = await db.query(
      'blends',
      columns: ['formulated_for'],
      where: 'formulated_by = ? AND formulated_for IS NOT NULL',
      whereArgs: [practitionerId],
      distinct: true,
    );

    if (blendMaps.isEmpty) return [];

    final patientIds = blendMaps
        .map((map) => map['formulated_for'] as int)
        .toList();

    // Get user details for these patients
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: 'user_id IN (${patientIds.map((_) => '?').join(',')})',
      whereArgs: patientIds,
      orderBy: 'first_name, last_name',
    );

    return userMaps.map((map) => User.fromMap(map)).toList();
  }
}