import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';

final alertsListProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, carId) async {
  final api = ref.watch(apiServiceProvider);
  try {
    return await api.getAlerts(carId);
  } catch (e) {
    return [
      {
        'id': 1,
        'car_id': carId,
        'title': 'Battery Terminal Cranking Sag Observed',
        'message': 'Resting voltage decaying at 0.05V/day. Cold crank transient dipped to 9.2V (OEM safe threshold: 10.2V). Wear horizon estimated at ~9 days.',
        'severity': 'critical',
        'component_name': 'Battery & Electrical',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 2,
        'car_id': carId,
        'title': 'Sub-12V Cranking Transient Logged',
        'message': 'Ignition start transient dip below 10V detected across 3 consecutive morning cycles.',
        'severity': 'warning',
        'component_name': 'Battery & Electrical',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 3,
        'car_id': carId,
        'title': 'Cooling System Thermal Window Stable',
        'message': 'ECT stabilized at 90.5°C with nominal radiator fan cycle. No boilover risk.',
        'severity': 'watch',
        'component_name': 'Cooling System',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      }
    ];
  }
});

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carId = ref.watch(currentCarIdProvider);
    final alertsAsync = ref.watch(alertsListProvider(carId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostics & Alerts', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimal Category Filter Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'CRITICAL', 'WARNING', 'WATCH'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary)
                                : (isDark ? AppTokens.darkSurface : AppTokens.lightSurface),
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? AppTokens.darkBackground : AppTokens.lightSurface)
                                  : (isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Alert Items Feed
            Expanded(
              child: alertsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, _) => Center(child: Text('Error loading alerts: $e')),
                data: (alerts) {
                  final filtered = alerts.where((a) {
                    if (_selectedFilter == 'ALL') return true;
                    return (a['severity'] as String? ?? '').toUpperCase() == _selectedFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 40,
                            color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No active alerts in this category',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final alert = filtered[idx] as Map<String, dynamic>;
                      final sev = (alert['severity'] as String? ?? 'info').toLowerCase();
                      final isCrit = sev == 'critical';
                      final isWarn = sev == 'warning';
                      final dotColor = isCrit
                          ? AppTokens.statusCritical
                          : isWarn
                              ? AppTokens.statusWarning
                              : AppTokens.statusHealthy;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          border: Border.all(
                            color: isCrit
                                ? AppTokens.statusCritical.withOpacity(0.35)
                                : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (alert['component_name'] as String? ?? 'Subsystem').toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: dotColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  sev.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert['title'] as String? ?? 'Diagnostic Alert',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert['message'] as String? ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final compName = (alert['component_name'] as String? ?? 'Battery').toLowerCase();
                                    context.go('/component/$compName');
                                  },
                                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Inspect Diagnostics',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 12,
                                          color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
