import 'package:flutter/material.dart';
import 'keyboard_mods.dart';
import 'mod_tool.dart';

enum ModButtonType {
  fillted(true),
  disabledFillted(false),
  filledTonal(true),
  disabledFilledTonal(false),
  outline(true),
  disabledOutline(false);

  final bool enable;

  const ModButtonType(this.enable);
}

class ModButton extends StatefulWidget {
  const ModButton({
    this.icon,
    this.selectedIcon,
    this.chip,
    required this.type,
    required this.tool,
    this.enable = true,
    this.onTap,
    this.modIndex,
    this.select = false,
    this.callback,
    super.key,
  });

  const ModButton.fillted({
    this.icon,
    this.selectedIcon,
    this.chip,
    required this.tool,
    this.enable = true,
    this.onTap,
    super.key,
  })  : select = false,
        modIndex = null,
        callback = null,
        type = enable ? ModButtonType.fillted : ModButtonType.disabledFillted;

  const ModButton.filledTonal({
    this.icon,
    this.selectedIcon,
    this.chip,
    required this.tool,
    this.enable = true,
    this.onTap,
    super.key,
  })  : select = false,
        modIndex = null,
        callback = null,
        type = enable ? ModButtonType.filledTonal : ModButtonType.disabledFilledTonal;

  const ModButton.outline({
    this.icon,
    this.selectedIcon,
    this.chip,
    required this.tool,
    this.enable = true,
    this.onTap,
    super.key,
  })  : select = false,
        modIndex = null,
        callback = null,
        type = enable ? ModButtonType.outline : ModButtonType.disabledOutline;

  final Icon? icon;
  final Icon? selectedIcon;
  final ModActionChip? chip;
  final ModButtonType type;
  final ModTool tool;
  final bool enable;
  final ValueChanged<bool>? onTap;
  final bool select;
  final int? modIndex;
  final Function? callback;

  @override
  State<ModButton> createState() => _ModButtonState();

  ModButton copyWith({
    Icon? icon,
    Icon? selectedIcon,
    ModActionChip? chip,
    ModButtonType? type,
    ModTool? tool,
    bool? select,
    ValueChanged<bool>? onTap,
    int? modIndex,
    Function? callback,
  }) =>
      ModButton(
        icon: icon ?? this.icon,
        selectedIcon: selectedIcon ?? this.selectedIcon,
        chip: chip ?? this.chip,
        type: type ?? this.type,
        tool: tool ?? this.tool,
        select: select ?? this.select,
        onTap: onTap ?? this.onTap,
        modIndex: modIndex ?? this.modIndex,
        callback: callback ?? this.callback,
      );
}

class _ModButtonState extends State<ModButton> {
  late final VoidCallback? onPressed;

  @override
  void initState() {
    super.initState();

    onPressed = widget.type.enable
        ? () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              } else if (widget.onTap is ValueChanged<bool>) {
                widget.onTap!(widget.select);
              } else if (widget.callback is Function) {
                widget.callback!(widget.copyWith(select: widget.select), widget.modIndex);
              }
            });
          }
        : null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icon != null) {
      return IconButton(
        isSelected: widget.select,
        icon: widget.icon!,
        selectedIcon: widget.selectedIcon,
        onPressed: onPressed,
        style: _buttonStyle(context),
      );
    } else if (widget.chip != null) {
      return InputChip(
        shape: const StadiumBorder(side: BorderSide()),
        avatar: SizedBox.expand(
            child: FittedBox(
          child: widget.chip!.icon,
        )),
        label: Text(widget.chip!.label),
        onPressed: onPressed,
      );
    }

    throw FlutterError('build widget unknown');
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    switch (widget.type) {
      case ModButtonType.fillted:
        return enabledFilledButtonStyle(widget.select, colors);
      case ModButtonType.disabledFillted:
        return disabledFilledButtonStyle(widget.select, colors);
      case ModButtonType.filledTonal:
        return enabledFilledButtonStyle(widget.select, colors);
      case ModButtonType.disabledFilledTonal:
        return disabledFilledButtonStyle(widget.select, colors);
      case ModButtonType.outline:
        return disabledFilledButtonStyle(widget.select, colors);
      case ModButtonType.disabledOutline:
        return disabledFilledButtonStyle(widget.select, colors);
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
