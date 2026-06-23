import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'portal_painter.dart';

class PortalWidget extends StatefulWidget {
  final double scale;
  final double opacity;
  final double brightness;

  const PortalWidget({
    super.key,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.brightness = 1.0,
  });

  @override
  State<PortalWidget> createState() => _PortalWidgetState();
}

class _PortalWidgetState extends State<PortalWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Stopwatch _stopwatch;
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    ui.FragmentProgram.fromAsset('shaders/portal.frag').then((program) {
      if (mounted) setState(() => _program = program);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: Transform.scale(
        scale: widget.scale,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return RepaintBoundary(
              child: CustomPaint(
                painter: PortalPainter(
                  program: _program,
                  time: _stopwatch.elapsedMicroseconds / 1000000.0,
                  brightness: widget.brightness,
                ),
                isComplex: true,
                willChange: true,
                child: const SizedBox(width: 400, height: 400),
              ),
            );
          },
        ),
      ),
    );
  }
}
