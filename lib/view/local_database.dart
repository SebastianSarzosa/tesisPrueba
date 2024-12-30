import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    String path = join(await getDatabasesPath(), 'tesis_libros.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE proyectos (
        id_proyecto INTEGER PRIMARY KEY,
        nombre_proyecto TEXT,
        descripcion TEXT,
        fkid_libro INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE plantas (
        id_planta INTEGER PRIMARY KEY,
        nombre_planta TEXT,
        nombre_cientifico TEXT,
        fkid_proyecto INTEGER
      )
    ''');
  }

  // Guardar proyectos en la base de datos local
  Future<void> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    await db.insert(
      'proyectos',
      project,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener proyectos desde la base de datos local
  Future<List<Map<String, dynamic>>> getProjects(int bookId) async {
    final db = await database;
    return await db.query(
      'proyectos',
      where: 'fkid_libro = ?',
      whereArgs: [bookId],
    );
  }

  // Guardar plantas en la base de datos local
  Future<void> insertPlant(Map<String, dynamic> plant) async {
    final db = await database;
    await db.insert(
      'plantas',
      plant,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener plantas desde la base de datos local
  Future<List<Map<String, dynamic>>> getPlants(int projectId) async {
    final db = await database;
    return await db.query(
      'plantas',
      where: 'fkid_proyecto = ?',
      whereArgs: [projectId],
    );
  }
}
