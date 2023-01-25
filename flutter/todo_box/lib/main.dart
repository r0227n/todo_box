import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'models/default_table.dart';
import 'database/helper/sql_helper.dart';
import 'controller/query/todo_query.dart';
import 'pages/home_page.dart';
import 'provider/todo_query_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasesPath = await getDatabasesPath();
  const defaultTable = DefaultTable();

  final database = await openDatabase(
    defaultTable.path(databasesPath),
    onCreate: (db, version) async {
      await db.execute(defaultTable.create());
      await db.insert(DefaultTable.name, defaultTable.insert());
    },
    version: 1,
  );
  final helper = SqlHeloper(database, defaultTable.id);
  runApp(
    ProviderScope(
      overrides: [
        todoQueryProvider.overrideWithValue(TodoQuery(helper)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
