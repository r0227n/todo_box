import 'package:flutter/material.dart';

enum ModButtonTheme {
  fillted(true),
  disabledFillted(false),
  filledTonal(true),
  disabledFilledTonal(false),
  outline(true),
  disabledOutline(false);

  final bool enable;

  const ModButtonTheme(this.enable);
}

class ModButton extends StatefulWidget {
  const ModButton({
    required this.icon,
    required this.selectedIcon,
    required this.modsStyle,
    this.onTap,
    super.key,
  });

  final Widget icon;
  final Widget selectedIcon;
  final ModButtonTheme modsStyle;
  final ValueChanged<bool>? onTap;

  @override
  State<ModButton> createState() => _ModButtonState();
}

class _ModButtonState extends State<ModButton> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onPressed = widget.modsStyle.enable
        ? () {
            setState(() {
              selected = !selected;
            });
            if (widget.onTap is ValueChanged<bool>) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  widget.onTap!(selected);
                }
              });
            }
          }
        : null;

    return IconButton(
      isSelected: selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: onPressed,
      style: _buttonStyle(context),
    );
  }

  VoidCallback? _enablePressed() {
    if (!widget.modsStyle.enable) {
      return null;
    }

    return () {
      setState(() {
        print('object');
        selected = !selected;
      });
    };
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    switch (widget.modsStyle) {
      case ModButtonTheme.fillted:
        return enabledFilledButtonStyle(selected, colors);
      case ModButtonTheme.disabledFillted:
        return disabledFilledButtonStyle(selected, colors);
      case ModButtonTheme.filledTonal:
        return enabledFilledButtonStyle(selected, colors);
      case ModButtonTheme.disabledFilledTonal:
        return disabledFilledButtonStyle(selected, colors);
      case ModButtonTheme.outline:
        return disabledFilledButtonStyle(selected, colors);
      case ModButtonTheme.disabledOutline:
        return disabledFilledButtonStyle(selected, colors);
    }
  }

  ButtonStyle enabledFilledButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      foregroundColor: selected ? colors.onPrimary : colors.primary,
      backgroundColor: selected ? colors.primary : colors.surfaceVariant,
      disabledForegroundColor: colors.onSurface.withOpacity(0.38),
      disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
      hoverColor: selected ? colors.onPrimary.withOpacity(0.08) : colors.primary.withOpacity(0.08),
      focusColor: selected ? colors.onPrimary.withOpacity(0.12) : colors.primary.withOpacity(0.12),
      highlightColor:
          selected ? colors.onPrimary.withOpacity(0.12) : colors.primary.withOpacity(0.12),
    );
  }

  ButtonStyle disabledFilledButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      disabledForegroundColor: colors.onSurface.withOpacity(0.38),
      disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
    );
  }

  ButtonStyle enabledFilledTonalButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      foregroundColor: selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
      backgroundColor: selected ? colors.secondaryContainer : colors.surfaceVariant,
      hoverColor: selected
          ? colors.onSecondaryContainer.withOpacity(0.08)
          : colors.onSurfaceVariant.withOpacity(0.08),
      focusColor: selected
          ? colors.onSecondaryContainer.withOpacity(0.12)
          : colors.onSurfaceVariant.withOpacity(0.12),
      highlightColor: selected
          ? colors.onSecondaryContainer.withOpacity(0.12)
          : colors.onSurfaceVariant.withOpacity(0.12),
    );
  }

  ButtonStyle disabledFilledTonalButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      disabledForegroundColor: colors.onSurface.withOpacity(0.38),
      disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
    );
  }

  ButtonStyle enabledOutlinedButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      backgroundColor: selected ? colors.inverseSurface : null,
      hoverColor: selected
          ? colors.onInverseSurface.withOpacity(0.08)
          : colors.onSurfaceVariant.withOpacity(0.08),
      focusColor: selected
          ? colors.onInverseSurface.withOpacity(0.12)
          : colors.onSurfaceVariant.withOpacity(0.12),
      highlightColor:
          selected ? colors.onInverseSurface.withOpacity(0.12) : colors.onSurface.withOpacity(0.12),
      side: BorderSide(color: colors.outline),
    ).copyWith(
      foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return colors.onInverseSurface;
        }
        if (states.contains(MaterialState.pressed)) {
          return colors.onSurface;
        }
        return null;
      }),
    );
  }

  ButtonStyle disabledOutlinedButtonStyle(bool selected, ColorScheme colors) {
    return IconButton.styleFrom(
      disabledForegroundColor: colors.onSurface.withOpacity(0.38),
      disabledBackgroundColor: selected ? colors.onSurface.withOpacity(0.12) : null,
      side: selected ? null : BorderSide(color: colors.outline.withOpacity(0.12)),
    );
  }
}
