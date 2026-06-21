import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TouchModeBody extends StatelessWidget {
  const TouchModeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 350,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderSubtle, width: 1),
            ),
            child: const Center(
              child: Icon(
                Icons.touch_app,
                size: 48,
                color: AppTheme.textDim,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap to click \u00B7 Two fingers to right click',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
