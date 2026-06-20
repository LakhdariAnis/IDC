import 'package:flutter/material.dart';
import '../core/network/connection_manager.dart' as cm;
import '../core/network/pc_device.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/connected_status_content.dart';
import 'main_hub_screen.dart';

enum AppPage { hub, sensors, remote, inbox }

class HomeScreen extends StatefulWidget {
  final PcDevice device;
  final cm.ConnectionManager connectionManager;

  const HomeScreen({
    super.key,
    required this.device,
    required this.connectionManager,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppPage _currentPage = AppPage.hub;

  Widget _buildPillContent() {
    switch (_currentPage) {
      case AppPage.hub:
        return ConnectedStatusContent(
          device: widget.device,
          connectionState: widget.connectionManager.state,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case AppPage.hub:
        return MainHubContent(connectionManager: widget.connectionManager);
      default:
        return const SizedBox.shrink();
    }
  }

  void _navigateTo(AppPage page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPage: _currentPage.name,
      pillContent: _buildPillContent(),
      body: _buildBody(),
      showBackButton: false,
      onBackPressed: () => _navigateTo(AppPage.hub),
    );
  }
}
