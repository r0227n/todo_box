import 'package:flutter/material.dart';

/// 画面比率を指定したセクションWidget
class Section extends StatelessWidget {
  const Section({
    required this.ration,
    required this.child,
    this.borderRadius = 20.0,
    super.key,
  });

  /// 画面比率
  final int ration;

  /// 表示させるWidget
  final Widget child;

  /// [Section]の角丸の比率
  /// デフォルトは[20.0]
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: ration,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: child,
      ),
    );
  }
}
