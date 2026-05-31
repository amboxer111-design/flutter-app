import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pak_machinery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Enable FFI on Windows / Linux desktop
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE partners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sharePercentage REAL NOT NULL,
        mobileNumber TEXT NOT NULL,
        joiningDate TEXT NOT NULL,
        colorAssignment TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        registrationNumber TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE work_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        siteName TEXT NOT NULL,
        areaName TEXT NOT NULL,
        customerName TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        vehicleId INTEGER NOT NULL,
        vehicleName TEXT NOT NULL,
        workLocationId INTEGER NOT NULL,
        workLocationName TEXT NOT NULL,
        customerName TEXT NOT NULL,
        incomeAmount REAL NOT NULL,
        notes TEXT,
        recordedBy TEXT NOT NULL,
        recordedByColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE fuel_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        vehicleId INTEGER NOT NULL,
        vehicleName TEXT NOT NULL,
        workLocationId INTEGER NOT NULL,
        workLocationName TEXT NOT NULL,
        fuelQuantity REAL NOT NULL,
        fuelCost REAL NOT NULL,
        notes TEXT,
        recordedBy TEXT NOT NULL,
        recordedByColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE repair_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        vehicleId INTEGER NOT NULL,
        vehicleName TEXT NOT NULL,
        workLocationId INTEGER NOT NULL,
        workLocationName TEXT NOT NULL,
        engineOilCost REAL NOT NULL,
        hydraulicOilCost REAL NOT NULL,
        brakeOilCost REAL NOT NULL,
        sparePartsCost REAL NOT NULL,
        laborCost REAL NOT NULL,
        totalCost REAL NOT NULL,
        repairDescription TEXT,
        recordedBy TEXT NOT NULL,
        recordedByColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE partner_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        partnerId INTEGER NOT NULL,
        partnerName TEXT NOT NULL,
        amountPaid REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        notes TEXT,
        recordedBy TEXT NOT NULL,
        recordedByColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE outstanding_credits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        workLocationName TEXT NOT NULL,
        vehicleName TEXT NOT NULL,
        amountDue REAL NOT NULL,
        dueDate TEXT NOT NULL,
        paidAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        performedBy TEXT NOT NULL,
        partnerColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE edit_history_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        recordId INTEGER NOT NULL,
        oldValue TEXT NOT NULL,
        newValue TEXT NOT NULL,
        editedBy TEXT NOT NULL,
        editedByColor TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Seed default partners on genesis database
    await db.rawInsert('''
      INSERT INTO partners (name, sharePercentage, mobileNumber, joiningDate, colorAssignment)
      VALUES ('Asif Khan', 40.0, '03001234567', '2026-05-01', 'Yellow')
    ''');
    await db.rawInsert('''
      INSERT INTO partners (name, sharePercentage, mobileNumber, joiningDate, colorAssignment)
      VALUES ('Zia Rehman', 25.0, '03112345678', '2026-05-02', 'Red')
    ''');
    await db.rawInsert('''
      INSERT INTO partners (name, sharePercentage, mobileNumber, joiningDate, colorAssignment)
      VALUES ('Arslan Ali', 20.0, '03223456789', '2026-05-03', 'Black')
    ''');
    await db.rawInsert('''
      INSERT INTO partners (name, sharePercentage, mobileNumber, joiningDate, colorAssignment)
      VALUES ('Farhan Shah', 15.0, '03334567890', '2026-05-04', 'Green')
    ''');
  }

  Future<int> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<int> updateRecord(String table, String idColumn, int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(table, data, where: '\$idColumn = ?', whereArgs: [id]);
  }

  Future<int> deleteRecord(String table, String idColumn, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: '\$idColumn = ?', whereArgs: [id]);
  }
}
