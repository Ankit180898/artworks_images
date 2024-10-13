import 'package:flutter/material.dart';

class PulsingCircleAnimation extends StatefulWidget {
  @override
  _PulsingCircleAnimationState createState() => _PulsingCircleAnimationState();
}

class _PulsingCircleAnimationState extends State<PulsingCircleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
          width: 50.0 + (10.0 * _controller.value),
          height: 50.0 + (10.0 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.5 - (0.3 * _controller.value)),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
