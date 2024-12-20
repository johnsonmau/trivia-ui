import 'package:flutter/material.dart';

class AnimatedResultIcon extends StatefulWidget {
  final bool isCorrect;

  const AnimatedResultIcon({Key? key, required this.isCorrect}) : super(key: key);

  @override
  _AnimatedResultIconState createState() => _AnimatedResultIconState();
}

class _AnimatedResultIconState extends State<AnimatedResultIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true); // Repeats the animation in a loop

    // Define the scaling animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        widget.isCorrect ? Icons.check_circle_outline : Icons.clear_rounded,
        color: widget.isCorrect ? Colors.green : Colors.red,
        size: 65,
      ),
    );
  }
}
