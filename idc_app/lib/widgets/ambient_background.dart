import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with TickerProviderStateMixin {
  late final AnimationController _navyCtl;
  late final AnimationController _violetCtl;
  late final AnimationController _crimsonCtl;

  @override
  void initState() {
    super.initState();

    const dur = Duration(seconds: 30);

    _navyCtl = AnimationController(vsync: this, duration: dur)..repeat();
    _violetCtl = AnimationController(vsync: this, duration: dur)..repeat();
    _crimsonCtl = AnimationController(vsync: this, duration: dur)..repeat();
  }

  @override
  void dispose() {
    _navyCtl.dispose();
    _violetCtl.dispose();
    _crimsonCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(color: const Color(0xFF0D0E1A)),
        ),

        _buildBlob(
          controller: _navyCtl,
          freq: 1.0,
          phaseX: 0.0,
          phaseY: 0.0,
          ampX: w * 0.08,
          ampY: h * 0.05,
          left: 0.0,
          top: (h - w) / 2,
          width: w,
          height: w,
          color: const Color.fromRGBO(10, 11, 20, 0.50),
          blurSigma: 100,
        ),

        _buildBlob(
          controller: _violetCtl,
          freq: 2.0,
          phaseX: 1.5,
          phaseY: 0.3,
          ampX: w * 0.12,
          ampY: h * 0.10,
          left: w * 0.15,
          top: (h - w * 0.7) / 2,
          width: w * 0.7,
          height: w * 0.7,
          color: const Color.fromRGBO(108, 63, 219, 0.30),
          blurSigma: 90,
        ),

        _buildBlob(
          controller: _crimsonCtl,
          freq: 3.0,
          phaseX: 4.2,
          phaseY: 2.7,
          ampX: w * 0.10,
          ampY: h * 0.05,
          left: 0.0,
          top: h * 0.61,
          width: w,
          height: h * 0.44,
          color: const Color.fromRGBO(224, 24, 90, 0.15),
          blurSigma: 80,
        ),

        widget.child,
      ],
    );
  }

  Widget _buildBlob({
    required AnimationController controller,
    required double freq,
    required double phaseX,
    required double phaseY,
    required double ampX,
    required double ampY,
    required double left,
    required double top,
    required double width,
    required double height,
    required Color color,
    required double blurSigma,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final angle = controller.value * 2 * pi;
            final dx = cos(angle * freq + phaseX) * ampX;
            final dy = sin(angle * freq + phaseY) * ampY;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: ClipOval(
                  child: Container(
                    width: width,
                    height: height,
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
