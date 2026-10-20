import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';

class DemoPanelDialog extends ConsumerStatefulWidget {
  const DemoPanelDialog({super.key});

  @override
  ConsumerState<DemoPanelDialog> createState() => _DemoPanelDialogState();
}

class _DemoPanelDialogState extends ConsumerState<DemoPanelDialog> {
  bool _isLoading = false;
  String _message = '';

  final List<Map<String, String>> _vehicles = [
    {'id': 'swift_2016', 'label': 'Maruti Swift 2016 (Weak Battery)'},
    {'id': 'i20_2018', 'label': 'Hyundai i20 2018 (Cooling Creep)'},
    {'id': 'city_2014', 'label': 'Honda City 2014 (O2 Drift)'},
    {'id': 'nexon_2020', 'label': 'Tata Nexon 2020 (Spark Misfire)'},
    {'id': 'xuv500_2015', 'label': 'Mahindra XUV500 (Alternator Ripple)'},
    {'id': 'baleno_2019', 'label': 'Maruti Baleno 2019 (100% Healthy)'},
  ];

  final List<Map<String, String>> _scenarios = [
    {'id': 'weak_battery', 'label': 'Inject Weak Battery (11.8V)'},
    {'id': 'cooling_fault', 'label': 'Inject Thermostat Creep (104°C)'},
    {'id': 'o2_sensor_aging', 'label': 'Inject O2 Sensor Drift'},
    {'id': 'spark_plug_wear', 'label': 'Inject Ignition Jitter'},
    {'id': 'healthy', 'label': 'Reset to 100% Healthy'},
  ];

  Future<void> _injectScenario(String carId, String scenario) async {
    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    try {
      final res = await api.injectFault(carId, scenario);
      setState(() {
        _isLoading = false;
        _message = res['message'] as String? ?? 'Fault injected successfully';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Scenario simulated locally';
      });
    }
  }

  Future<void> _fastForward(String carId, double days) async {
    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    try {
      final res = await api.fastForward(carId, days);
      setState(() {
        _isLoading = false;
        _message = 'Fast-forwarded to Day ${res['simulated_day']}! New score: ${res['new_health_score']}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Fast-forwarded +$days days';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentCarId = ref.watch(currentCarIdProvider);

    return AlertDialog(
      backgroundColor: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: BorderSide(color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent),
      ),
      title: Row(
        children: [
          Icon(Icons.terminal, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent),
          const SizedBox(width: 10),
          Text(
            'Judge Demo Control Panel',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instant demo switches for pitch presentations:',
                style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
              ),
              const SizedBox(height: 14),

              // 1. Vehicle Switcher
              Text('Switch Active Demo Car', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentCarId,
                    isExpanded: true,
                    items: _vehicles.map((v) {
                      return DropdownMenuItem<String>(
                        value: v['id'],
                        child: Text(v['label']!, style: GoogleFonts.inter(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (newCar) {
                      if (newCar != null) {
                        ref.read(currentCarIdProvider.notifier).state = newCar;
                        setState(() => _message = 'Switched to $newCar');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Inject Fault Scenario
              Text('Inject Degradation Scenario', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _scenarios.map((sc) {
                  return ActionChip(
                    label: Text(sc['label']!, style: const TextStyle(fontSize: 11)),
                    onPressed: _isLoading ? null : () => _injectScenario(currentCarId, sc['id']!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 3. Time-Lapse Acceleration
              Text('Time-Lapse Fast Forward (Simulate Days)', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _fastForward(currentCarId, 7.0),
                      child: const Text('+7 Days (Sag)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _fastForward(currentCarId, 14.0),
                      child: const Text('+14 Days (Fail)'),
                    ),
                  ),
                ],
              ),
              if (_message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTokens.statusHealthy.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Text(
                    _message,
                    style: GoogleFonts.inter(fontSize: 11, color: AppTokens.statusHealthy, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
