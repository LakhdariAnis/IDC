import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/network/pc_device.dart';
import '../core/network/connection_manager.dart' as cm;

class ConnectedStatusContent extends StatelessWidget {
  final PcDevice device;
  final ValueNotifier<cm.ConnectionState> connectionState;

  const ConnectedStatusContent({
    super.key,
    required this.device,
    required this.connectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monitor, color: AppTheme.crimson, size: 16),
              const SizedBox(width: 8),
              Text(
                device.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ValueListenableBuilder<cm.ConnectionState>(
            valueListenable: connectionState,
            builder: (context, state, child) {
              final bool isConnected = state == cm.ConnectionState.connected;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusDot(isConnected: isConnected),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: isConnected ? AppTheme.green : AppTheme.textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isConnected;
  const _StatusDot({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isConnected ? AppTheme.green : AppTheme.textDim,
        shape: BoxShape.circle,
        boxShadow: isConnected
            ? [
                const BoxShadow(
                  color: Color(0x8039FF14),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
  }
}
