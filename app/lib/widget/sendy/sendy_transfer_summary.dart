// Sendy: real transfer progress, accessible terminal states and drawn success mark.
import 'package:flutter/material.dart';
import 'package:localsend_app/config/sendy/sendy_transfer_state.dart';

class SendyTransferSummary extends StatelessWidget {
  final SendyTransferPhase phase;
  final String statusLabel;
  final String peer;
  final String details;
  final double? progress;
  final bool animate;
  const SendyTransferSummary({
    super.key,
    required this.phase,
    required this.statusLabel,
    required this.peer,
    required this.details,
    required this.progress,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = animate && !MediaQuery.disableAnimationsOf(context);
    final value = progress != null && progress!.isFinite ? progress!.clamp(0.0, 1.0).toDouble() : null;
    final color = phase == SendyTransferPhase.problem
        ? theme.colorScheme.error
        : phase == SendyTransferPhase.success
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    Widget indicator;
    if (phase == SendyTransferPhase.success) {
      indicator = SendySuccessMark(color: color, animate: motion);
    } else if (phase == SendyTransferPhase.problem) {
      indicator = Icon(Icons.info_outline_rounded, color: color, size: 64);
    } else {
      indicator = SizedBox(
        width: 128,
        height: 128,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: value ?? 0, end: value ?? 0),
                duration: motion ? const Duration(milliseconds: 180) : Duration.zero,
                builder: (context, current, _) => CircularProgressIndicator(
                  value: value == null ? 0 : current,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ),
            ),
            if (value != null && phase == SendyTransferPhase.active)
              Text('${(value * 100).floor()} %', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))
            else
              Icon(Icons.hourglass_top_rounded, size: 38, color: color),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  peer,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                ExcludeSemantics(
                  child: SizedBox(width: 128, height: 128, child: Center(child: indicator)),
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    statusLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    details,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
                if (value != null && phase == SendyTransferPhase.active)
                  Semantics(label: '${(value * 100).floor()} %', child: const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SendySuccessMark extends StatefulWidget {
  final Color color;
  final bool animate;
  const SendySuccessMark({super.key, required this.color, this.animate = true});
  @override
  State<SendySuccessMark> createState() => _SendySuccessMarkState();
}

class _SendySuccessMarkState extends State<SendySuccessMark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void didUpdateWidget(covariant SendySuccessMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  void _update() {
    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      // ignore: discarded_futures
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => CustomPaint(size: const Size(112, 112), painter: _CheckPainter(widget.color, _controller.value)),
  );
}

class _CheckPainter extends CustomPainter {
  final Color color;
  final double progress;
  _CheckPainter(this.color, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.shortestSide / 2, Paint()..color = color.withValues(alpha: .12));
    final path = Path()
      ..moveTo(size.width * .28, size.height * .52)
      ..lineTo(size.width * .44, size.height * .67)
      ..lineTo(size.width * .73, size.height * .35);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => color != old.color || progress != old.progress;
}
