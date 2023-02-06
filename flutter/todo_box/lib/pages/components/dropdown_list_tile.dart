import 'package:flutter/material.dart';

class DorpdownListTile extends StatelessWidget {
  const DorpdownListTile({
    this.title,
    this.trailing = const Icon(
      Icons.arrow_drop_down,
      size: 24.0,
    ),
    this.onTap,
    super.key,
  });

  // TODO: leading プロパティを作る。Desktop onlyで表示
  final Widget? title;
  final Widget trailing;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SizedBox(
            height: 32.0,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 12.0),
                if (title != null) title!,
                const SizedBox(width: 8.0),
                trailing,
                const SizedBox(width: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
