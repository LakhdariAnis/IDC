import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KeyboardModeBody extends StatelessWidget {
  const KeyboardModeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = 16 + 44 + 20 + 12 + 12 + 40 + 4 + 356;
        final hasSpacer = constraints.maxHeight > contentHeight;

        if (hasSpacer) {
          return _buildColumn(withSpacer: true);
        } else {
          return SingleChildScrollView(
            child: _buildColumn(withSpacer: false),
          );
        }
      },
    );
  }

  Widget _buildColumn({required bool withSpacer}) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _MediaControlsRow(),
        const SizedBox(height: 20),
        _ShortcutsSection(),
        if (withSpacer) const Spacer(),
        _KeyboardGrid(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MediaControlsRow extends StatelessWidget {
  const _MediaControlsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MediaButton(icon: Icons.skip_previous),
          _MediaButton(icon: Icons.play_arrow),
          _MediaButton(icon: Icons.skip_next),
          _MediaButton(icon: Icons.volume_down),
          _MediaButton(icon: Icons.volume_up),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  const _MediaButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textMuted),
      ),
    );
  }
}

class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CUSTOM SHORTCUTS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppTheme.textDim,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ShortcutChip(icon: Icons.public, label: 'Browser'),
                const SizedBox(width: 8),
                _ShortcutChip(icon: Icons.lock, label: 'Lock Screen'),
                const SizedBox(width: 8),
                _ShortcutChip(icon: Icons.screenshot, label: 'Screenshot'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.crimson, width: 1),
                    ),
                    child: const Icon(Icons.add, color: AppTheme.crimson, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShortcutChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          const Text(
            'Browser',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardGrid extends StatelessWidget {
  const _KeyboardGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _KeyboardRow(
            height: 40,
            children: ['Esc', 'F1', 'F2', 'F3', 'F4', 'F5']
                .map((l) => _KeyButton(label: l, isMod: true))
                .toList(),
          ),
          const SizedBox(height: 4),
          _KeyboardRow(
            height: 48,
            children: [
              ...'1234567890'
                  .split('')
                  .map((c) => _KeyButton(label: c)),
              _KeyButton(
                icon: Icons.backspace,
                isMod: true,
                fixedWidth: 48,
              ),
            ],
          ),
          const SizedBox(height: 4),
          _KeyboardRow(
            height: 48,
            leading: const Spacer(flex: 1),
            children: 'QWERTYUIOP'
                .split('')
                .map((c) => _KeyButton(label: c))
                .toList(),
          ),
          const SizedBox(height: 4),
          _KeyboardRow(
            height: 48,
            leading: Expanded(
              flex: 2,
              child: _KeyButton(label: 'Tab', isMod: true),
            ),
            trailing: Expanded(
              flex: 2,
              child: _KeyButton(icon: Icons.keyboard_return, isMod: true),
            ),
            children: 'ASDFGHJKL'
                .split('')
                .map((c) => _KeyButton(label: c))
                .toList(),
          ),
          const SizedBox(height: 4),
          _KeyboardRow(
            height: 48,
            leading: Expanded(
              flex: 2,
              child: _KeyButton(label: 'Shift', isMod: true),
            ),
            trailing: Expanded(
              flex: 2,
              child: _KeyButton(label: 'Shift', isMod: true),
            ),
            children: 'ZXCVBNM'
                .split('')
                .map((c) => _KeyButton(label: c))
                .toList(),
          ),
          const SizedBox(height: 8),
          _BottomRow(),
        ],
      ),
    );
  }
}

class _KeyboardRow extends StatelessWidget {
  final double height;
  final List<_KeyButton> children;
  final Widget? leading;
  final Widget? trailing;

  const _KeyboardRow({
    required this.height,
    required this.children,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?leading,
          ...children.map((key) {
            if (key.fixedWidth != null) {
              return SizedBox(width: key.fixedWidth, child: key);
            }
            return Expanded(child: key);
          }),
          ?trailing,
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isMod;
  final double? fixedWidth;
  final Widget? customChild;

  const _KeyButton({
    this.label,
    this.icon,
    this.isMod = false,
    this.fixedWidth,
    this.customChild,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: isMod ? AppTheme.cardActiveGlow : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
        ),
        alignment: Alignment.center,
        child: customChild ?? _defaultChild(),
      ),
    );
  }

  Widget _defaultChild() {
    if (label != null) {
      return Text(
        label!,
        style: TextStyle(
          fontSize: isMod ? 12 : 14,
          color: isMod ? AppTheme.textMuted : AppTheme.textPrimary,
        ),
      );
    }
    if (icon != null) {
      return Icon(icon, size: 16, color: isMod ? AppTheme.textMuted : AppTheme.textPrimary);
    }
    return const SizedBox.shrink();
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 48, child: _KeyButton(label: 'Ctrl', isMod: true)),
          const SizedBox(width: 4),
          SizedBox(width: 48, child: _KeyButton(label: 'Win', isMod: true)),
          const SizedBox(width: 4),
          SizedBox(width: 48, child: _KeyButton(label: 'Alt', isMod: true)),
          const SizedBox(width: 4),
          const Expanded(child: _KeyButton(label: 'Space')),
          const SizedBox(width: 4),
          SizedBox(width: 48, child: _KeyButton(label: 'Alt', isMod: true)),
          const SizedBox(width: 4),
          SizedBox(width: 48, child: _KeyButton(icon: Icons.arrow_back, isMod: true)),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            child: _KeyButton(
              isMod: true,
              customChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_drop_up, size: 16, color: AppTheme.textMuted),
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(width: 48, child: _KeyButton(icon: Icons.arrow_forward, isMod: true)),
        ],
      ),
    );
  }
}
