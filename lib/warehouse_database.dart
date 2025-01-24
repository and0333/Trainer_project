// lib/warehouse_database.dart
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class WarehouseDatabase {
  static final WarehouseDatabase _instance = WarehouseDatabase._internal();

  factory WarehouseDatabase() => _instance;

  WarehouseDatabase._internal();

  Database? _db;

  Future<void> init() async {
    _db ??= await databaseFactoryWeb.openDatabase('warehouse.db');
  }

  Database get database {
    if (_db == null) {
      throw Exception("Database not initialized. Call init() first.");
    }
    return _db!;
  }
}