import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:app/core/config.dart';

final currentCarIdProvider = StateProvider<String>((ref) => AppConfig.defaultCarId);

final telemetryWebSocketProvider = StreamProvider.autoDispose.family<Map<String, dynamic>, String>((ref, carId) async* {
  final uri = Uri.parse('${AppConfig.wsBaseUrl}/ws/telemetry/$carId');
  WebSocketChannel? channel;

  try {
    channel = WebSocketChannel.connect(uri);
    await for (final message in channel.stream) {
      if (message is String) {
        final data = jsonDecode(message) as Map<String, dynamic>;
        yield data;
      }
    }
  } catch (e) {
    // If backend websocket is offline during offline development, yield synthetic fallback
    yield {
      'car_id': carId,
      'timestamp': DateTime.now().toIso8601String(),
      'rpm': 780.0,
      'speed': 0.0,
      'coolant_temp': 92.0,
      'engine_load': 22.0,
      'battery_voltage': 11.8,
      'intake_air_temp': 34.0,
      'short_fuel_trim': 0.8,
      'long_fuel_trim': 1.2,
      'maf': 2.4,
      'throttle_pos': 12.0,
      'o2_voltage': 0.45,
      'engine_on': true,
      'simulated_day': 12.0
    };
  } finally {
    channel?.sink.close();
  }
});
