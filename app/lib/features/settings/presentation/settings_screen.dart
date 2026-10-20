import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/features/settings/presentation/demo_panel_dialog.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode Selector
              Text('Appearance', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Theme (Cockpit OLED Glare-Free)'),
                      value: ThemeMode.dark,
                      groupValue: currentThemeMode,
                      onChanged: (mode) {
                        if (mode != null) ref.read(themeModeProvider.notifier).state = mode;
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Theme (Daylight Windshield High-Contrast)'),
                      value: ThemeMode.light,
                      groupValue: currentThemeMode,
                      onChanged: (mode) {
                        if (mode != null) ref.read(themeModeProvider.notifier).state = mode;
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      value: ThemeMode.system,
                      groupValue: currentThemeMode,
                      onChanged: (mode) {
                        if (mode != null) ref.read(themeModeProvider.notifier).state = mode;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Links
              Text('Product & Business', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.compare_arrows),
                      title: const Text('Why AutoPulse (Pitch Matrix)'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/comparison'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.card_membership),
                      title: const Text('Membership & Plans (₹999 + ₹999/yr)'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/plans'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bluetooth_searching),
                      title: const Text('Dongle Bluetooth Pairing'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/pair'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demo Presentation Controls
              Text('Judge & Demo Controls', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Secret Demo Control Panel', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('Inject faults, switch cars, and fast-forward simulated days.', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
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
              ),
              const SizedBox(height: 24),

              // About & Startup Credits
              Center(
                child: Column(
                  children: [
                    Text(
                      'AutoPulse v1.0.0 (Demo Prototype)',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIMS University • Smart Mobility & Automotive AI',
                      style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
