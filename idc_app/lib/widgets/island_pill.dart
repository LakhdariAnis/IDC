import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IslandPill extends StatelessWidget {
  final Widget child;
  final double? width;

  const IslandPill({super.key, required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    final pillWidth = width ?? MediaQuery.of(context).size.width * 0.70;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 44,
            width: pillWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.fromRGBO(22, 23, 40, 0.7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Color.fromRGBO(108, 63, 219, 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x146C3FDB),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
