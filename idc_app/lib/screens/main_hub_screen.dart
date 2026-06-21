import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MainHubContent extends StatefulWidget {
  final VoidCallback onNavigateToSensors;
  final VoidCallback onNavigateToRemote;
  final VoidCallback onNavigateToInbox;

  const MainHubContent({
    super.key,
    required this.onNavigateToSensors,
    required this.onNavigateToRemote,
    required this.onNavigateToInbox,
  });

  @override
  State<MainHubContent> createState() => _MainHubContentState();
}

class _MainHubContentState extends State<MainHubContent> {
  bool _micOn = true;
  bool _cameraOn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardSize = (constraints.maxWidth - 12) / 2;
              return Row(
                children: [
                  SizedBox(
                    width: cardSize,
                    height: cardSize,
                    child: _DeviceToggleCard(
                      icon: Icons.mic,
                      label: 'Microphone',
                      isActive: _micOn,
                      activeText: 'Active',
                      inactiveText: 'Off',
                      onToggle: () => setState(() => _micOn = !_micOn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: cardSize,
                    height: cardSize,
                    child: _DeviceToggleCard(
                      icon: Icons.videocam,
                      label: 'Camera',
                      isActive: _cameraOn,
                      activeText: 'Active',
                      inactiveText: 'Off',
                      onToggle: () => setState(() => _cameraOn = !_cameraOn),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _HubNavCard(
            icon: Icons.sensors,
            title: 'Sensors',
            statusText: '3 Active',
            statusColor: AppTheme.crimson,
            onTap: widget.onNavigateToSensors,
          ),
          const SizedBox(height: 16),
          _HubNavCard(
            icon: Icons.sports_esports,
            title: 'Remote Control',
            statusText: 'Idle',
            statusColor: AppTheme.textDim,
            onTap: widget.onNavigateToRemote,
          ),
          const SizedBox(height: 16),
          _HubNavCard(
            icon: Icons.inbox,
            title: 'Inbox & Transfers',
            statusText: '2 New',
            statusColor: AppTheme.crimson,
            onTap: widget.onNavigateToInbox,
          ),
        ],
      ),
    );
  }
}

class _DeviceToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final String activeText;
  final String inactiveText;
  final VoidCallback onToggle;

  const _DeviceToggleCard({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,

          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppTheme.crimson : AppTheme.borderSubtle,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.5,
                        colors: [const Color(0x26E0185A), Colors.transparent],
                        stops: [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          size: 44,
                          color: isActive
                              ? AppTheme.crimson
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive ? activeText : inactiveText,
                          style: TextStyle(
                            fontSize: 14,
                            color: isActive
                                ? AppTheme.crimson
                                : AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 52,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isActive ? null : const Color(0xFF3A3D5C),
                            gradient: isActive
                                ? const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [AppTheme.green, Color(0xFF1F8A0C)],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: 3,
                                left: isActive ? 25 : 3,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.textPrimary
                                        : AppTheme.textDim,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String statusText;
  final Color statusColor;
  final VoidCallback onTap;

  const _HubNavCard({
    required this.icon,
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.textMuted, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 14, color: statusColor),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textDim, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
