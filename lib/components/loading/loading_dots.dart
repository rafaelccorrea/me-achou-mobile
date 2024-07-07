import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  const LoadingDots({Key? key}) : super(key: key);

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation1 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );

    _animation2 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );

    _animation3 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(_animation1, Colors.red),
        const SizedBox(width: 8),
        _buildDot(_animation2, Colors.green),
        const SizedBox(width: 8),
        _buildDot(_animation3, Colors.blue),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation, Color color) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Dot(color: color),
        );
      },
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;

  const Dot({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
