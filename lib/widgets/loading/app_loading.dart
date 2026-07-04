/// Loading indicators — spinner and shimmer placeholder.
library;

import 'package:flutter/material.dart';
import 'package:rug/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 40, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(width: size, height: size, child: CircularProgressIndicator(strokeWidth: 3, color: color ?? AppColors.accent)));
  }
}

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width = double.infinity, this.height = 16, this.borderRadius = 8});
  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(); }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width, height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: const [AppColors.shimmerBase, AppColors.shimmerHighlight, AppColors.shimmerBase],
            ),
          ),
        );
      },
    );
  }
}
