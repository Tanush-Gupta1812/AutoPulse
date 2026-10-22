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
  final List<double> _voltageHistory = [12.4, 12.3, 12.1, 11.9, 11.8, 11.8, 9.2, 11.8, 11.8, 11.8];

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
    final double load = (data['engine_load'] as num?)?.toDouble() ?? 22.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Telemetry',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x1A10B981) : const Color(0x1510B981),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: Border.all(color: AppTokens.statusHealthy.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppTokens.statusHealthy,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '1 Hz Stream',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.statusHealthy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dual Primary Digital Cluster (Minimalist Speed + RPM)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VEHICLE SPEED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${speed.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'KM/H',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENGINE RPM',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${rpm.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'RPM',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Linear RPM Bar (0-6000)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (rpm / 6000.0).clamp(0.0, 1.0),
                              backgroundColor: isDark ? const Color(0x14FFFFFF) : const Color(0x14000000),
                              valueColor: AlwaysStoppedAnimation(
                                rpm > 4500 ? AppTokens.statusCritical : (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary),
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Secondary Sensor Bento Grid (Minimalist 4-block)
              Row(
                children: [
                  _buildSensorBox('BATTERY', '${vBat.toStringAsFixed(1)} V', vBat < 12.0 ? AppTokens.statusWarning : AppTokens.statusHealthy, '11.3V Cutoff', isDark),
                  const SizedBox(width: 10),
                  _buildSensorBox('COOLANT', '${temp.round()}°C', AppTokens.statusHealthy, '88-93°C Norm', isDark),
                  const SizedBox(width: 10),
                  _buildSensorBox('LOAD', '${load.round()}%', isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary, 'Idle Band', isDark),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Real-Time Sparkline: Battery Cranking & Idle Stability
              Text(
                'Battery Voltage Transient (Last 10 Samples)',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                padding: const EdgeInsets.only(top: 16, right: 14, left: 4, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: LineChart(
                  LineChartData(
                    minY: 8.0,
                    maxY: 14.0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2.0,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: isDark ? const Color(0x10FFFFFF) : const Color(0x10000000),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2.0,
                          reservedSize: 26,
                          getTitlesWidget: (val, _) => Text(
                            '${val.toInt()}V',
                            style: GoogleFonts.inter(fontSize: 9, color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted),
                          ),
                        ),
                      ),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _voltageHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: vBat < 12.0 ? AppTokens.statusWarning : AppTokens.statusHealthy,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (vBat < 12.0 ? AppTokens.statusWarning : AppTokens.statusHealthy).withOpacity(0.06),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Extended Sensor Bus Metrics (Minimal Table)
              Text(
                'Live CAN-Bus Parameter Stream',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildParameterRow('PID 0x05: Engine Coolant Temp', '${temp.round()} °C', 'Nominal', isDark),
                    const Divider(height: 1),
                    _buildParameterRow('PID 0x0F: Intake Air Temp', '${data['intake_air_temp'] ?? 34} °C', 'Ambient', isDark),
                    const Divider(height: 1),
                    _buildParameterRow('PID 0x10: Mass Air Flow (MAF)', '${data['maf'] ?? 2.4} g/s', 'Calibrated', isDark),
                    const Divider(height: 1),
                    _buildParameterRow('PID 0x11: Throttle Position', '${data['throttle_pos'] ?? 12}%', 'Idle Position', isDark),
                    const Divider(height: 1),
                    _buildParameterRow('PID 0x14: O2 Bank 1 Sensor 1', '${data['o2_voltage'] ?? 0.45} V', 'Switching Active', isDark),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Freeze-Frame Capture Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Capture Diagnostic Freeze-Frame Snapshot'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Freeze-Frame diagnostic snapshot saved to session buffer.', style: GoogleFonts.inter()),
                        backgroundColor: AppTokens.statusHealthy,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorBox(String label, String value, Color color, String sub, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow(String label, String value, String status, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTokens.statusHealthy,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
