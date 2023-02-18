/// Document ↓
/// https://api.flutter.dev/flutter/widgets/InteractiveViewer/transformationController.html

import 'package:flutter/material.dart';

class PinchZoom extends StatefulWidget {
  const PinchZoom({
    this.controller,
    required this.child,
    this.backgroudColor,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    this.scale = 3.0,
    this.animationController,
    this.curve = Curves.easeOut,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
    super.key,
  });

  final PinchZoomController? controller;
  final Widget child;
  final Color? backgroudColor;
  final double minScale;
  final double maxScale;

  /// Scale of child
  final double scale;

  final AnimationController? animationController;

  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
  final Curve curve;

  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCallback? onDoubleTap;

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom> with SingleTickerProviderStateMixin {
  late final PinchZoomController _controller;
  TapDownDetails? _doubleTapDetails;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = widget.animationController ??
        AnimationController(
          vsync: this, // the SingleTickerProviderStateMixin
          duration: const Duration(milliseconds: 400),
        );

    _controller = widget.controller ??
        PinchZoomController(
          animationController: _animationController,
        );
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _animationController.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroudColor,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (details) {
          _doubleTapDetails = details;

          WidgetsBinding.instance.addPersistentFrameCallback((_) {
            if (widget.onTapDown is GestureTapDownCallback && mounted) {
              widget.onTapDown!(details);
            }
          });
        },
        onDoubleTap: () {
          if (widget.onDoubleTap is GestureTapCallback && mounted) {
            widget.onDoubleTap!();
          }

          if (_doubleTapDetails == null) {
            return;
          }
          _controller.scenePosition = _controller.toScene(_doubleTapDetails!.localPosition);

          _controller.animationState = Matrix4Tween(
            begin: _controller.value,
            end: _controller.animationScale(widget.scale),
          ).animate(
            CurveTween(curve: widget.curve).animate(_controller.animationController),
          );
          _controller.animationController.forward(from: 0);
        },
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          onInteractionStart: (details) => _controller.onInteractionStart(details),
          child: widget.child,
        ),
      ),
    );
  }
}

class PinchZoomController extends TransformationController {
  PinchZoomController({
    required this.animationController,
    Matrix4? value,
  }) : super(value ?? Matrix4.identity()) {
    animationController.addListener(() {
      if (animationState is Animation<Matrix4>) {
        this.value = animationState!.value;
      }
    });
  }

  /// Controller during animation of [PinchZoomController]
  final AnimationController animationController;

  /// Value of [Matrix4] that is animated.
  Animation<Matrix4>? animationState;
  Offset? scenePosition;

  /// Called when the user pan or scale gesture on the widget.
  /// Overwrite the value of [value] with [animationState]
  void _onAnimateReset() {
    value = animationState!.value;
    if (!animationController.isAnimating) {
      animationState!.removeListener(_onAnimateReset);
      animationState = null;
      animationController.reset();
    }
  }

  /// [PinhZoom]'s animation scale
  Matrix4? animationScale(double scale, {bool reverse = false, Offset? position}) {
    position ??= scenePosition;
    if (position == null) {
      return null;
    } else if (value != Matrix4.identity()) {
      return Matrix4.identity();
    } else if (reverse) {
      return Matrix4.identity()
        ..translate(position.dx * scale, position.dy * scale)
        ..scale(scale);
    }

    return Matrix4.identity()
      ..translate(-position.dx * scale, -position.dy * scale)
      ..scale(scale);
  }

  /// Reset [PinchZoomController] values.
  void reset() {
    animationController.reset();
    scenePosition = null;
    animationState = Matrix4Tween(
      begin: value,
      end: Matrix4.identity(),
    ).animate(animationController);
    animationState!.addListener(_onAnimateReset);
    animationController.forward();
  }

  /// Stop a running reset to home transform animation.
  void _animateResetStop() {
    animationController.stop();
    animationState?.removeListener(_onAnimateReset);
    animationState = null;
    animationController.reset();
  }

  /// Called when the user begins a pan or scale gesture on the widget.
  void onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (animationController.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }
}
