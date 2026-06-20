import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'island_pill.dart';

class AppShell extends StatelessWidget {
  final String currentPage;
  final Widget pillContent;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget body;

  const AppShell({
    super.key,
    required this.currentPage,
    required this.pillContent,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showBackButton)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onBackPressed,
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppTheme.textPrimary,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: showBackButton ? 16 : 24),
              child: IslandPill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: SizedBox(
                    key: ValueKey('pill_$currentPage'),
                    child: Center(child: pillContent),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: SizedBox(
                  key: ValueKey('body_$currentPage'),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
