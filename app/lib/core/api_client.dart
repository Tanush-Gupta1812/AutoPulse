import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  return dio;
});

class ApiService {
  final Dio dio;
  ApiService(this.dio);

  Future<List<dynamic>> getCars() async {
    final response = await dio.get('/api/cars');
    return response.data;
  }

  Future<Map<String, dynamic>> getCar(String carId) async {
    final response = await dio.get('/api/cars/$carId');
    return response.data;
  }

  Future<Map<String, dynamic>> pairDongle(String carId, String mac) async {
    final response = await dio.post(
      '/api/cars/$carId/pair',
      data: {'dongle_mac': mac},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getVehicleHealth(String carId) async {
    final response = await dio.get('/api/cars/$carId/health');
    return response.data;
  }

  Future<Map<String, dynamic>> getComponentDetail(String carId, String component) async {
    final response = await dio.get('/api/cars/$carId/components/$component');
    return response.data;
  }

  Future<Map<String, dynamic>> getLatestTelemetry(String carId) async {
    final response = await dio.get('/api/cars/$carId/telemetry/latest');
    return response.data;
  }

  Future<List<dynamic>> getTelemetryHistory(String carId) async {
    final response = await dio.get('/api/cars/$carId/telemetry/history');
    return response.data;
  }

  Future<List<dynamic>> getAlerts(String carId) async {
    final response = await dio.get('/api/cars/$carId/alerts');
    return response.data;
  }

  Future<void> markAlertRead(String carId, int alertId) async {
    await dio.post('/api/cars/$carId/alerts/$alertId/read');
  }

  Future<List<dynamic>> getGarages() async {
    final response = await dio.get('/api/garages');
    return response.data;
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> booking) async {
    final response = await dio.post('/api/service-bookings', data: booking);
    return response.data;
  }

  Future<Map<String, dynamic>> getPlans() async {
    final response = await dio.get('/api/plans');
    return response.data;
  }

  Future<Map<String, dynamic>> getFleetSummary() async {
    final response = await dio.get('/api/fleet');
    return response.data;
  }

  Future<Map<String, dynamic>> injectFault(String carId, String scenario) async {
    final response = await dio.post(
      '/api/demo/inject-fault',
      data: {'car_id': carId, 'scenario': scenario},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> fastForward(String carId, double days) async {
    final response = await dio.post(
      '/api/demo/fast-forward',
      data: {'car_id': carId, 'days': days},
    );
    return response.data;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
