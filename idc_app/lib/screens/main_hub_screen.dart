import 'package:flutter/material.dart';
import '../core/network/connection_manager.dart' as cm;
import '../theme/app_theme.dart';

class MainHubContent extends StatelessWidget {
  final cm.ConnectionManager? connectionManager;

  const MainHubContent({super.key, this.connectionManager});

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
