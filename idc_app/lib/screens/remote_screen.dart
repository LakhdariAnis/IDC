import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'remote_keyboard_screen.dart';
import 'remote_mouse_screen.dart';
import 'remote_touch_screen.dart';

enum RemoteMode { mouse, touch, keyboard }

class RemotePillContent extends StatelessWidget {
  final RemoteMode mode;
  final ValueChanged<RemoteMode>? onModeChanged;

  const RemotePillContent({
    super.key,
    required this.mode,
    this.onModeChanged,
  });

  static const List<_TabEntry> _tabs = [
    _TabEntry(RemoteMode.mouse, 'Mouse'),
    _TabEntry(RemoteMode.touch, 'Touch'),
    _TabEntry(RemoteMode.keyboard, 'Keyboard'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _tabs.indexWhere((t) => t.mode == mode);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / 3;

          return SizedBox(
            height: 44,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: segmentWidth * activeIndex,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.crimson,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: _tabs.map((tab) {
                    final isActive = tab.mode == mode;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onModeChanged?.call(tab.mode),
                        child: Container(
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
                            ),
                            child: Text(tab.label),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabEntry {
  final RemoteMode mode;
  final String label;
  const _TabEntry(this.mode, this.label);
}

class RemoteBody extends StatelessWidget {
  final RemoteMode mode;

  const RemoteBody({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case RemoteMode.keyboard:
        return const KeyboardModeBody();
      case RemoteMode.mouse:
        return const MouseModeBody();
      case RemoteMode.touch:
        return const TouchModeBody();
    }
  }
}
