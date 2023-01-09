import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'list_page.dart';
import 'components/section.dart';
import 'components/emoji_text.dart';
import '../controller/table_controller.dart';
import '../models/table.dart' as sql;

final _currentTable = Provider<sql.Table>((ref) => throw UnimplementedError());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tableControllerProvider);

    return config.when(
      loading: () => const CircularProgressIndicator(),
      error: ((error, stackTrace) => Text('Error $error')),
      data: (tables) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Box',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_full_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ListPage(
                        'box',
                        display: PageDisplay.page,
                      ),
                      fullscreenDialog: true, // true だとモーダル遷移になる
                    ),
                  ),
                ),
              ),
              const Section(
                ration: 3,
                borderRadius: 8,
                child: ListPage(
                  'box',
                  display: PageDisplay.component,
                ),
              ),
              ListTile(
                title: Text(
                  'Lists',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Section(
                ration: 4,
                borderRadius: 5.0,
                child: ListView.builder(
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    return ProviderScope(
                      overrides: [
                        _currentTable.overrideWithValue(tables[index]),
                      ],
                      child: const _TodoItem(),
                    );
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 15.0)),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).primaryColor,
            // TODO: height propertyが認識されたら、高さを修正する
            shape: const AutomaticNotchedShape(
              RoundedRectangleBorder(),
              StadiumBorder(
                side: BorderSide(),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}

class _TodoItem extends ConsumerWidget {
  const _TodoItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(_currentTable);

    return Card(
      child: ListTile(
        leading: EmojiText(table.icon),
        title: Text(table.title),
        trailing: Text(
          '${table.content.length}',
          style: Theme.of(context).textTheme.caption,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListPage(
              table.title,
            ),
          ),
        ),
      ),
    );
  }
}
