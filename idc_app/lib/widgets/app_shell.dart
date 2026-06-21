import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'island_pill.dart';

class AppShell extends StatelessWidget {
  final String currentPage;
  final Widget pillContent;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showSettingsButton;
  final VoidCallback? onSettingsPressed;
  final Widget body;

  const AppShell({
    super.key,
    required this.currentPage,
    required this.pillContent,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
    this.showSettingsButton = false,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && onBackPressed != null) {
          onBackPressed!();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: (showBackButton || showSettingsButton) ? 16 : 24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                        child: IslandPill(
                        child: PageTransitionSwitcher(
                          duration: const Duration(milliseconds: 380),
                          transitionBuilder:
                              (child, primaryAnimation, secondaryAnimation) {
                            return FadeThroughTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              fillColor: Colors.transparent,
                              child: child,
                            );
                          },
                          child: SizedBox(
                            key: ValueKey('pill_$currentPage'),
                            child: Center(child: pillContent),
                          ),
                        ),
                      ),
                    ),
                    if (showBackButton)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: onBackPressed,
                            child: const Icon(
                              Icons.chevron_left,
                              color: AppTheme.textMuted,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    if (showSettingsButton)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: onSettingsPressed,
                            child: const Icon(
                              Icons.settings,
                              color: AppTheme.textMuted,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) {
                    return FadeThroughTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      fillColor: Colors.transparent,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    key: ValueKey('body_$currentPage'),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
