import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/network/connection_manager.dart' as cm;
import '../core/network/discovery_service.dart';
import '../core/network/foreground_service.dart';
import '../core/network/pc_device.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_background.dart';
import 'home_screen.dart';

class _DiscoveredDevice {
  final String name;
  final String ip;
  final int wsPort;
  final String pcId;
  final double angleDeg;
  final double distance;

  const _DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.wsPort,
    required this.pcId,
    required this.angleDeg,
    required this.distance,
  });
}

class GateConnectionScreen extends StatefulWidget {
  const GateConnectionScreen({super.key});

  @override
  State<GateConnectionScreen> createState() => _GateConnectionScreenState();
}

class _GateConnectionScreenState extends State<GateConnectionScreen> {
  bool _isManualEntry = false;
  bool _isConnecting = false;
  String? _connectionError;
  PcDevice? _connectedDevice;
  List<_DiscoveredDevice>? _discovered;
  Timer? _scanTimer;
  Timer? _stateCheckTimer;

  @override
  void initState() {
    super.initState();
    ForegroundService.state.addListener(_onConnectionStateChanged);
    _checkExistingState();
  }

  @override
  void dispose() {
    _stopScanLoop();
    _stateCheckTimer?.cancel();
    ForegroundService.state.removeListener(_onConnectionStateChanged);
    super.dispose();
  }

  void _checkExistingState() {
    final current = ForegroundService.state.value;
    if (current == cm.ConnectionState.connected) {
      _navigateToHome();
    } else if (current == cm.ConnectionState.connecting) {
      setState(() => _isConnecting = true);
    } else {
      _stateCheckTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _startScanLoop();
      });
    }
  }

  void _startScanLoop() {
    _stopScanLoop();
    if (_isManualEntry || _discovered != null || _isConnecting) return;

    setState(() => _discovered = null);
    DiscoveryService().scan().then((devices) {
      if (!mounted) return;
      if (devices.isNotEmpty) {
        final rng = Random();
        setState(() {
          _discovered = devices.map((d) => _DiscoveredDevice(
            name: d.name,
            ip: d.ip,
            wsPort: d.wsPort,
            pcId: d.pcId,
            angleDeg: rng.nextDouble() * 180,
            distance: 95 + rng.nextDouble() * 40,
          )).toList();
        });
      } else {
        _scanTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) _startScanLoop();
        });
      }
    });
  }

  void _stopScanLoop() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  void _connectToDevice(PcDevice device) {
    if (_isConnecting) return;
    final current = ForegroundService.state.value;
    if (current == cm.ConnectionState.connected || current == cm.ConnectionState.connecting) {
      print('_connectToDevice: already $current, ignoring tap');
      return;
    }
    _stopScanLoop();
    print('_connectToDevice called: ${device.name} @ ${device.ip}:${device.wsPort} pcId=${device.pcId}');
    _connectedDevice = device;
    setState(() {
      _isConnecting = true;
      _connectionError = null;
      _discovered = null;
    });
    try {
      ForegroundService.connect(device);
    } catch (e) {
      print('_connectToDevice: ForegroundService.connect failed: $e');
      setState(() {
        _isConnecting = false;
        _connectionError = 'Connection failed';
      });
    }
  }

  void _onConnectionStateChanged() {
    _stateCheckTimer?.cancel();
    _stateCheckTimer = null;
    if (!mounted) return;
    final state = ForegroundService.state.value;
    print('_onConnectionStateChanged: state=$state');
    if (state == cm.ConnectionState.connected) {
      _navigateToHome();
    } else if (state == cm.ConnectionState.error) {
      _onConnectionFailed();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    final device = _connectedDevice ?? ForegroundService.connectedDevice;
    if (device == null) return;
    print('Connected, navigating to HomeScreen');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(device: device),
      ),
    );
  }

  void _onConnectionFailed() {
    if (!mounted) return;
    print('_onConnectionFailed triggered');
    ForegroundService.disconnect();
    setState(() {
      _isConnecting = false;
      _connectionError = 'Connection failed';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _connectionError = null);
      _startScanLoop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Stack(
          children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            transform: Matrix4.translationValues(
              0,
              _isManualEntry ? -300.0 : -60.0,
              0,
            ),
            child: AnimatedScale(
              scale: _isManualEntry ? 0.75 : 1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -130),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          width: 480,
                          height: _isManualEntry ? 100 : 480,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                opacity: _isManualEntry ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: const PulseRing(
                                  delay: Duration(seconds: 0),
                                ),
                              ),
                              AnimatedOpacity(
                                opacity: _isManualEntry ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: const PulseRing(
                                  delay: Duration(seconds: 1),
                                ),
                              ),
                              const _IconCircle(),
                              if (_discovered != null && !_isManualEntry)
                                ..._discovered!.map((d) => _RadarBlip(
                                  device: d,
                                  onTap: () => _connectToDevice(PcDevice(
                                    name: d.name,
                                    ip: d.ip,
                                    wsPort: d.wsPort,
                                    pcId: d.pcId,
                                  )),
                                )),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: _isManualEntry ? 0 : 8,
                        ),
                        Text(
                          _isConnecting
                              ? 'Connecting...'
                              : 'Looking for PC...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: (_isManualEntry || _isConnecting) ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                'Scanning local network',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textMuted,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_connectionError != null)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _connectionError!,
                  style: const TextStyle(
                    color: AppTheme.crimson,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
              transitionBuilder: (child, animation) {
                final sequenceAnimation = CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                );
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(sequenceAnimation),
                  child: FadeTransition(
                    opacity: sequenceAnimation,
                    child: child,
                  ),
                );
              },
              child: _isManualEntry
                  ? _buildManualEntryCard()
                  : _buildEnterIpText(),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEnterIpText() {
    return Container(
      key: const ValueKey('enter_ip_text'),
      padding: const EdgeInsets.only(bottom: 40.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() => _isManualEntry = true);
            _stopScanLoop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.transparent,
            child: const Text(
              'Enter IP Manually',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntryCard() {
    return Container(
      key: const ValueKey('manual_entry_card'),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ).copyWith(bottom: 40.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.card,
          border: Border.all(color: AppTheme.borderSubtle),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'DEVICE IP ADDRESS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            TextField(
              cursorColor: AppTheme.crimson,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: '192.168.x.x',
                hintStyle: const TextStyle(
                  color: AppTheme.textDim,
                  fontFamily: 'Inter',
                ),
                prefixIcon: const Icon(
                  Icons.wifi_tethering,
                  color: AppTheme.textMuted,
                ),
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppTheme.crimson),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.crimson.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.crimson,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  'Connect',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  setState(() => _isManualEntry = false);
                  _startScanLoop();
                },
                child: const Text(
                  'Back to Scanning',
                  style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarBlip extends StatefulWidget {
  final _DiscoveredDevice device;
  final VoidCallback onTap;

  const _RadarBlip({required this.device, required this.onTap});

  @override
  State<_RadarBlip> createState() => _RadarBlipState();
}

class _RadarBlipState extends State<_RadarBlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double distanceScale = 1.4;
    final double rad = widget.device.angleDeg * pi / 180;
    final double cx = widget.device.distance * distanceScale * cos(rad);
    final double cy = widget.device.distance * distanceScale * sin(rad);

    const double circleSize = 42;
    const double iconSize = 16;
    const double centerX = 240;
    const double centerY = 240;

    return Positioned(
      left: centerX + cx - circleSize / 2,
      top: centerY + cy - circleSize / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              print('Blip tapped: ${widget.device.name}');
              widget.onTap();
            },
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(scale: _scale.value, child: child),
              ),
              child: CustomPaint(
                size: const Size(circleSize, circleSize),
                painter: _BlipPainter(iconSize: iconSize),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.device.name,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.65),
              fontFamily: 'Inter',
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BlipPainter extends CustomPainter {
  final double iconSize;
  const _BlipPainter({required this.iconSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Offset.zero & size;

    canvas.saveLayer(rect, Paint());

    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(Icons.desktop_windows.codePoint),
        style: TextStyle(
          fontFamily: Icons.desktop_windows.fontFamily,
          package: Icons.desktop_windows.fontPackage,
          fontSize: iconSize,
          color: Colors.white,
        ),
      )
      ..layout();

    final glyphOffset = Offset(
      center.dx - tp.width / 2,
      center.dy - tp.height / 2,
    );

    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstOut);
    tp.paint(canvas, glyphOffset);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlipPainter old) => old.iconSize != iconSize;
}

class _IconCircle extends StatelessWidget {
  const _IconCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 77,
      height: 77,
      decoration: BoxDecoration(
        color: AppTheme.crimson,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.crimson.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.desktop_windows,
        size: 38.5,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class PulseRing extends StatefulWidget {
  final Duration delay;
  const PulseRing({super.key, required this.delay});

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0, 0.2, 1)),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0, 0.2, 1)),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay != Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.crimson.withOpacity(0.2),
              ),
            ),
          ),
        );
      },
    );
  }
}
