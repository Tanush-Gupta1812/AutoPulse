import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';

final fleetDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    return await api.getFleetSummary();
  } catch (e) {
    // Fallback data matching Stitch screen 017d2d164e0b411f8b6b57eecdbb2c6e
    return {
      'total_vehicles': 6,
      'critical_risk_count': 2,
      'watchlist_count': 3,
      'healthy_count': 1,
      'prevented_breakdowns_count': 14,
      'total_fleet_savings_inr': 68500,
      'average_fleet_health': 81,
      'vehicles': [
        {
          'car_id': 'swift_2016',
          'name': 'Maruti Swift 2016 VXi',
          'license_plate': 'DL 3C AP 4821',
          'health_score': 54,
          'status': 'Critical',
          'risk_tier': 'High Risk',
          'urgent_forecast': 'Battery fails in ~9 days',
          'days_to_failure': 9,
          'prevented_savings_inr': 4500,
          'live_pids': {'battery': 11.8, 'coolant': 92.0, 'rpm': 780.0}
        },
        {
          'car_id': 'i20_2018',
          'name': 'Hyundai i20 2018 Asta',
          'license_plate': 'DL 8C BK 1904',
          'health_score': 61,
          'status': 'Warning',
          'risk_tier': 'High Risk',
          'urgent_forecast': 'Cooling temp creep, thermostat stuck',
          'days_to_failure': 6,
          'prevented_savings_inr': 18000,
          'live_pids': {'battery': 14.1, 'coolant': 104.0, 'rpm': 720.0}
        },
        {
          'car_id': 'city_2014',
          'name': 'Honda City 2014 VX',
          'license_plate': 'HR 26 CQ 9912',
          'health_score': 65,
          'status': 'Watch',
          'risk_tier': 'Watchlist',
          'urgent_forecast': 'O2 sensor slow response',
          'days_to_failure': 11,
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
          'urgent_forecast': 'Spark plug jitter',
          'days_to_failure': 18,
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
          'urgent_forecast': 'Alternator diode ripple',
          'days_to_failure': 25,
          'prevented_savings_inr': 6500,
          'live_pids': {'battery': 13.1, 'coolant': 88.0, 'rpm': 780.0}
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
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Garage & Fleet Intelligence', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)),
            Text('NIMS University Pilot Fleet (18 Active Cars)', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
          ],
        ),
      ),
      body: SafeArea(
        child: fleetAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) {
            final vehicles = (data['vehicles'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
            if (_selectedVehicle == null && vehicles.isNotEmpty) {
              _selectedVehicle = vehicles[0];
            }

            final filteredVehicles = vehicles.where((v) {
              if (_filter == 'ALL') return true;
              if (_filter == 'HIGH RISK') return v['risk_tier'] == 'High Risk';
              if (_filter == 'WATCHLIST') return v['risk_tier'] == 'Watchlist';
              return v['risk_tier'] == 'Healthy';
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Summary Bar
                  Row(
                    children: [
                      _buildKpiCard(context, 'Critical Imminent', '${data['critical_risk_count'] ?? 2}', AppTokens.statusCritical, 'Immediate Action'),
                      const SizedBox(width: 8),
                      _buildKpiCard(context, 'Breakdowns Prevented', '${data['prevented_breakdowns_count'] ?? 14}', isDark ? AppTokens.darkAccent : AppTokens.lightAccent, 'Past 30 Days'),
                      const SizedBox(width: 8),
                      _buildKpiCard(context, 'Customer Savings', '₹${data['total_fleet_savings_inr'] ?? 68500}', AppTokens.statusHealthy, 'Avoided Towing'),
                      const SizedBox(width: 8),
                      _buildKpiCard(context, 'Avg Fleet Health', '${data['average_fleet_health'] ?? 81}%', AppTokens.statusWatch, '18 OBD Nodes'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Filter Pills
                  Row(
                    children: ['ALL', 'HIGH RISK', 'WATCHLIST', 'HEALTHY'].map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _filter = f),
                          selectedColor: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.2),
                          labelStyle: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent) : (isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Responsive Body (Wide screen side-by-side or stacked)
                  if (isWide) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildVehiclesList(filteredVehicles, isDark)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildInspectionDrawer(isDark)),
                      ],
                    ),
                  ] else ...[
                    _buildVehiclesList(filteredVehicles, isDark),
                    if (_selectedVehicle != null) ...[
                      const SizedBox(height: 16),
                      _buildInspectionDrawer(isDark),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String label, String value, Color color, String sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(sub, style: GoogleFonts.inter(fontSize: 9, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList(List<Map<String, dynamic>> vehicles, bool isDark) {
    return Column(
      children: vehicles.map((v) {
        final isSelected = _selectedVehicle?['car_id'] == v['car_id'];
        final score = v['health_score'] as int;

        return GestureDetector(
          onTap: () => setState(() => _selectedVehicle = v),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isSelected ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent) : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Circular mini health gauge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTokens.getScoreColor(score).withOpacity(0.12),
                    border: Border.all(color: AppTokens.getScoreColor(score), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: AppTokens.getScoreColor(score)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(v['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(v['license_plate'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.warning_amber, size: 14, color: AppTokens.getStatusColor(v['status'] as String)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              v['urgent_forecast'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 12, color: AppTokens.getStatusColor(v['status'] as String), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInspectionDrawer(bool isDark) {
    if (_selectedVehicle == null) return const SizedBox.shrink();
    final v = _selectedVehicle!;
    final pids = v['live_pids'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Telemetry Node', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('1 Hz Active', style: GoogleFonts.inter(fontSize: 11, color: AppTokens.statusHealthy)),
            ],
          ),
          const SizedBox(height: 4),
          Text(v['name'] as String, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Plate: ${v['license_plate']}', style: GoogleFonts.inter(fontSize: 12)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Battery Voltage: ${pids['battery'] ?? 11.8} V', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Text('Coolant: ${pids['coolant'] ?? 92}°C', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Idle RPM: ${pids['rpm'] ?? 780}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Text('Savings: ₹${v['prevented_savings_inr']}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTokens.statusHealthy)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(currentCarIdProvider.notifier).state = v['car_id'] as String;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched active inspection vehicle to ${v['name']}')),
                );
              },
              child: const Text('Inspect in Main Cockpit'),
            ),
          ),
        ],
      ),
    );
  }
}
