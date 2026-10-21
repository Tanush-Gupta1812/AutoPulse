import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

enum UnitSystem { metric, imperial }

final unitSystemProvider = StateProvider<UnitSystem>((ref) => UnitSystem.metric);

enum AiSensitivity { conservative, balanced, proactive }

final aiSensitivityProvider = StateProvider<AiSensitivity>((ref) => AiSensitivity.balanced);

final predictionHorizonProvider = StateProvider<int>((ref) => 14); // 7, 14, 30 days

final telemetryRateProvider = StateProvider<double>((ref) => 1.0); // 1.0 Hz, 0.5 Hz, 0.1 Hz

final screenAwakeProvider = StateProvider<bool>((ref) => true);

final coldStartWatchdogProvider = StateProvider<bool>((ref) => true);

final thermalWatchdogProvider = StateProvider<bool>((ref) => true);

final emissionsWatchdogProvider = StateProvider<bool>((ref) => true);

final cloudSyncWifiOnlyProvider = StateProvider<bool>((ref) => false);
