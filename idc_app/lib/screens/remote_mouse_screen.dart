import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MouseModeBody extends StatefulWidget {
  const MouseModeBody({super.key});

  @override
  State<MouseModeBody> createState() => _MouseModeBodyState();
}

class _MouseModeBodyState extends State<MouseModeBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  final bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.05);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.crimson.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.crimson.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.screen_rotation,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Tilt your phone to move the cursor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Shake to toggle on/off',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardActiveGlow,
                    border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _isActive
                              ? AppTheme.crimson
                              : AppTheme.textDim,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: _isActive
                              ? AppTheme.crimson
                              : AppTheme.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.volume_up,
                    size: 16,
                    color: AppTheme.textDim,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Volume Up \u2192 Left Click',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.volume_down,
                    size: 16,
                    color: AppTheme.textDim,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Volume Down \u2192 Right Click',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
