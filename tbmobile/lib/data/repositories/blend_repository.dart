import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/blend.dart';
import '../models/blend_ingredient.dart';

class BlendRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create a new blend
  Future<int> createBlend(Blend blend) async {
    final db = await _dbHelper.database;
    return await db.insert('blends', blend.toMap());
  }

  // Get all blends for a user
  Future<List<Blend>> getBlendsForUser(int userId, {bool asPatient = true}) async {
    final db = await _dbHelper.database;
    final column = asPatient ? 'formulated_for' : 'formulated_by';
    
    final List<Map<String, dynamic>> maps = await db.query(
      'blends',
      where: '$column = ?',
      whereArgs: [userId],
      orderBy: 'created_date DESC',
    );

    List<Blend> blends = [];
    for (var map in maps) {
      final blend = Blend.fromMap(map);
      final ingredients = await getBlendIngredients(map['blend_id']);
      blends.add(blend.copyWith(ingredients: ingredients));
    }
    
    return blends;
  }

  // Get a single blend with ingredients
  Future<Blend?> getBlend(int blendId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'blends',
      where: 'blend_id = ?',
      whereArgs: [blendId],
    );

    if (maps.isEmpty) return null;

    final blend = Blend.fromMap(maps.first);
    final ingredients = await getBlendIngredients(blendId);
    return blend.copyWith(ingredients: ingredients);
  }

  // Get blend ingredients
  Future<List<BlendIngredient>> getBlendIngredients(int blendId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        bi.*,
        i.name as ingredient_name,
        CASE 
          WHEN i.unit_of_measure = 133 THEN 'mg'
          WHEN i.unit_of_measure = 134 THEN 'mcg'
          WHEN i.unit_of_measure = 135 THEN 'g'
          WHEN i.unit_of_measure = 136 THEN 'IU'
          ELSE 'mg'
        END as unit_of_measure
      FROM blend_ingredients bi
      JOIN ingredients i ON bi.ingredient_id = i.ingredient_id
      WHERE bi.blend_id = ?
      ORDER BY bi.sequence
    ''', [blendId]);

    return maps.map((map) => BlendIngredient.fromMap(map)).toList();
  }

  // Add ingredient to blend
  Future<int> addIngredientToBlend(BlendIngredient ingredient) async {
    final db = await _dbHelper.database;
    
    // Get current max sequence for this blend
    final result = await db.rawQuery(
      'SELECT MAX(sequence) as max_seq FROM blend_ingredients WHERE blend_id = ?',
      [ingredient.blendId],
    );
    
    final maxSeq = result.first['max_seq'] as int? ?? 0;
    final newIngredient = ingredient.copyWith(sequence: maxSeq + 1);
    
    return await db.insert('blend_ingredients', newIngredient.toMap());
  }

  // Update blend ingredient amount
  Future<int> updateIngredientAmount(int ingredientId, double newAmount) async {
    final db = await _dbHelper.database;
    return await db.update(
      'blend_ingredients',
      {'amount': newAmount},
      where: 'id = ?',
      whereArgs: [ingredientId],
    );
  }

  // Remove ingredient from blend
  Future<int> removeIngredientFromBlend(int ingredientId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'blend_ingredients',
      where: 'id = ?',
      whereArgs: [ingredientId],
    );
  }

  // Update blend
  Future<int> updateBlend(Blend blend) async {
    final db = await _dbHelper.database;
    final updatedBlend = blend.copyWith(modifiedDate: DateTime.now());
    
    return await db.update(
      'blends',
      updatedBlend.toMap(),
      where: 'blend_id = ?',
      whereArgs: [blend.blendId],
    );
  }

  // Delete blend
  Future<int> deleteBlend(int blendId) async {
    final db = await _dbHelper.database;
    
    // Delete will cascade to blend_ingredients due to foreign key
    return await db.delete(
      'blends',
      where: 'blend_id = ?',
      whereArgs: [blendId],
    );
  }

  // Search blends by name
  Future<List<Blend>> searchBlends(String query, {int? userId}) async {
    final db = await _dbHelper.database;
    
    String where = 'name LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];
    
    if (userId != null) {
      where += ' AND (formulated_for = ? OR formulated_by = ?)';
      whereArgs.addAll([userId, userId]);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'blends',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_date DESC',
    );

    return maps.map((map) => Blend.fromMap(map)).toList();
  }

  // Get recent blends
  Future<List<Blend>> getRecentBlends({int limit = 5, int? userId}) async {
    final db = await _dbHelper.database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (userId != null) {
      where = 'formulated_for = ? OR formulated_by = ?';
      whereArgs = [userId, userId];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'blends',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_date DESC',
      limit: limit,
    );

    return maps.map((map) => Blend.fromMap(map)).toList();
  }

  // Mark blend as synced
  Future<int> markBlendAsSynced(int blendId, int serverBlendId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'blends',
      {
        'is_synced': 1,
        'server_blend_id': serverBlendId,
      },
      where: 'blend_id = ?',
      whereArgs: [blendId],
    );
  }

  // Get unsynced blends
  Future<List<Blend>> getUnsyncedBlends() async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'blends',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_date ASC',
    );

    List<Blend> blends = [];
    for (var map in maps) {
      final blend = Blend.fromMap(map);
      final ingredients = await getBlendIngredients(map['blend_id']);
      blends.add(blend.copyWith(ingredients: ingredients));
    }
    
    return blends;
  }
}