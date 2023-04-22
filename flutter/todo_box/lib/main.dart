import 'package:flutter/material.dart';
import 'package:todo_box/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'models/default_table.dart';
import 'models/todo_box_metadata.dart';
import 'database/helper/sql_helper.dart';
import 'controller/query/todo_query.dart';
import 'controller/local_notification_controller.dart';
import 'pages/home_page.dart';
import 'provider/todo_query_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 通知の初期化
  // TODO: foregroundResponseで指定する画面を[DetailPage]にする
  final notificationSetting = NotificationInitilizer();

  final databasesPath = await getDatabasesPath();
  const defaultTable = DefaultTable();

  final database = await openDatabase(
    defaultTable.path(databasesPath),
    onCreate: (db, version) async {
      await db.execute(defaultTable.create());
      await db.insert(DefaultTable.name, defaultTable.insert());

      final todoBoxMetadata =
          TodoBoxMetadata(notification: DateTime.now(), continueWriiting: false);
      await db.execute(TodoBoxMetadata.toCreateSql);
      await db.insert(todoBoxMetadata.tableName, todoBoxMetadata.toSql(containsId: false));
    },
    version: 1,
  );
  final helper = SqlHeloper(database, defaultTable.id);

  runApp(
    ProviderScope(
      overrides: [
        todoQueryProvider.overrideWithValue(TodoQuery(helper)),
        localNotificationPluguinProvider.overrideWithValue(notificationSetting.plugin),
      ],
      child: MyApp(
        notification: notificationSetting,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.notification});

  final NotificationInitilizer notification;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: notification.navigatorKey,
      title: 'Flutter Demo', // TODO: タイトルをいい感じに変更する
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'), // English
        Locale('ja'), // Japanese
      ],
      home: const HomePage(),
    );
  }
}
