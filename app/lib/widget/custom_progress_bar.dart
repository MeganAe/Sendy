// Modified for Sendy: animate only real determinate progress, honor reduced motion.
import 'package:flutter/material.dart';
import 'package:localsend_app/provider/animation_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

class CustomProgressBar extends StatelessWidget {
  final double? progress;
  final double borderRadius;
  final Color? color;

  const CustomProgressBar({required this.progress, this.borderRadius = 10, this.color});

  @override
  Widget build(BuildContext context) {
    final animations = context.watch(animationProvider) && !MediaQuery.disableAnimationsOf(context);
    final value = progress?.clamp(0.0, 1.0).toDouble();
    Widget bar(double? current) => ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: current,
        color: color ?? Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        minHeight: 8,
      ),
    );
    if (value == null || !animations) {
      return TickerMode(enabled: animations, child: bar(value));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) => bar(current),
    );
  }
}
