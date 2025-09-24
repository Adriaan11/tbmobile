import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'tailorblend.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table (both practitioners and patients)
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        mobile_number TEXT,
        user_type TEXT CHECK(user_type IN ('practitioner', 'patient', 'both')),
        account_number TEXT,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        last_sync DATETIME
      )
    ''');

    // Practitioner details
    await db.execute('''
      CREATE TABLE practitioners (
        practitioner_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER REFERENCES users(user_id),
        specializes_in TEXT,
        biography TEXT,
        is_active INTEGER DEFAULT 1,
        commission_basic REAL,
        commission_special REAL,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Practitioner-Client relationships
    await db.execute('''
      CREATE TABLE practitioner_clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        practitioner_id INTEGER REFERENCES practitioners(practitioner_id),
        client_id INTEGER REFERENCES users(user_id),
        is_validated INTEGER DEFAULT 0,
        reference_number TEXT UNIQUE,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Ingredients master data
    await db.execute('''
      CREATE TABLE ingredients (
        ingredient_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        label_name TEXT,
        category INTEGER,
        min_range REAL,
        recommended_range REAL,
        customer_max_range REAL,
        practitioner_max_range REAL,
        is_vegan INTEGER DEFAULT 0,
        is_vegetarian INTEGER DEFAULT 0,
        gluten_free INTEGER DEFAULT 0,
        cognitive INTEGER DEFAULT 0,
        energy INTEGER DEFAULT 0,
        immune INTEGER DEFAULT 0,
        muscle INTEGER DEFAULT 0,
        wellness INTEGER DEFAULT 0,
        beauty INTEGER DEFAULT 0,
        sleep INTEGER DEFAULT 0,
        female_health INTEGER DEFAULT 0,
        unit_of_measure INTEGER,
        retail_price REAL,
        benefits TEXT,
        warnings TEXT,
        is_in_stock INTEGER DEFAULT 1
      )
    ''');

    // Base mixes
    await db.execute('''
      CREATE TABLE base_mixes (
        base_mix_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type INTEGER,
        min_quantity REAL,
        max_quantity REAL,
        is_vegan INTEGER DEFAULT 0
      )
    ''');

    // Blends
    await db.execute('''
      CREATE TABLE blends (
        blend_id INTEGER PRIMARY KEY AUTOINCREMENT,
        blend_uid TEXT UNIQUE,
        name TEXT NOT NULL,
        formulated_for INTEGER REFERENCES users(user_id),
        formulated_by INTEGER REFERENCES users(user_id),
        description TEXT,
        notes TEXT,
        base_mix_id INTEGER REFERENCES base_mixes(base_mix_id),
        blend_status TEXT,
        total_amount REAL,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        modified_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
        server_blend_id INTEGER
      )
    ''');

    // Blend ingredients
    await db.execute('''
      CREATE TABLE blend_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        blend_id INTEGER REFERENCES blends(blend_id) ON DELETE CASCADE,
        ingredient_id INTEGER REFERENCES ingredients(ingredient_id),
        amount REAL NOT NULL,
        sequence INTEGER
      )
    ''');

    // Sync queue for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        operation TEXT CHECK(operation IN ('CREATE', 'UPDATE', 'DELETE')),
        data TEXT,
        created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        retry_count INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_blends_formulated_for ON blends(formulated_for)');
    await db.execute('CREATE INDEX idx_blends_formulated_by ON blends(formulated_by)');
    await db.execute('CREATE INDEX idx_blend_ingredients_blend ON blend_ingredients(blend_id)');
    await db.execute('CREATE INDEX idx_practitioner_clients_practitioner ON practitioner_clients(practitioner_id)');
    await db.execute('CREATE INDEX idx_practitioner_clients_client ON practitioner_clients(client_id)');
    await db.execute('CREATE INDEX idx_sync_queue_synced ON sync_queue(is_synced)');

    // Insert default base mixes
    await _insertDefaultBaseMixes(db);
    // Insert sample ingredients
    await _insertSampleIngredients(db);
    // Insert sample users
    await _insertSampleUsers(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> _insertDefaultBaseMixes(Database db) async {
    final baseMixes = [
      {'base_mix_id': 1, 'name': 'Shake (Whey)', 'type': 53, 'min_quantity': 29.615, 'max_quantity': 42.0, 'is_vegan': 0},
      {'base_mix_id': 2, 'name': 'Drink', 'type': 54, 'min_quantity': 2.04, 'max_quantity': 6.0, 'is_vegan': 0},
      {'base_mix_id': 6, 'name': 'Nutriblend-F', 'type': 213, 'min_quantity': 58.0, 'max_quantity': 1000.0, 'is_vegan': 0},
      {'base_mix_id': 7, 'name': 'Active Ingredients Only', 'type': 217, 'min_quantity': 2.55, 'max_quantity': 1000.0, 'is_vegan': 0},
      {'base_mix_id': 8, 'name': 'Shake (Vegan)', 'type': 53, 'min_quantity': 27.0, 'max_quantity': 42.0, 'is_vegan': 1},
    ];

    for (final baseMix in baseMixes) {
      await db.insert('base_mixes', baseMix);
    }
  }

  Future<void> _insertSampleIngredients(Database db) async {
    final ingredients = [
      {
        'ingredient_id': 1, 'name': 'Vitamin C', 'label_name': 'Vitamin C (Ascorbic Acid)',
        'min_range': 50.0, 'recommended_range': 500.0, 'customer_max_range': 1000.0,
        'practitioner_max_range': 2000.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'immune': 1, 'wellness': 1, 'unit_of_measure': 133,
        'retail_price': 0.05, 'benefits': 'Supports immune function, antioxidant'
      },
      {
        'ingredient_id': 2, 'name': 'Vitamin D3', 'label_name': 'Vitamin D3 (Cholecalciferol)',
        'min_range': 5.0, 'recommended_range': 25.0, 'customer_max_range': 50.0,
        'practitioner_max_range': 100.0, 'is_vegetarian': 1, 'gluten_free': 1,
        'immune': 1, 'wellness': 1, 'muscle': 1, 'unit_of_measure': 134,
        'retail_price': 0.08, 'benefits': 'Bone health, immune support'
      },
      {
        'ingredient_id': 3, 'name': 'Magnesium', 'label_name': 'Magnesium Glycinate',
        'min_range': 100.0, 'recommended_range': 300.0, 'customer_max_range': 400.0,
        'practitioner_max_range': 600.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'muscle': 1, 'sleep': 1, 'energy': 1, 'unit_of_measure': 133,
        'retail_price': 0.06, 'benefits': 'Muscle function, relaxation, energy production'
      },
      {
        'ingredient_id': 4, 'name': 'Ashwagandha', 'label_name': 'Ashwagandha Root Extract',
        'min_range': 200.0, 'recommended_range': 600.0, 'customer_max_range': 1000.0,
        'practitioner_max_range': 1500.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'cognitive': 1, 'sleep': 1, 'wellness': 1, 'unit_of_measure': 133,
        'retail_price': 0.12, 'benefits': 'Stress adaptation, cognitive support'
      },
      {
        'ingredient_id': 5, 'name': 'Omega-3', 'label_name': 'Omega-3 Fatty Acids',
        'min_range': 250.0, 'recommended_range': 1000.0, 'customer_max_range': 2000.0,
        'practitioner_max_range': 3000.0, 'gluten_free': 1, 'cognitive': 1,
        'beauty': 1, 'wellness': 1, 'unit_of_measure': 133,
        'retail_price': 0.15, 'benefits': 'Brain health, heart health, skin health'
      },
      {
        'ingredient_id': 6, 'name': 'B Complex', 'label_name': 'B Vitamin Complex',
        'min_range': 10.0, 'recommended_range': 50.0, 'customer_max_range': 100.0,
        'practitioner_max_range': 150.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'energy': 1, 'cognitive': 1, 'unit_of_measure': 133,
        'retail_price': 0.07, 'benefits': 'Energy metabolism, nervous system support'
      },
      {
        'ingredient_id': 7, 'name': 'Zinc', 'label_name': 'Zinc Picolinate',
        'min_range': 5.0, 'recommended_range': 15.0, 'customer_max_range': 30.0,
        'practitioner_max_range': 40.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'immune': 1, 'beauty': 1, 'unit_of_measure': 133,
        'retail_price': 0.04, 'benefits': 'Immune function, wound healing, skin health'
      },
      {
        'ingredient_id': 8, 'name': 'Collagen', 'label_name': 'Hydrolyzed Collagen Peptides',
        'min_range': 2500.0, 'recommended_range': 10000.0, 'customer_max_range': 20000.0,
        'practitioner_max_range': 25000.0, 'gluten_free': 1, 'beauty': 1,
        'muscle': 1, 'wellness': 1, 'unit_of_measure': 133,
        'retail_price': 0.25, 'benefits': 'Skin elasticity, joint health, muscle recovery'
      },
      {
        'ingredient_id': 9, 'name': 'Probiotics', 'label_name': 'Multi-Strain Probiotics',
        'min_range': 1.0, 'recommended_range': 10.0, 'customer_max_range': 50.0,
        'practitioner_max_range': 100.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'immune': 1, 'wellness': 1, 'unit_of_measure': 136,
        'retail_price': 0.20, 'benefits': 'Digestive health, immune support'
      },
      {
        'ingredient_id': 10, 'name': 'Turmeric', 'label_name': 'Turmeric Extract (95% Curcuminoids)',
        'min_range': 250.0, 'recommended_range': 500.0, 'customer_max_range': 1000.0,
        'practitioner_max_range': 1500.0, 'is_vegan': 1, 'is_vegetarian': 1,
        'gluten_free': 1, 'wellness': 1, 'beauty': 1, 'unit_of_measure': 133,
        'retail_price': 0.10, 'benefits': 'Anti-inflammatory, antioxidant'
      },
    ];

    for (final ingredient in ingredients) {
      await db.insert('ingredients', ingredient);
    }
  }

  Future<void> _insertSampleUsers(Database db) async {
    // Insert sample patients
    final users = [
      {
        'username': 'john.doe', 'first_name': 'John', 'last_name': 'Doe',
        'email': 'john.doe@example.com', 'mobile_number': '+27821234567',
        'user_type': 'patient', 'account_number': 'ACC001'
      },
      {
        'username': 'jane.smith', 'first_name': 'Jane', 'last_name': 'Smith',
        'email': 'jane.smith@example.com', 'mobile_number': '+27829876543',
        'user_type': 'patient', 'account_number': 'ACC002'
      },
      {
        'username': 'mike.johnson', 'first_name': 'Mike', 'last_name': 'Johnson',
        'email': 'mike.j@example.com', 'mobile_number': '+27835551234',
        'user_type': 'patient', 'account_number': 'ACC003'
      },
      {
        'username': 'sarah.wilson', 'first_name': 'Sarah', 'last_name': 'Wilson',
        'email': 'sarah.w@example.com', 'mobile_number': '+27841112222',
        'user_type': 'patient', 'account_number': 'ACC004'
      },
      {
        'username': 'david.brown', 'first_name': 'David', 'last_name': 'Brown',
        'email': 'david.b@example.com', 'mobile_number': '+27823334444',
        'user_type': 'patient', 'account_number': 'ACC005'
      },
    ];

    for (final user in users) {
      await db.insert('users', user);
    }
  }

  // Helper method to close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Helper method for raw queries
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Helper method for raw inserts
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  // Helper method for raw updates
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // Helper method for raw deletes
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }
}