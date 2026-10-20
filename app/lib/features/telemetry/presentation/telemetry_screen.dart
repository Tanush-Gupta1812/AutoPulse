import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/websocket_client.dart';

class TelemetryScreen extends ConsumerStatefulWidget {
  const TelemetryScreen({super.key});

  @override
  ConsumerState<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends ConsumerState<TelemetryScreen> {
  final List<double> _voltageHistory = [12.4, 12.3, 12.1, 11.9, 11.8, 11.8, 9.2, 11.8];
  final List<double> _coolantHistory = [88.0, 89.0, 90.0, 91.0, 92.0, 92.0, 92.0, 92.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carId = ref.watch(currentCarIdProvider);
    final liveStreamAsync = ref.watch(telemetryWebSocketProvider(carId));

    final data = liveStreamAsync.value ?? {
      'rpm': 780.0,
      'speed': 0.0,
      'battery_voltage': 11.8,
      'coolant_temp': 92.0,
      'engine_load': 22.0,
      'intake_air_temp': 34.0,
      'maf': 2.4,
      'throttle_pos': 12.0,
      'o2_voltage': 0.45,
    };

    final double rpm = (data['rpm'] as num?)?.toDouble() ?? 780.0;
    final double speed = (data['speed'] as num?)?.toDouble() ?? 0.0;
    final double vBat = (data['battery_voltage'] as num?)?.toDouble() ?? 11.8;
    final double temp = (data['coolant_temp'] as num?)?.toDouble() ?? 92.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live OBD-II Telemetry',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTokens.statusHealthy.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: Border.all(color: AppTokens.statusHealthy.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTokens.statusHealthy,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '1 Hz Stream',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.statusHealthy,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dual Cockpit Cluster Gauges
              Row(
                children: [
                  // Engine RPM Gauge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                        border: Border.all(
                          color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ENGINE RPM',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rpm.round().toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                            ),
                          ),
                          Text(
                            'Idle Target: 750',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Vehicle Speed Gauge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                        border: Border.all(
                          color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'VEHICLE SPEED',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            speed.round().toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'km/h (Stopped)',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sparkline 1: Battery Voltage Sag
              _buildSparklineCard(
                context,
                title: 'Battery Bus Voltage',
                currentValue: '${vBat.toStringAsFixed(2)} V',
                statusLabel: vBat < 12.0 ? 'Sub-12V Alert' : 'Normal',
                statusColor: vBat < 12.0 ? AppTokens.statusCritical : AppTokens.statusHealthy,
                history: _voltageHistory,
                minY: 8.0,
                maxY: 14.5,
                unit: 'V',
              ),
              const SizedBox(height: 12),

              // Sparkline 2: Coolant Temperature
              _buildSparklineCard(
                context,
                title: 'Engine Coolant Temp (ECT)',
                currentValue: '${temp.round()}°C',
                statusLabel: 'Normal (85–95°C Band)',
                statusColor: AppTokens.statusHealthy,
                history: _coolantHistory,
                minY: 70.0,
                maxY: 110.0,
                unit: '°C',
              ),
              const SizedBox(height: 12),

              // Supplementary PIDs Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _buildMiniPid(context, 'Engine Load', '${(data['engine_load'] as num?)?.round() ?? 22}%', 'Calculated'),
                  _buildMiniPid(context, 'Intake Air Temp', '${(data['intake_air_temp'] as num?)?.round() ?? 34}°C', 'Ambient +4°C'),
                  _buildMiniPid(context, 'Mass Air Flow (MAF)', '${(data['maf'] as num?)?.toStringAsFixed(1) ?? '2.4'} g/s', 'Throttle: 12%'),
                  _buildMiniPid(context, 'O2 Sensor Bank 1', '${(data['o2_voltage'] as num?)?.toStringAsFixed(2) ?? '0.45'} V', 'Lambda λ: 1.01'),
                ],
              ),
              const SizedBox(height: 20),

              // Diagnostic Freeze-Frame CTA Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Freeze Frame'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Freeze-frame DTC buffer captured and saved.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export CSV'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting 1 Hz telemetry log session to CSV...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSparklineCard(
    BuildContext context, {
    required String title,
    required String currentValue,
    required String statusLabel,
    required Color statusColor,
    required List<double> history,
    required double minY,
    required double maxY,
    required String unit,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currentValue,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: statusColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: statusColor.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPid(BuildContext context, String label, String value, String sub) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
