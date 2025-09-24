import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/ingredient.dart';

class IngredientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all ingredients
  Future<List<Ingredient>> getAllIngredients() async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'is_in_stock = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Get ingredient by ID
  Future<Ingredient?> getIngredient(int ingredientId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
    );

    if (maps.isEmpty) return null;
    return Ingredient.fromMap(maps.first);
  }

  // Search ingredients by name
  Future<List<Ingredient>> searchIngredients(String query) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'name LIKE ? AND is_in_stock = ?',
      whereArgs: ['%$query%', 1],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Filter ingredients by health categories
  Future<List<Ingredient>> filterByHealthCategories({
    bool? cognitive,
    bool? energy,
    bool? immune,
    bool? muscle,
    bool? wellness,
    bool? beauty,
    bool? sleep,
    bool? femaleHealth,
  }) async {
    final db = await _dbHelper.database;
    
    List<String> conditions = ['is_in_stock = 1'];
    if (cognitive == true) conditions.add('cognitive = 1');
    if (energy == true) conditions.add('energy = 1');
    if (immune == true) conditions.add('immune = 1');
    if (muscle == true) conditions.add('muscle = 1');
    if (wellness == true) conditions.add('wellness = 1');
    if (beauty == true) conditions.add('beauty = 1');
    if (sleep == true) conditions.add('sleep = 1');
    if (femaleHealth == true) conditions.add('female_health = 1');

    final whereClause = conditions.join(' AND ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: whereClause.isNotEmpty ? whereClause : null,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Filter ingredients by dietary preferences
  Future<List<Ingredient>> filterByDietaryPreferences({
    bool? isVegan,
    bool? isVegetarian,
    bool? glutenFree,
  }) async {
    final db = await _dbHelper.database;
    
    List<String> conditions = ['is_in_stock = 1'];
    if (isVegan == true) conditions.add('is_vegan = 1');
    if (isVegetarian == true) conditions.add('is_vegetarian = 1');
    if (glutenFree == true) conditions.add('gluten_free = 1');

    final whereClause = conditions.join(' AND ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: whereClause,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Get recommended ingredients for health goals
  Future<List<Ingredient>> getRecommendedIngredients(List<String> healthGoals) async {
    final db = await _dbHelper.database;
    
    List<String> conditions = ['is_in_stock = 1'];
    
    for (String goal in healthGoals) {
      switch (goal.toLowerCase()) {
        case 'cognitive':
          conditions.add('cognitive = 1');
          break;
        case 'energy':
          conditions.add('energy = 1');
          break;
        case 'immune':
          conditions.add('immune = 1');
          break;
        case 'muscle':
          conditions.add('muscle = 1');
          break;
        case 'wellness':
          conditions.add('wellness = 1');
          break;
        case 'beauty':
          conditions.add('beauty = 1');
          break;
        case 'sleep':
          conditions.add('sleep = 1');
          break;
        case 'female health':
          conditions.add('female_health = 1');
          break;
      }
    }

    final whereClause = conditions.join(' OR ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: whereClause,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Insert multiple ingredients (for initial data load)
  Future<void> insertIngredients(List<Ingredient> ingredients) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    
    for (var ingredient in ingredients) {
      batch.insert(
        'ingredients',
        ingredient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Update ingredient
  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await _dbHelper.database;
    return await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'ingredient_id = ?',
      whereArgs: [ingredient.ingredientId],
    );
  }

  // Check if ingredients need update (for sync purposes)
  Future<bool> needsUpdate(DateTime? lastSync) async {
    if (lastSync == null) return true;
    
    final db = await _dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ingredients',
    );
    
    return (count.first['count'] as int) == 0;
  }
}