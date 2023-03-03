import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../models/table.dart' as sql;

class TableCreateField extends StatefulWidget {
  const TableCreateField({super.key});

  @override
  State<TableCreateField> createState() => _TableCreateFieldState();
}

class _TableCreateFieldState extends State<TableCreateField> {
  final TextEditingController _txtController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  bool emojiShowing = false;

  @override
  void initState() {
    super.initState();
    _txtController.addListener(() {
      // カーソルを末尾に移動
      _txtController.selection = TextSelection.fromPosition(
        TextPosition(offset: _txtController.text.length), // 末尾にカーソルを移動
      );
    });
  }

  @override
  void dispose() {
    _txtController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Create new list'),
          actions: <Widget>[
            TextButton(
              onPressed: _txtController.text.isNotEmpty
                  ? () => Navigator.pop(context, sql.Table(
                        icon: _emojiController.text,
                        title: _txtController.text,
                        content: const <int>[],
                      ))
                  : null,
              child: const Text(
                'Done',
              ),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onDoubleTap: null,
          onHorizontalDragUpdate: (details) {
            // 左にスワイプ
            if (details.localPosition.dx < 45.0) {
              Navigator.pop(context, sql.Table(
                        icon: _emojiController.text,
                        title: _txtController.text,
                        content: const <int>[],
                      ));
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Center(
                  child: Text(
                    _emojiController.text,
                    style: const TextStyle(fontSize: 60.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 15.0),
                child: TextField(
                  controller: _txtController,
                  decoration: InputDecoration(
                    hintText: 'Enter list title',
                    suffixIcon: IconButton(
                      onPressed: _txtController.clear,
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      _txtController.text = text;
                    });
                  },
                ),
              ),
              Expanded(
                child: EmojiPicker(
                  textEditingController: _emojiController,
                  config: Config(
                    columns: 7,
                    // Issue: https://github.com/flutter/flutter/issues/28894
                    emojiSizeMax:
                        32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    initCategory: Category.RECENT,
                    bgColor: const Color(0xFFF2F2F2),
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    backspaceColor: Colors.blue,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    replaceEmojiOnLimitExceed: false,
                    noRecents: const Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                    checkPlatformCompatibility: true,
                  ),
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _emojiController.text = emoji.emoji;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async => true,
    );
  }
}
