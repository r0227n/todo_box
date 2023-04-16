import 'package:flutter/material.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Returns the title of the day of the week.
  /// For example, `DayOfWeek.monday.title` returns `monday`.
  String get title => toString().split('.').last;
}

class PopupDayOfWeekButton extends StatelessWidget {
  const PopupDayOfWeekButton({
    super.key,
    required this.value,
    this.size = const Size(100.0, 50.0),
    this.onChaged,
    this.onSelected,
  });

  /// The value of the currently selected item.
  final DayOfWeek value;

  /// The size of the button.
  final Size size;

  /// Called when the user selects an item.
  /// The button passes this callback the newly selected item's value.
  final ValueChanged<DayOfWeek>? onChaged;

  /// Called when the user selects an item.
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopupMenuButton<DayOfWeek>(
        initialValue: DayOfWeek.monday,
        child: SizedBox.fromSize(
          size: size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                value.title,
                style: const TextStyle(fontSize: 13.0),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        onSelected: (DayOfWeek day) {
          // Notify the caller of changes to the value.
          if (onChaged is ValueChanged<DayOfWeek>) {
            onChaged!(day);
          }
          // Action when the menu item is selected.
          if (onSelected is VoidCallback) {
            onSelected!();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<DayOfWeek>>[
          for (final item in DayOfWeek.values)
            PopupMenuItem<DayOfWeek>(
              value: item,
              child: Text(item.title),
            ),
        ],
      ),
    );
  }
}
