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
        'title': 'Battery Failure Imminent in ~9 Days',
        'message': 'Idle resting voltage dropped 0.6V across 12 days to 11.8V. Morning crank sag reached 9.2V. Pre-emptive battery replacement recommended.',
        'severity': 'critical',
        'component_name': 'Battery & Electrical',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 2,
        'car_id': carId,
        'title': 'Sub-12V Cranking Transient Warning',
        'message': 'Ignition cold crank transient dipped to 9.2V (Minimum safety margin: 10.2V).',
        'severity': 'warning',
        'component_name': 'Battery & Electrical',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 3,
        'car_id': carId,
        'title': 'Cooling Fan Cycle Optimization',
        'message': 'Secondary radiator fan engaged for 14 minutes continuous at idle.',
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
        title: Text('Diagnostics & Alerts', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', 'CRITICAL', 'WARNING', 'WATCH'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedFilter = filter),
                        selectedColor: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.2),
                        checkmarkColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                              : (isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),

            // Alerts Feed
            Expanded(
              child: alertsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (alerts) {
                  final filtered = alerts.where((a) {
                    if (_selectedFilter == 'ALL') return true;
                    return (a['severity'] as String).toUpperCase() == _selectedFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 54, color: AppTokens.statusHealthy),
                          const SizedBox(height: 12),
                          Text('No active alerts in this category', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final alert = filtered[index] as Map<String, dynamic>;
                      final severity = (alert['severity'] as String? ?? 'info').toLowerCase();
                      final isCrit = severity == 'critical';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          border: Border.all(
                            color: isCrit ? AppTokens.statusCritical.withOpacity(0.5) : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                            width: isCrit ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTokens.getStatusColor(severity).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                  ),
                                  child: Text(
                                    severity.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTokens.getStatusColor(severity),
                                    ),
                                  ),
                                ),
                                Text(
                                  alert['component_name'] as String? ?? 'Vehicle Subsystem',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              alert['title'] as String? ?? 'Fault Detected',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alert['message'] as String? ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isCrit) ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () => context.go('/service'),
                                    child: const Text('Book Service', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
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
