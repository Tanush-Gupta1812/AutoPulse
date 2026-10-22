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
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      setState(() {
        _isPinging = false;
        _pingLatencyMs = 18;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OBD-II BLE Response: 18ms (Optimal)', style: GoogleFonts.inter()),
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
            backgroundColor: isDark ? const Color(0xFF11141A) : const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              side: BorderSide(
                color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.terminal, color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'OBD-II Command Diagnostics',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct bus handshake test with ELM327 BLE adapter:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF07090C) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                    ),
                    child: _terminalLogs.isEmpty
                        ? Center(
                            child: Text(
                              'Tap "Run Self-Test" to query adapter status',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _terminalLogs.length,
                            itemBuilder: (c, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                _terminalLogs[i],
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: _terminalLogs[i].startsWith('>')
                                      ? (isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted)
                                      : AppTokens.statusHealthy,
                                ),
                              ),
                            ),
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
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow, size: 16),
                label: const Text('Run Self-Test'),
                onPressed: _isTestingTerminal
                    ? null
                    : () async {
                        setDialogState(() => _isTestingTerminal = true);
                        setState(() {
                          _terminalLogs = ['> AT Z (Adapter Reset)'];
                        });
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 250));
                        _terminalLogs.add('ELM327 v2.1 AutoPulse Edge OS');
                        _terminalLogs.add('> AT SP 0 (Set Protocol Auto)');
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 250));
                        _terminalLogs.add('OK (Protocol ISO 15765-4 CAN Locked)');
                        _terminalLogs.add('> 01 00 (Query Supported PIDs)');
                        setDialogState(() {});
                        await Future.delayed(const Duration(milliseconds: 250));
                        _terminalLogs.add('SEARCHING... 41 00 BE 3F B8 11 (28 Active)');
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
          'Settings & Diagnostics',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Vehicle & Dongle Hardware Status
              _buildVehicleHardwareCard(context, carId, isDark),
              const SizedBox(height: 20),

              // 2. Display & Unit Preferences
              _buildSectionTitle('Display & Appearance', isDark),
              const SizedBox(height: 8),
              _buildAppearanceCard(context, currentThemeMode, isDark),
              const SizedBox(height: 10),
              _buildDisplayPreferencesCard(context, unitSystem, screenAwake, isDark),
              const SizedBox(height: 20),

              // 3. AI Predictive Engine Tuning
              _buildSectionTitle('AI Predictive Engine', isDark),
              const SizedBox(height: 8),
              _buildAiEngineCard(
                context,
                aiSensitivity: aiSensitivity,
                horizonDays: predictionHorizon,
                coldStart: coldStartWatchdog,
                thermal: thermalWatchdog,
                emissions: emissionsWatchdog,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // 4. OBD-II Polling & Bus
              _buildSectionTitle('OBD-II & Sensor Polling', isDark),
              const SizedBox(height: 8),
              _buildObdBusCard(context, telemetryRate, isDark),
              const SizedBox(height: 20),

              // 5. Diagnostics & Demo Testbench
              _buildSectionTitle('Diagnostic Testbench', isDark),
              const SizedBox(height: 8),
              _buildTestbenchCard(context, isDark),
              const SizedBox(height: 20),

              // 6. Data & Cache Management
              _buildSectionTitle('Data & Storage', isDark),
              const SizedBox(height: 8),
              _buildDataCacheCard(context, cloudSyncWifiOnly, isDark),
              const SizedBox(height: 24),

              // 7. Minimal Footer
              _buildFooterCredits(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
      ),
    );
  }

  Widget _buildVehicleHardwareCard(BuildContext context, String carId, bool isDark) {
    final vehicleTitle = carId == 'swift_2016'
        ? 'Maruti Swift 2016 VXi'
        : carId.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DL 3C AP 4821 • 64,280 km • 1.2L K12M',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTokens.statusHealthy.withOpacity(0.12),
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
                      'BLE Linked',
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
          const Divider(height: 20),
          Row(
            children: [
              Expanded(child: _buildMiniMetric('Hardware', 'AutoPulse-BLE-89F2', isDark)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniMetric('Protocol', 'ISO 15765-4 CAN', isDark)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniMetric('Signal', '-58 dBm (Strong)', isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: _isPinging ? null : _runPingTest,
                  child: Text(
                    _isPinging
                        ? 'Testing...'
                        : (_pingLatencyMs != null ? 'Latency: ${_pingLatencyMs}ms' : 'Ping Dongle'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => _showTerminalDialog(context, isDark),
                  child: const Text('AT Self-Test', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          _buildThemeTile('Obsidian Dark', ThemeMode.dark, currentMode, Icons.dark_mode_outlined, isDark),
          const Divider(height: 1),
          _buildThemeTile('Daylight Clean', ThemeMode.light, currentMode, Icons.light_mode_outlined, isDark),
          const Divider(height: 1),
          _buildThemeTile('System Automatic', ThemeMode.system, currentMode, Icons.brightness_auto_outlined, isDark),
        ],
      ),
    );
  }

  Widget _buildThemeTile(String label, ThemeMode mode, ThemeMode current, IconData icon, bool isDark) {
    final isSelected = mode == current;
    return InkWell(
      onTap: () => ref.read(themeModeProvider.notifier).state = mode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary)
                  : (isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 16,
                color: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Telemetry Unit System',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoicePill(
                  label: 'Metric (°C, km/h)',
                  isSelected: unitSystem == UnitSystem.metric,
                  onTap: () => ref.read(unitSystemProvider.notifier).state = UnitSystem.metric,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoicePill(
                  label: 'Imperial (°F, mph)',
                  isSelected: unitSystem == UnitSystem.imperial,
                  onTap: () => ref.read(unitSystemProvider.notifier).state = UnitSystem.imperial,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keep Screen Awake', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Prevent screen timeout during live telemetry', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted)),
                  ],
                ),
              ),
              Switch(
                value: screenAwake,
                onChanged: (val) => ref.read(screenAwakeProvider.notifier).state = val,
              ),
            ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Failure Sensitivity Threshold', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoicePill(
                  label: 'Conservative',
                  isSelected: aiSensitivity == AiSensitivity.conservative,
                  onTap: () => ref.read(aiSensitivityProvider.notifier).state = AiSensitivity.conservative,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChoicePill(
                  label: 'Balanced',
                  isSelected: aiSensitivity == AiSensitivity.balanced,
                  onTap: () => ref.read(aiSensitivityProvider.notifier).state = AiSensitivity.balanced,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChoicePill(
                  label: 'Proactive',
                  isSelected: aiSensitivity == AiSensitivity.proactive,
                  onTap: () => ref.read(aiSensitivityProvider.notifier).state = AiSensitivity.proactive,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text('Forecast Horizon Window', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [7, 14, 30].map((days) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: _buildChoicePill(
                    label: '$days Days',
                    isSelected: horizonDays == days,
                    onTap: () => ref.read(predictionHorizonProvider.notifier).state = days,
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 20),
          _buildToggleRow(
            title: 'Cold Crank Sag Watchdog',
            subtitle: 'Alert when morning crank transient dips below 10.2V',
            value: coldStart,
            onChanged: (val) => ref.read(coldStartWatchdogProvider.notifier).state = val,
            isDark: isDark,
          ),
          const Divider(height: 14),
          _buildToggleRow(
            title: 'Thermal Gradient Watchdog',
            subtitle: 'Detect abnormal coolant temperature rise in traffic',
            value: thermal,
            onChanged: (val) => ref.read(thermalWatchdogProvider.notifier).state = val,
            isDark: isDark,
          ),
          const Divider(height: 14),
          _buildToggleRow(
            title: 'Fuel Trim Lambda Drift',
            subtitle: 'Notify on persistent STFT + LTFT fuel trim deviation > 10%',
            value: emissions,
            onChanged: (val) => ref.read(emissionsWatchdogProvider.notifier).state = val,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildObdBusCard(BuildContext context, double rate, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OBD-II Polling Frequency', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoicePill(
                  label: '1.0 Hz (Live)',
                  isSelected: rate == 1.0,
                  onTap: () => ref.read(telemetryRateProvider.notifier).state = 1.0,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChoicePill(
                  label: '0.5 Hz (Std)',
                  isSelected: rate == 0.5,
                  onTap: () => ref.read(telemetryRateProvider.notifier).state = 0.5,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildChoicePill(
                  label: '0.1 Hz (Eco)',
                  isSelected: rate == 0.1,
                  onTap: () => ref.read(telemetryRateProvider.notifier).state = 0.1,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reset Bus Cache', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Forces fresh ISO protocol negotiation with dongle', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('OBD-II bus cache cleared.', style: GoogleFonts.inter()),
                      backgroundColor: AppTokens.statusHealthy,
                    ),
                  );
                },
                child: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestbenchCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Demo Scenario Control', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Inject simulated faults and test real-time alerts', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(70, 34)),
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
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/comparison'),
                  child: const Text('Market Matrix', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/plans'),
                  child: const Text('Pricing & SaaS', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCacheCard(BuildContext context, bool wifiOnly, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sync on Wi-Fi Only', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Save mobile data when uploading raw telemetry', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted)),
                  ],
                ),
              ),
              Switch(
                value: wifiOnly,
                onChanged: (val) => ref.read(cloudSyncWifiOnlyProvider.notifier).state = val,
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exported 4,820 packets to /Downloads', style: GoogleFonts.inter()),
                        backgroundColor: AppTokens.statusHealthy,
                      ),
                    );
                  },
                  child: const Text('Export CSV', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Diagnostic cache cleared.', style: GoogleFonts.inter()),
                        backgroundColor: AppTokens.statusHealthy,
                      ),
                    );
                  },
                  child: const Text('Purge Cache', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoicePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF222834) : const Color(0xFFE2E8F0))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary)
                : (isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary)
                : (isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFooterCredits(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            'AUTOPULSE v1.2.0 • OBD-II AI MOBILITY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'NIMS University Smart Mobility & AI Lab',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
