import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SensorsPillContent extends StatelessWidget {
  const SensorsPillContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sensors, color: AppTheme.textMuted, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Sensors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const Text(
            '3 Active',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.crimson,
            ),
          ),
        ],
      ),
    );
  }
}

class SensorsBody extends StatefulWidget {
  const SensorsBody({super.key});

  @override
  State<SensorsBody> createState() => _SensorsBodyState();
}

class _SensorsBodyState extends State<SensorsBody> {
  final Map<String, bool> _sensorStates = {
    'GPS': true,
    'Accelerometer': true,
    'Gyroscope': true,
    'Ambient Light': false,
    'Magnetometer': false,
    'Barometer': false,
    'Proximity': false,
    'Step Counter': false,
    'Rotation Vector': false,
    'Linear Acceleration': false,
  };

  static const List<_SensorData> _sensors = [
    _SensorData('Accelerometer', 'Movement, vibration, impact'),
    _SensorData('Gyroscope', 'Orientation, tilt, spin'),
    _SensorData('Magnetometer', 'Compass, magnetic field'),
    _SensorData('Barometer', 'Atmospheric pressure, altitude'),
    _SensorData('GPS', 'Location, speed, bearing'),
    _SensorData('Ambient Light', 'Light level in lux'),
    _SensorData('Proximity', 'Detects nearby objects'),
    _SensorData('Step Counter', 'Steps since last reset'),
    _SensorData('Rotation Vector', 'Full 3D orientation'),
    _SensorData('Linear Acceleration', 'Acceleration, gravity removed'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
      itemCount: _sensors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sensor = _sensors[index];
        return _SensorToggleCard(
          title: sensor.title,
          subtitle: sensor.subtitle,
          isOn: _sensorStates[sensor.title] ?? false,
          onToggle: () {
            setState(() {
              _sensorStates[sensor.title] = !(_sensorStates[sensor.title] ?? false);
            });
          },
        );
      },
    );
  }
}

class _SensorData {
  final String title;
  final String subtitle;
  const _SensorData(this.title, this.subtitle);
}

class _SensorToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOn;
  final VoidCallback onToggle;

  const _SensorToggleCard({
    required this.title,
    required this.subtitle,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOn ? AppTheme.textMuted : AppTheme.textDim,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 44,
                height: 26,
                decoration: BoxDecoration(
                  color: isOn ? null : const Color(0xFF3A3D5C),
                  gradient: isOn
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [AppTheme.green, Color(0xFF1F8A0C)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: 4,
                      left: isOn ? 22 : 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isOn ? AppTheme.textPrimary : AppTheme.textDim,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
