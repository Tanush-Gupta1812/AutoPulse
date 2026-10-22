import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';

final fleetDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    return await api.getFleetSummary();
  } catch (e) {
    return {
      'total_vehicles': 6,
      'critical_risk_count': 1,
      'watchlist_count': 3,
      'healthy_count': 2,
      'prevented_breakdowns_count': 14,
      'total_fleet_savings_inr': 68500,
      'average_fleet_health': 81,
      'vehicles': [
        {
          'car_id': 'swift_2016',
          'name': 'Maruti Swift 2016 VXi',
          'license_plate': 'DL 3C AP 4821',
          'health_score': 54,
          'status': 'Warning',
          'risk_tier': 'High Risk',
          'urgent_forecast': 'Battery wear in ~9 days',
          'days_to_failure': 9,
          'prevented_savings_inr': 4500,
          'live_pids': {'battery': 11.8, 'coolant': 92.0, 'rpm': 780.0}
        },
        {
          'car_id': 'i20_2018',
          'name': 'Hyundai i20 2018 Asta',
          'license_plate': 'DL 8C BK 1904',
          'health_score': 61,
          'status': 'Watch',
          'risk_tier': 'Watchlist',
          'urgent_forecast': 'Thermostat opening latency',
          'days_to_failure': 24,
          'prevented_savings_inr': 18000,
          'live_pids': {'battery': 14.1, 'coolant': 94.0, 'rpm': 720.0}
        },
        {
          'car_id': 'city_2014',
          'name': 'Honda City 2014 VX',
          'license_plate': 'HR 26 CQ 9912',
          'health_score': 84,
          'status': 'OK',
          'risk_tier': 'Healthy',
          'urgent_forecast': 'Lambda nominal (1.01)',
          'days_to_failure': null,
          'prevented_savings_inr': 8500,
          'live_pids': {'battery': 14.2, 'coolant': 91.0, 'rpm': 700.0}
        },
        {
          'car_id': 'nexon_2020',
          'name': 'Tata Nexon 2020 XZ+',
          'license_plate': 'UP 16 BX 4410',
          'health_score': 72,
          'status': 'Watch',
          'risk_tier': 'Watchlist',
          'urgent_forecast': 'Spark plug gap wear drift',
          'days_to_failure': 35,
          'prevented_savings_inr': 5000,
          'live_pids': {'battery': 14.2, 'coolant': 90.0, 'rpm': 800.0}
        },
        {
          'car_id': 'xuv500_2015',
          'name': 'Mahindra XUV500 W8',
          'license_plate': 'DL 1V CD 3320',
          'health_score': 78,
          'status': 'Watch',
          'risk_tier': 'Watchlist',
          'urgent_forecast': 'Alternator diode ripple watch',
          'days_to_failure': 45,
          'prevented_savings_inr': 6500,
          'live_pids': {'battery': 13.6, 'coolant': 88.0, 'rpm': 780.0}
        },
        {
          'car_id': 'baleno_2019',
          'name': 'Maruti Baleno Alpha',
          'license_plate': 'DL 7C AR 5521',
          'health_score': 94,
          'status': 'OK',
          'risk_tier': 'Healthy',
          'urgent_forecast': 'All Systems Normal',
          'days_to_failure': null,
          'prevented_savings_inr': 0,
          'live_pids': {'battery': 14.25, 'coolant': 89.0, 'rpm': 740.0}
        }
      ]
    };
  }
});

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  String _filter = 'ALL';
  Map<String, dynamic>? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fleetAsync = ref.watch(fleetDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fleet Intelligence', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SafeArea(
        child: fleetAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error loading fleet: $e')),
          data: (fleet) {
            final vehicles = fleet['vehicles'] as List<dynamic>? ?? [];
            final filtered = vehicles.where((v) {
              if (_filter == 'ALL') return true;
              if (_filter == 'ATTENTION') return (v['status'] as String? ?? '') != 'OK';
              if (_filter == 'HEALTHY') return (v['status'] as String? ?? '') == 'OK';
              return true;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Minimal Overview Metrics Strip
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric('ACTIVE ASSETS', '${fleet['total_vehicles'] ?? 6}', isDark),
                        _buildVerticalDivider(isDark),
                        _buildMetric('AVG HEALTH', '${fleet['average_fleet_health'] ?? 81}%', isDark),
                        _buildVerticalDivider(isDark),
                        _buildMetric('SAVINGS', '₹${((fleet['total_fleet_savings_inr'] as int? ?? 68500) / 1000).toStringAsFixed(1)}k', isDark),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 18),

                  // 2. Filter Pills
                  Row(
                    children: ['ALL', 'ATTENTION', 'HEALTHY'].map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _filter = f),
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
                              f,
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

                  const SizedBox(height: 14),

                  // 3. Vehicles List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final v = filtered[idx] as Map<String, dynamic>;
                      final score = v['health_score'] as int? ?? 80;
                      final isSelected = _selectedVehicle?['car_id'] == v['car_id'];
                      final isAttention = (v['status'] as String? ?? 'OK') != 'OK';
                      final dotColor = isAttention ? AppTokens.statusWarning : AppTokens.statusHealthy;

                      return InkWell(
                        onTap: () => setState(() => _selectedVehicle = v),
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary)
                                  : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v['name'] as String? ?? 'Vehicle',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${v['license_plate']} • ${v['urgent_forecast']}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$score%',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    v['days_to_failure'] != null ? '~${v['days_to_failure']}d' : 'Nominal',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: dotColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 18),

                  // 4. Inspection Drawer
                  if (_selectedVehicle != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        border: Border.all(color: isDark ? AppTokens.darkBorderHigh : AppTokens.lightBorderHigh),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVehicle!['name'] as String,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                'Plate: ${_selectedVehicle!['license_plate']}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Loss Prevented: ₹${_selectedVehicle!['prevented_savings_inr']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.statusHealthy,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 34),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  ref.read(currentCarIdProvider.notifier).state = _selectedVehicle!['car_id'] as String;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Active vehicle set to ${_selectedVehicle!['name']}')),
                                  );
                                },
                                child: const Text('Set as Active', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 250.ms),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
    );
  }
}
