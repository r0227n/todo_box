import 'package:flutter/material.dart';

class TableCreateField extends StatefulWidget {
  const TableCreateField({super.key});

  @override
  State<TableCreateField> createState() => _TableCreateFieldState();
}

class _TableCreateFieldState extends State<TableCreateField> {
  late final TextEditingController txtController;

  @override
  void initState() {
    super.initState();
    txtController = TextEditingController();
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onDoubleTap: null,
          onHorizontalDragUpdate: (details) {
            if (details.localPosition.dx < 45.0) {
              // スワイプ方向が左の場合
              Navigator.pop(context, txtController.text);
            }
          },
          child: Column(
            children: <Widget>[
              TextField(
                controller: txtController,
                keyboardType: TextInputType.multiline,
              ),
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () => Navigator.pop(context, txtController.text),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async => true,
    );
  }
}
