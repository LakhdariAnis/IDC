import 'package:flutter/material.dart';
import '../core/network/foreground_service.dart';
import '../core/network/pc_device.dart';
import '../widgets/app_shell.dart';
import '../widgets/connected_status_content.dart';
import 'main_hub_screen.dart';

enum AppPage { hub, sensors, remote, inbox }

class HomeScreen extends StatefulWidget {
  final PcDevice device;

  const HomeScreen({
    super.key,
    required this.device,
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
          connectionState: ForegroundService.state,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case AppPage.hub:
        return const MainHubContent();
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
