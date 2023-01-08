import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'database/helper/sql_helper.dart';
import 'database/query/todo_query.dart';
import 'database/static/todo_value.dart';
import 'pages/home_page.dart';
import 'provider/todo_query_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databasesPath = await getDatabasesPath();

  final database = await openDatabase(
    '$databasesPath$tableTodo.db',
    onCreate: (db, version) async {
      await db.execute(
        '''CREATE TABLE $tableTodo(
          $typeId,
          $typeTitle,
          $typeDone,
          $typeDate,
          $typeTags,
          $typeNotification
        )
        ''',
      );
      await db.insert(tableTodo, {
        columnTitle: '_📂' '_$tableTodo',
        columnDone: 0,
        columnDate: null,
        columnTags: null,
        columnNotification: 0,
      });
    },
    version: 1,
  );
  final helper = SqlHeloper(database, columnId);
  runApp(
    ProviderScope(
      overrides: [
        todoQueryProvider.overrideWithValue(TodoQuery(helper, tableTodo)),
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
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
