import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MainHubContent extends StatelessWidget {
  const MainHubContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: Text(
          'Hub',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 18),
        ),
      ),
    );
  }
}
