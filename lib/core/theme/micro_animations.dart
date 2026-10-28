import 'package:flutter/material.dart';

class MicroAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration chartSweep = Duration(milliseconds: 400);

  static const Curve springCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeInOutCubic;
}

/// A tactile button wrapper that shrinks slightly (0.95x) on tap for snappy feel
class TactileScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final HitTestBehavior behavior;

  const TactileScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<TactileScaleTap> createState() => _TactileScaleTapState();
}

class _TactileScaleTapState extends State<TactileScaleTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MicroAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
