import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sclad/%D0%BErder_page.dart';
import 'package:sclad/warehouse_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final warehouseDatabase = WarehouseDatabase();
  await warehouseDatabase.init();

  final logger = Logger();
  logger.i('App starting...');

  runApp(MyApp(logger: logger));
}

class MyApp extends StatelessWidget {
  final Logger logger;

  const MyApp({super.key, required this.logger});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MentorPage(logger: logger),
    );
  }
}
