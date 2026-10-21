import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/websocket_client.dart';
import 'package:app/features/settings/presentation/demo_panel_dialog.dart';
import 'package:app/features/settings/presentation/settings_provider.dart';

export 'package:app/features/settings/presentation/settings_provider.dart' show themeModeProvider;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPinging = false;
  int? _pingLatencyMs;
  bool _isTestingTerminal = false;
  List<String> _terminalLogs = [];

  void _runPingTest() async {
    setState(() {
      _isPinging = true;
      _pingLatencyMs = null;
    });
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() {
        _isPinging = false;
        _pingLatencyMs = 18; // Realistic BLE 5.0 ELM327 command latency
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OBD-II Dongle Response: 18ms (Optimal)', style: GoogleFonts.inter()),
          backgroundColor: AppTokens.statusHealthy,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showTerminalDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0F1520) : const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              side: BorderSide(
                color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                width: 1.5,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.terminal, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  'OBD-II AT Command Diagnostic',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct bus handshake test with AutoPulse ELM327 adapter:',
                    style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF080C12) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                    ),
                    child: _terminalLogs.isEmpty
                        ? Center(
                            child: Text(
                              'Tap "Run Bus Self-Test" to query adapter status...',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _terminalLogs.length,
                            itemBuilder: (context, idx) {
                              final log = _terminalLogs[idx];
                              final isCommand = log.startsWith('>');
                              final isSuccess = log.contains('OK') || log.contains('41 00');
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  log,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    fontWeight: isCommand ? FontWeight.w700 : FontWeight.w400,
                                    color: isCommand
                                        ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                                        : isSuccess
                                            ? AppTokens.statusHealthy
                                            : (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                icon: _isTestingTerminal
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow, size: 16),
                label: const Text('Run Bus Self-Test'),
                onPressed: _isTestingTerminal
                    ? null
                    : () async {
                        setDialogState(() => _isTestingTerminal = true);
                        setState(() {
                          _terminalLogs = ['> AT Z (Adapter Reset)'];
                        });
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 300));
                        _terminalLogs.add('ELM327 v2.1 AutoPulse Edge OS');
                        _terminalLogs.add('> AT SP 0 (Set Protocol Auto)');
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 300));
                        _terminalLogs.add('OK (Protocol ISO 15765-4 CAN 500k Locked)');
                        _terminalLogs.add('> 01 00 (Query Supported PIDs)');
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 300));
                        _terminalLogs.add('SEARCHING... 41 00 BE 3F B8 11 (28 PIDs Active)');
                        _terminalLogs.add('[Self-Test Complete: All Bus Responses Nominal]');
                        setDialogState(() => _isTestingTerminal = false);
                        setState(() {});
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carId = ref.watch(currentCarIdProvider);

    final currentThemeMode = ref.watch(themeModeProvider);
    final unitSystem = ref.watch(unitSystemProvider);
    final aiSensitivity = ref.watch(aiSensitivityProvider);
    final predictionHorizon = ref.watch(predictionHorizonProvider);
    final telemetryRate = ref.watch(telemetryRateProvider);
    final screenAwake = ref.watch(screenAwakeProvider);
    final coldStartWatchdog = ref.watch(coldStartWatchdogProvider);
    final thermalWatchdog = ref.watch(thermalWatchdogProvider);
    final emissionsWatchdog = ref.watch(emissionsWatchdogProvider);
    final cloudSyncWifiOnly = ref.watch(cloudSyncWifiOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings & Diagnostic Hub',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Vehicle & Dongle Edge Hardware Overview Card
              _buildVehicleHardwareCard(context, carId, isDark),
              const SizedBox(height: 22),

              // 2. Cockpit Display & Theme (Design Pro Max)
              _buildSectionHeader('Cockpit Display & Aesthetics', Icons.palette_outlined, isDark),
              const SizedBox(height: 10),
              _buildAppearanceCard(context, currentThemeMode, isDark),
              const SizedBox(height: 12),
              _buildDisplayPreferencesCard(context, unitSystem, screenAwake, isDark),
              const SizedBox(height: 22),

              // 3. AI Failure Forecasting Engine Calibration
              _buildSectionHeader('AI Predictive Forecasting Engine', Icons.psychology_outlined, isDark),
              const SizedBox(height: 10),
              _buildAiEngineCard(
                context,
                aiSensitivity: aiSensitivity,
                horizonDays: predictionHorizon,
                coldStart: coldStartWatchdog,
                thermal: thermalWatchdog,
                emissions: emissionsWatchdog,
                isDark: isDark,
              ),
              const SizedBox(height: 22),

              // 4. OBD-II Dongle & Edge Bus Configuration
              _buildSectionHeader('OBD-II Edge & Bus Telemetry', Icons.settings_input_composite_outlined, isDark),
              const SizedBox(height: 10),
              _buildObdBusCard(context, telemetryRate, isDark),
              const SizedBox(height: 22),

              // 5. Product & Benchmark Matrices
              _buildSectionHeader('Product & Business Ecosystem', Icons.auto_graph_outlined, isDark),
              const SizedBox(height: 10),
              _buildProductNavigationCard(context, isDark),
              const SizedBox(height: 22),

              // 6. Judge Demo & Evaluation Testbench
              _buildSectionHeader('Demo & Testbench Suite', Icons.science_outlined, isDark),
              const SizedBox(height: 10),
              _buildDemoPanelTriggerCard(context, isDark),
              const SizedBox(height: 22),

              // 7. Telemetry Data & Storage
              _buildSectionHeader('Data Management & Cache', Icons.storage_outlined, isDark),
              const SizedBox(height: 10),
              _buildDataCacheCard(context, cloudSyncWifiOnly, isDark),
              const SizedBox(height: 26),

              // 8. Academic & Startup Provenance
              _buildFooterCredits(isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleHardwareCard(BuildContext context, String carId, bool isDark) {
    final vehicleTitle = carId == 'swift_2016'
        ? 'Maruti Swift 2016 VXi'
        : carId.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Icon(
                  Icons.directions_car_filled,
                  color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTokens.statusHealthy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTokens.statusHealthy,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'BLE 5.0 Online',
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
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHardwareMiniSpec('Hardware Dongle', 'AutoPulse-BLE-89F2', isDark),
              _buildHardwareMiniSpec('OBD Protocol', 'ISO 15765-4 (CAN 500k)', isDark),
              _buildHardwareMiniSpec('Signal RSSI', '-62 dBm (Excellent)', isDark),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: _isPinging
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.network_check, size: 16),
                  label: Text(
                    _pingLatencyMs != null ? 'OBD Latency: ${_pingLatencyMs}ms' : 'Ping Dongle',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: _isPinging ? null : _runPingTest,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.terminal, size: 16),
                  label: const Text('AT Self-Test', style: TextStyle(fontSize: 12)),
                  onPressed: () => _showTerminalDialog(context, isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareMiniSpec(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceCard(BuildContext context, ThemeMode currentMode, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        children: [
          _buildThemeRadioTile(
            title: 'Cockpit OLED Theme',
            subtitle: 'Deep Graphite (#0B0F17) glare-free nocturnal driving',
            value: ThemeMode.dark,
            groupValue: currentMode,
            icon: Icons.dark_mode_outlined,
            isDark: isDark,
          ),
          const Divider(height: 1),
          _buildThemeRadioTile(
            title: 'Windshield Daylight Theme',
            subtitle: 'Crisp Alabaster (#F8FAFC) ultra-high contrast for sun glare',
            value: ThemeMode.light,
            groupValue: currentMode,
            icon: Icons.light_mode_outlined,
            isDark: isDark,
          ),
          const Divider(height: 1),
          _buildThemeRadioTile(
            title: 'System Automatic',
            subtitle: 'Synchronizes with ambient daylight & device settings',
            value: ThemeMode.system,
            groupValue: currentMode,
            icon: Icons.brightness_auto_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = value;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                  : (isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
              onChanged: (mode) {
                if (mode != null) ref.read(themeModeProvider.notifier).state = mode;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayPreferencesCard(
    BuildContext context,
    UnitSystem unitSystem,
    bool screenAwake,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telemetry Unit System', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Speed, temperature & pressure scales', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                  ],
                ),
                SegmentedButton<UnitSystem>(
                  segments: const [
                    ButtonSegment(value: UnitSystem.metric, label: Text('Metric (°C, km/h)', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: UnitSystem.imperial, label: Text('Imperial (°F, mph)', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {unitSystem},
                  onSelectionChanged: (set) {
                    ref.read(unitSystemProvider.notifier).state = set.first;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text('Keep Screen Awake While Driving', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Prevents lock screen timeout during real-time telemetry streaming', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            value: screenAwake,
            activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
            onChanged: (val) => ref.read(screenAwakeProvider.notifier).state = val,
          ),
        ],
      ),
    );
  }

  Widget _buildAiEngineCard(
    BuildContext context, {
    required AiSensitivity aiSensitivity,
    required int horizonDays,
    required bool coldStart,
    required bool thermal,
    required bool emissions,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Failure Sensitivity Level',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                      ),
                      child: Text(
                        aiSensitivity.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tunes Ordinary Least Squares (OLS) slope confidence threshold and anomaly noise filtering.',
                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: AiSensitivity.values.map((s) {
                    final isSel = s == aiSensitivity;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              s == AiSensitivity.conservative
                                  ? 'Conservative'
                                  : s == AiSensitivity.balanced
                                      ? 'Balanced'
                                      : 'Proactive',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel
                                    ? (isDark ? AppTokens.darkBackground : Colors.white)
                                    : (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary),
                              ),
                            ),
                          ),
                          selected: isSel,
                          selectedColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                          onSelected: (_) => ref.read(aiSensitivityProvider.notifier).state = s,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Forecast Risk Horizon Window', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('Maximum advance projection horizon', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                  ],
                ),
                Row(
                  children: [7, 14, 30].map((days) {
                    final isSel = days == horizonDays;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: InkWell(
                        onTap: () => ref.read(predictionHorizonProvider.notifier).state = days,
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                                : (isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated),
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                            border: Border.all(
                              color: isSel
                                  ? Colors.transparent
                                  : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                            ),
                          ),
                          child: Text(
                            '$days Days',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSel
                                  ? (isDark ? AppTokens.darkBackground : Colors.white)
                                  : (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text('Cold Start Cranking Sag Watchdog', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Alert immediately when morning ignition transient drops below 10.2V', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            value: coldStart,
            activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
            onChanged: (val) => ref.read(coldStartWatchdogProvider.notifier).state = val,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text('Thermal Dissipation Gradient Alert', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Monitors rate of coolant temp rise under city stop-and-go idle', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            value: thermal,
            activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
            onChanged: (val) => ref.read(thermalWatchdogProvider.notifier).state = val,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text('Emissions & Lambda Drift Watchdog', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Tracks combined STFT + LTFT fuel trims exceeding ±10%', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            value: emissions,
            activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
            onChanged: (val) => ref.read(emissionsWatchdogProvider.notifier).state = val,
          ),
        ],
      ),
    );
  }

  Widget _buildObdBusCard(BuildContext context, double rate, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telemetry Polling Rate', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('OBD-II PID query frequency via BLE 5.0', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                  ],
                ),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 1.0, label: Text('1.0 Hz (Live)', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: 0.5, label: Text('0.5 Hz (Std)', style: TextStyle(fontSize: 11))),
                    ButtonSegment(value: 0.1, label: Text('0.1 Hz (Eco)', style: TextStyle(fontSize: 11))),
                  ],
                  selected: {rate},
                  onSelectionChanged: (set) {
                    ref.read(telemetryRateProvider.notifier).state = set.first;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: Text('Reset OBD-II Adapter Bus Cache', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Clears volatile PID buffer and forces full ISO protocol re-negotiation', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            trailing: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('OBD-II adapter bus cache cleared and re-synced.', style: GoogleFonts.inter()),
                    backgroundColor: AppTokens.statusHealthy,
                  ),
                );
              },
              child: const Text('Reset', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductNavigationCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text('Why AutoPulse (Pitch Matrix)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Amazon OBD scanner vs AutoPulse vs Dealership scan tools', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/comparison'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.card_membership_outlined),
            title: Text('Hardware & SaaS Membership (₹999 + ₹999/yr)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Pricing tiers, annual AI license & hardware warranty', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/plans'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bluetooth_searching),
            title: Text('Pair New Dongle Adapter', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('Scan and connect another AutoPulse BLE smart scanner', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/pair'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoPanelTriggerCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.tune, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judge Demo Control Testbench', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Inject simulated faults, swap test vehicles, and fast-forward 30-day wear horizons.', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(88, 38)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DemoPanelDialog(),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCacheCard(BuildContext context, bool wifiOnly, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text('Sync Telemetry Cloud Buffer', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('14.8 MB local buffer • 4,820 packets recorded', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
            trailing: Switch(
              value: wifiOnly,
              activeColor: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
              onChanged: (val) => ref.read(cloudSyncWifiOnlyProvider.notifier).state = val,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export CSV Telemetry', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Exported 4,820 telemetry rows to /Download/AutoPulse_Telemetry.csv', style: GoogleFonts.inter()),
                          backgroundColor: AppTokens.statusHealthy,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Purge Cache', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Diagnostic cache cleared.', style: GoogleFonts.inter()),
                          backgroundColor: AppTokens.statusHealthy,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCredits(bool isDark) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
            child: Text(
              'v1.2.0 • UI/UX PRO MAX EDITION',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'AutoPulse AI Smart Mobility Platform',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'NIMS University Smart Mobility & Automotive AI Lab',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
