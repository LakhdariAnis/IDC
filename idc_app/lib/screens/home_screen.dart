import 'package:flutter/material.dart';
import '../core/network/foreground_service.dart';
import '../core/network/pc_device.dart';
import '../widgets/app_shell.dart';
import '../widgets/connected_status_content.dart';
import 'inbox_screen.dart';
import 'main_hub_screen.dart';
import 'remote_screen.dart';
import 'sensors_screen.dart';

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
  RemoteMode _remoteMode = RemoteMode.mouse;
  InboxTab _inboxTab = InboxTab.files;

  Widget _buildPillContent() {
    switch (_currentPage) {
      case AppPage.hub:
        return ConnectedStatusContent(
          device: widget.device,
          connectionState: ForegroundService.state,
        );
      case AppPage.sensors:
        return const SensorsPillContent();
      case AppPage.remote:
        return RemotePillContent(
          mode: _remoteMode,
          onModeChanged: (mode) => setState(() => _remoteMode = mode),
        );
      case AppPage.inbox:
        return InboxPillContent(
          tab: _inboxTab,
          onTabChanged: (tab) => setState(() => _inboxTab = tab),
        );
    }
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case AppPage.hub:
        return MainHubContent(
          onNavigateToSensors: () => _navigateTo(AppPage.sensors),
          onNavigateToRemote: () => _navigateTo(AppPage.remote),
          onNavigateToInbox: () => _navigateTo(AppPage.inbox),
        );
      case AppPage.sensors:
        return const SensorsBody();
      case AppPage.remote:
        return RemoteBody(mode: _remoteMode);
      case AppPage.inbox:
        return InboxBody(tab: _inboxTab);
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
      showBackButton: _currentPage != AppPage.hub,
      onBackPressed: () => _navigateTo(AppPage.hub),
      showSettingsButton: true,
      onSettingsPressed: () {},
    );
  }
}
