// Sendy fork: resolution-independent reconstruction of the approved two-file mark.
import 'package:flutter/material.dart';

class SendyLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final Color? color;
  const SendyLogo({super.key, this.size = 36, this.withText = true, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Sendy',
      image: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(size: Size(size, size * 1.16), painter: SendyMarkPainter(tint)),
          if (withText) ...[
            SizedBox(width: size * .32),
            Text(
              'sendy',
              style: TextStyle(
                fontSize: size * 1.12,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.8,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SendyMarkPainter extends CustomPainter {
  final Color color;
  const SendyMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 116);
    final paint = Paint()..color = color;
    final upper = Path()
      ..moveTo(13, 0)
      ..lineTo(48, 0)
      ..quadraticBezierTo(51, 0, 54, 3)
      ..lineTo(62, 11)
      ..lineTo(62, 28)
      ..quadraticBezierTo(62, 34, 56, 34)
      ..lineTo(46, 34)
      ..cubicTo(26, 34, 26, 64, 46, 64)
      ..cubicTo(54, 64, 54, 73, 46, 73)
      ..lineTo(13, 73)
      ..quadraticBezierTo(0, 73, 0, 60)
      ..lineTo(0, 13)
      ..quadraticBezierTo(0, 0, 13, 0)
      ..close();
    canvas.drawPath(upper, paint);
    canvas.translate(100, 116);
    canvas.rotate(3.141592653589793);
    canvas.drawPath(upper, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SendyMarkPainter oldDelegate) => oldDelegate.color != color;
}
