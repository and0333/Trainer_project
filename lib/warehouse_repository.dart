// lib/repositories/mentor_repository.dart
import 'package:logger/logger.dart';
import 'package:sclad/warehouse_entiti.dart';
import 'package:sembast/sembast.dart';
import 'package:sclad/warehouse_database.dart';

class MentorRepository {
  final _store = stringMapStoreFactory.store('mentors');
  final Logger _logger;
  MentorRepository({required Logger logger}) : _logger = logger;

  Future<void> addMentor(Mentor mentor) async {
    final db = await WarehouseDatabase().database;
    await _store.record(mentor.id).put(db, mentor.toJson());
    _logger.i('Added mentor: ${mentor.toJson()}');
  }

  Future<List<Mentor>> getMentors() async {
    final db = await WarehouseDatabase().database;
    final snapshots = await _store.find(db);
    final mentors = snapshots.map((snapshot) {
      return Mentor.fromJson(snapshot.value as Map<String, dynamic>);
    }).toList();
    _logger.i('Fetched mentors: ${mentors.length} items');
    return mentors;
  }

  Future<void> updateMentor(Mentor mentor) async {
    final db = await WarehouseDatabase().database;
    await _store.record(mentor.id).update(db, mentor.toJson());
    _logger.i('Updated mentor: ${mentor.toJson()}');
  }

  Future<void> deleteMentor(String id) async {
    final db = await WarehouseDatabase().database;
    await _store.record(id).delete(db);
    _logger.i('Deleted mentor with ID: $id');
  }
}