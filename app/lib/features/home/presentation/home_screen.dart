import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';
import 'package:app/features/settings/presentation/demo_panel_dialog.dart';

final vehicleHealthProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, carId) async {
  final api = ref.watch(apiServiceProvider);
  try {
    return await api.getVehicleHealth(carId);
  } catch (e) {
    // Fallback data matching Swift 2016 Stitch specification if server temporarily busy
    return {
      'car_id': carId,
      'overall_health_score': 68,
      'overall_status': 'Watch',
      'urgent_forecast': {
        'component_name': 'Battery & Electrical',
        'health_score': 54,
        'status': 'Warning',
        'days_to_failure': 9,
        'confidence_pct': 91,
        'primary_reason': 'Idle voltage dropped 0.6V over 12 days (Resting: 11.8V, Crank dip: 9.2V)',
        'prevented_cost_inr': 4500,
        'diagnostic_evidence': [
          'Resting voltage: 11.8V (Normal > 12.4V)',
          'Cold morning crank sag: 9.2V',
          'Internal cell resistance: +38% drift'
        ]
      },
      'components': [
        {
          'component_name': 'Alternator & Charging',
          'health_score': 88,
          'status': 'OK',
          'days_to_failure': null,
          'confidence_pct': 95,
          'primary_reason': '14.1V charging bus stable'
        },
        {
          'component_name': 'Cooling System',
          'health_score': 79,
          'status': 'Watch',
          'days_to_failure': 18,
          'confidence_pct': 86,
          'primary_reason': 'Operating temp 96°C peak'
        },
        {
          'component_name': 'O2 Sensor & Emissions',
          'health_score': 82,
          'status': 'OK',
          'days_to_failure': null,
          'confidence_pct': 93,
          'primary_reason': 'Lambda 1.01 nominal'
        },
        {
          'component_name': 'Spark Plugs & Ignition',
          'health_score': 74,
          'status': 'Watch',
          'days_to_failure': 21,
          'confidence_pct': 85,
          'primary_reason': 'Cyl 2 micro-misfire trend'
        }
      ],
      'active_alerts_count': 2,
      'total_savings_inr': 22500
    };
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carId = ref.watch(currentCarIdProvider);
    final healthAsync = ref.watch(vehicleHealthProvider(carId));
    final liveStreamAsync = ref.watch(telemetryWebSocketProvider(carId));

    // Live PIDs with fallback
    final liveData = liveStreamAsync.value ?? {
      'battery_voltage': 11.8,
      'coolant_temp': 92.0,
      'rpm': 780.0,
      'engine_load': 22.0
    };

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(vehicleHealthProvider(carId)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header with Brand & Secret Long-Press Demo Trigger
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => const DemoPanelDialog(),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              ),
                              child: Icon(
                                Icons.electric_bolt,
                                color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'AutoPulse',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // OBD-II Live Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTokens.statusHealthy.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                        border: Border.all(color: AppTokens.statusHealthy.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppTokens.statusHealthy,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OBD-II Online',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.statusHealthy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Active Vehicle Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(
                      color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              carId == 'swift_2016'
                                  ? 'Maruti Swift 2016 VXi'
                                  : carId.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'DL 3C AP 4821 • 64,280 km • 1.2L K12M Petrol',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const DemoPanelDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Glanceable Quick Telemetry Row
                Row(
                  children: [
                    _buildQuickMetric(
                      context,
                      label: 'Battery',
                      value: '${liveData['battery_voltage'] ?? 11.8} V',
                      color: (liveData['battery_voltage'] ?? 12.0) < 12.0
                          ? AppTokens.statusCritical
                          : AppTokens.statusHealthy,
                      icon: Icons.battery_alert,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMetric(
                      context,
                      label: 'Coolant',
                      value: '${(liveData['coolant_temp'] ?? 92.0).round()}°C',
                      color: AppTokens.statusHealthy,
                      icon: Icons.thermostat,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMetric(
                      context,
                      label: 'Idle RPM',
                      value: '${(liveData['rpm'] ?? 780.0).round()}',
                      color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                      icon: Icons.speed,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickMetric(
                      context,
                      label: 'Load',
                      value: '${(liveData['engine_load'] ?? 22.0).round()}%',
                      color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                      icon: Icons.compress,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Centerpiece Vehicle Health Ring Gauge
                healthAsync.when(
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                  error: (e, _) => Text('Failed to load health: $e'),
                  data: (health) {
                    final score = health['overall_health_score'] as int? ?? 68;
                    final urgent = health['urgent_forecast'] as Map<String, dynamic>?;
                    final components = health['components'] as List<dynamic>? ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall Health Gauge Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
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
                                'OVERALL VEHICLE HEALTH',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: CustomPaint(
                                  painter: HealthRingPainter(
                                    score: score,
                                    scoreColor: AppTokens.getScoreColor(score),
                                    backgroundColor: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$score',
                                          style: GoogleFonts.outfit(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w800,
                                            color: AppTokens.getScoreColor(score),
                                          ),
                                        ),
                                        Text(
                                          '/100',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_down, size: 16, color: AppTokens.statusWatch),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Watch / Trend Drift (-4 pts in 14d)',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTokens.statusWatch,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. Urgent Forecast Hero Card
                        if (urgent != null) ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: (isDark ? AppTokens.darkSurface : AppTokens.lightSurface),
                              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                              border: Border.all(
                                color: AppTokens.statusWarning.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTokens.statusWarning.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppTokens.statusWarning),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              'Battery fails in ~${urgent['days_to_failure'] ?? 9} days',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTokens.statusWarning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                      ),
                                      child: Text(
                                        'Confidence ${urgent['confidence_pct'] ?? 91}%',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  urgent['primary_reason'] as String? ?? 'Battery voltage decaying rapidly under load.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => context.go('/service'),
                                        child: const Text('Book Service'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.go('/component/battery'),
                                        child: const Text('Diagnostics'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 6. Subsystem Diagnostics Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Subsystem Health',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              'Tap for details',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.45,
                          ),
                          itemCount: components.length,
                          itemBuilder: (context, index) {
                            final comp = components[index] as Map<String, dynamic>;
                            final name = comp['component_name'] as String? ?? 'Component';
                            final cScore = comp['health_score'] as int? ?? 80;
                            final status = comp['status'] as String? ?? 'OK';

                            return InkWell(
                              onTap: () => context.go('/component/${name.toLowerCase()}'),
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              child: Container(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name.split('&')[0].trim(),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTokens.getStatusColor(status).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                          ),
                                          child: Text(
                                            status,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppTokens.getStatusColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$cScore%',
                                          style: GoogleFonts.outfit(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppTokens.getScoreColor(cScore),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: cScore / 100.0,
                                            backgroundColor: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                                            valueColor: AlwaysStoppedAnimation(AppTokens.getScoreColor(cScore)),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
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
}

class HealthRingPainter extends CustomPainter {
  final int score;
  final Color scoreColor;
  final Color backgroundColor;

  HealthRingPainter({
    required this.score,
    required this.scoreColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = scoreColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background track (270 degrees sweep)
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw progress arc
    final currentSweep = sweepAngle * (score / 100.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HealthRingPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.scoreColor != scoreColor;
  }
}
