import 'package:dio/dio.dart';
import '../models/laundry_service_model.dart';

class DioService {
  static const String baseUrl =
      'https://6915596b84e8bd126af996e3.mockapi.io';

  late Dio _dio;

  DioService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🔵 [DIO] Request: ${options.method} ${options.uri}');
          print('🔵 [DIO] Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('🔵 [DIO] Response: ${response.statusCode}');
          print('🔵 [DIO] Data Size: ${response.data.toString().length} bytes');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('🔴 [DIO] Error Type: ${error.type}');
          print('🔴 [DIO] Error Message: ${error.message}');
          print('🔴 [DIO] Status Code: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );
  }

  // Fetch all services with Dio
  Future<Map<String, dynamic>> fetchServices() async {
    final stopwatch = Stopwatch()..start();

    try {
      print('🔵 [DIO] Starting request...');

      final response = await _dio.get('/services');

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      print('🔵 [DIO] Response Time: ${duration}ms');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        final services = jsonData
            .map((json) => LaundryService.fromJson(json))
            .toList();

        print('🔵 [DIO] Success: ${services.length} services loaded');

        return {
          'success': true,
          'data': services,
          'duration': duration,
          'statusCode': response.statusCode,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'duration': duration,
          'statusCode': response.statusCode,
          'error': 'HTTP Error ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      stopwatch.stop();

      String errorMsg = '';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMsg = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMsg = 'Bad response: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMsg = 'Request cancelled';
          break;
        default:
          errorMsg = 'Network error: ${e.message}';
      }

      print('🔴 [DIO] DioException: $errorMsg');

      return {
        'success': false,
        'data': null,
        'duration': stopwatch.elapsedMilliseconds,
        'statusCode': e.response?.statusCode ?? 0,
        'error': errorMsg,
      };
    } catch (e) {
      stopwatch.stop();
      print('🔴 [DIO] Unknown error: $e');

      return {
        'success': false,
        'data': null,
        'duration': stopwatch.elapsedMilliseconds,
        'statusCode': 0,
        'error': e.toString(),
      };
    }
  }

  // Simulate error scenario
  Future<Map<String, dynamic>> fetchWithError() async {
    final stopwatch = Stopwatch()..start();

    try {
      print('🔵 [DIO] Testing error handling...');

      final response = await _dio.get('/invalid-endpoint');

      stopwatch.stop();

      return {
        'success': true,
        'data': response.data,
        'duration': stopwatch.elapsedMilliseconds,
        'statusCode': response.statusCode,
        'error': null,
      };
    } on DioException catch (e) {
      stopwatch.stop();

      print('🔴 [DIO] Interceptor caught error automatically!');
      print('🔴 [DIO] Error type: ${e.type}');

      return {
        'success': false,
        'data': null,
        'duration': stopwatch.elapsedMilliseconds,
        'statusCode': e.response?.statusCode ?? 0,
        'error': 'Dio Interceptor: ${e.type.toString()}',
      };
    }
  }

  // Chained request for async demo
  Future<Map<String, dynamic>> fetchServiceById(String id) async {
    try {
      print('🔵 [DIO] Fetching service with ID: $id');

      final response = await _dio.get('/services/$id');

      if (response.statusCode == 200) {
        final service = LaundryService.fromJson(response.data);
        return {'success': true, 'data': service, 'error': null};
      } else {
        return {'success': false, 'data': null, 'error': 'Service not found'};
      }
    } catch (e) {
      return {'success': false, 'data': null, 'error': e.toString()};
    }
  }
}
