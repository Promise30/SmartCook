import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/history_entry.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/bookmark.dart';

class DatabaseService {
  static Database? _database;
  static const String _historyTableName = 'history_entries';
  static const String _bookmarksTableName = 'bookmarks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smartcook.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_historyTableName(
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        ingredients TEXT NOT NULL,
        suggested_recipes TEXT NOT NULL,
        top_recipe TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $_bookmarksTableName(
        id TEXT PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        recipe_data TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $_bookmarksTableName(
          id TEXT PRIMARY KEY,
          timestamp INTEGER NOT NULL,
          recipe_data TEXT NOT NULL
        )
      ''');
    }
  }

  Future<String> saveHistoryEntry(HistoryEntry entry) async {
    final db = await database;
    await db.insert(
      _historyTableName,
      {
        'id': entry.id,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'ingredients': jsonEncode(entry.ingredients.map((i) => i.toJson()).toList()),
        'suggested_recipes': jsonEncode(entry.suggestedRecipes.map((r) => r.toJson()).toList()),
        'top_recipe': entry.topRecipe,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return entry.id;
  }

  Future<List<HistoryEntry>> getAllHistoryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _historyTableName,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return HistoryEntry(
        id: maps[i]['id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        ingredients: _ingredientsFromJson(maps[i]['ingredients']),
        suggestedRecipes: _recipesFromJson(maps[i]['suggested_recipes']),
        topRecipe: maps[i]['top_recipe'],
      );
    });
  }

  Future<void> deleteHistoryEntry(String id) async {
    final db = await database;
    await db.delete(
      _historyTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllHistory() async {
    final db = await database;
    await db.delete(_historyTableName);
  }
  
  // Bookmarks methods
  Future<String> saveBookmark(Bookmark bookmark) async {
    final db = await database;
    await db.insert(
      _bookmarksTableName,
      {
        'id': bookmark.id,
        'timestamp': bookmark.timestamp.millisecondsSinceEpoch,
        'recipe_data': jsonEncode(bookmark.recipe.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return bookmark.id;
  }
  
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookmarksTableName,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final recipeData = jsonDecode(maps[i]['recipe_data']) as Map<String, dynamic>;
      return Bookmark(
        id: maps[i]['id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        recipe: RecipeSuggestion.fromJson(recipeData),
      );
    });
  }
  
  Future<bool> isBookmarked(String recipeTitle) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookmarksTableName,
      where: 'id = ?',
      whereArgs: [recipeTitle],
    );
    return maps.isNotEmpty;
  }
  
  Future<void> deleteBookmark(String id) async {
    final db = await database;
    await db.delete(
      _bookmarksTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> clearAllBookmarks() async {
    final db = await database;
    await db.delete(_bookmarksTableName);
  }

  List<Ingredient> _ingredientsFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Ingredient.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  List<RecipeSuggestion> _recipesFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => RecipeSuggestion.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}
