import 'package:flutter/material.dart';

/// Tıklanabilir öğelere kısa ve hafif bir basılma geri bildirimi verir.
class AppPressableScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double pressedScale;

  const AppPressableScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.98,
  });

  @override
  State<AppPressableScale> createState() => _AppPressableScaleState();
}

class _AppPressableScaleState extends State<AppPressableScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  void didUpdateWidget(covariant AppPressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _isPressed) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
