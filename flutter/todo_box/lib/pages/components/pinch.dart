/// Document ↓
/// https://api.flutter.dev/flutter/widgets/InteractiveViewer/transformationController.html

import 'package:flutter/material.dart';

class Pinch extends StatelessWidget {
  const Pinch({
    this.controller,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    super.key,
  });

  final PinchController? controller;
  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InteractiveViewer(
        transformationController: controller?.transformationController,
        minScale: minScale,
        maxScale: maxScale,
        onInteractionStart: (details) => controller?.onInteractionStart(details),
        child: SizedBox.expand(
          child: child,
        ),
      ),
    );
  }
}

class PinchController extends ValueNotifier<Matrix4> {
  PinchController({
    required this.animationCtrl,
    Matrix4? value,
  })  : transformationController = TransformationController(value),
        super(value ?? Matrix4.identity());

  final AnimationController animationCtrl;
  final TransformationController transformationController;

  Animation<Matrix4>? _animationReset;

  @override
  void dispose() {
    animationCtrl.dispose();
    transformationController.dispose();
    _animationReset!.removeListener(onAnimateReset);
    super.dispose();
  }

  void onAnimateReset() {
    transformationController.value = _animationReset!.value;
    if (!animationCtrl.isAnimating) {
      _animationReset!.removeListener(onAnimateReset);
      _animationReset = null;
      animationCtrl.reset();
    }
  }

  void animateResetInitialize() {
    animationCtrl.reset();
    _animationReset = Matrix4Tween(
      begin: transformationController.value,
      end: Matrix4.identity(),
    ).animate(animationCtrl);
    _animationReset!.addListener(onAnimateReset);
    animationCtrl.forward();
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    animationCtrl.stop();
    _animationReset?.removeListener(onAnimateReset);
    _animationReset = null;
    animationCtrl.reset();
  }

  void onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (animationCtrl.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }
}
