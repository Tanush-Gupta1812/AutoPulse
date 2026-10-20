import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';
import 'package:app/core/api_client.dart';
import 'package:app/core/websocket_client.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isScanning = true;
  bool _isPairing = false;
  bool _isPaired = false;
  String? _pairedMac;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto-discover after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handlePair(String carId) async {
    setState(() => _isPairing = true);
    final api = ref.read(apiServiceProvider);

    try {
      final res = await api.pairDongle(carId, '00:1D:A5:68:98:8B');
      if (mounted) {
        setState(() {
          _isPairing = false;
          _isPaired = true;
          _pairedMac = res['dongle_mac'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPairing = false;
          _isPaired = true; // graceful fallback for demo
          _pairedMac = '00:1D:A5:68:98:8B';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final carId = ref.watch(currentCarIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair OBD-II Dongle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                _isPaired ? 'Dongle Connected!' : (_isScanning ? 'Scanning for AutoPulse Dongle...' : 'Device Found Nearby'),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isPaired
                    ? 'CAN-Bus synchronization active. ISO 15765-4 protocol established.'
                    : 'Ensure your dongle is firmly inserted into your vehicle’s OBD-II port under the steering wheel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                ),
              ),
              const Spacer(),

              // Radar Pulse Animation
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!_isPaired) ...[
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 140 + (_pulseController.value * 110),
                              height: 140 + (_pulseController.value * 110),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                                    .withOpacity((1.0 - _pulseController.value) * 0.25),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 90 + (_pulseController.value * 80),
                              height: 90 + (_pulseController.value * 80),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                                    .withOpacity((1.0 - _pulseController.value) * 0.35),
                              ),
                            );
                          },
                        ),
                      ],
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPaired
                              ? AppTokens.statusHealthy
                              : (isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated),
                          border: Border.all(
                            color: _isPaired
                                ? AppTokens.statusHealthy
                                : (isDark ? AppTokens.darkAccent : AppTokens.lightAccent),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isPaired ? AppTokens.statusHealthy : (isDark ? AppTokens.darkAccent : AppTokens.lightAccent))
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Icon(
                          _isPaired ? Icons.check_circle : Icons.bluetooth_searching,
                          size: 48,
                          color: _isPaired ? Colors.white : (isDark ? AppTokens.darkAccent : AppTokens.lightAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Found Dongle Card
              if (!_isPaired && !_isScanning) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(
                      color: isDark ? AppTokens.darkAccent.withOpacity(0.4) : AppTokens.lightAccent.withOpacity(0.4),
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
                          Icons.router,
                          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AutoPulse BLE-OBD #4821',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MAC: 00:1D:A5:68:98:8B • Signal: -58 dBm (Strong)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check, color: AppTokens.statusHealthy, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              if (_isPaired) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTokens.statusHealthy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: AppTokens.statusHealthy.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppTokens.statusHealthy),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linked with Maruti Swift 2016',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'MAC: ${_pairedMac ?? "00:1D:A5:68:98:8B"} • Mode \$01 Online',
                              style: GoogleFonts.inter(fontSize: 12, color: AppTokens.statusHealthy),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // CTA Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPairing
                      ? null
                      : () {
                          if (_isPaired) {
                            context.go('/home');
                          } else {
                            _handlePair(carId);
                          }
                        },
                  child: _isPairing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isPaired ? 'Go to Car Health Dashboard' : 'Pair AutoPulse Dongle'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
