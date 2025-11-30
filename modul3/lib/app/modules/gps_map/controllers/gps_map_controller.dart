import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

// --- MODEL DATA LOKASI ---
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String timestamp;
  final String method;
  final Color color;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.method,
    required this.color,
  });
}

class GpsMapController extends GetxController {
  
  // Data Lokasi yang diobservasi
  final currentGpsLocation = Rxn<LocationData>();
  final isLoading = true.obs;
  
  // Fitur Tracking - Toggle untuk mengikuti lokasi
  final isTrackingEnabled = true.obs;
  
  // Stream dan Pengaturan
  StreamSubscription<Position>? _gpsSubscription;
  final Duration _updateInterval = const Duration(seconds: 15);
  final String method = 'GPS (Akurasi Terbaik)';
  
  // Flag untuk mencegah multiple initialization
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    // Delay untuk memastikan widget sudah ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isInitialized) {
        _isInitialized = true;
        startLocationStream();
      }
    });
  }

  @override
  void onClose() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _isInitialized = false;
    super.onClose();
  }

  // Toggle tracking on/off
  void toggleTracking() {
    isTrackingEnabled.value = !isTrackingEnabled.value;
    
    Get.snackbar(
      'Mode Tracking',
      isTrackingEnabled.value 
        ? 'Tracking diaktifkan - Peta akan mengikuti lokasi Anda' 
        : 'Tracking dinonaktifkan - Anda dapat menggeser peta secara manual',
      backgroundColor: isTrackingEnabled.value ? Colors.green : Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }

  Future<void> startLocationStream() async {
    // Cegah multiple calls
    if (!_isInitialized) return;
    
    try {
      isLoading(true);
      
      // Cancel subscription sebelumnya jika ada
      await _gpsSubscription?.cancel();
      _gpsSubscription = null;
      
      if (!await _handleLocationPermission()) {
        isLoading(false);
        return;
      }
      
      Get.snackbar(
        'Status', 
        'Memulai pemantauan GPS...', 
        backgroundColor: Colors.blue, 
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );

      LocationSettings locationSettings;
      
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high, // Ubah ke high untuk stabilitas
          distanceFilter: 5, // Ubah ke 5 meter untuk mencegah update terlalu sering
          intervalDuration: _updateInterval,
          forceLocationManager: false, // Ubah ke false untuk stabilitas
        );
      } else if (Platform.isIOS || Platform.isMacOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 5,
          pauseLocationUpdatesAutomatically: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );
      }
      
      // Mulai streaming dengan error handling
      _gpsSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings, 
      ).listen(
        (Position position) {
          if (_isInitialized) {
            currentGpsLocation.value = _mapPositionToLocationData(position);
            isLoading(false);
          }
        },
        onError: (error) {
          print('GPS Stream Error: $error');
          Get.snackbar(
            'Error GPS', 
            'Gagal mendapatkan lokasi. Coba aktifkan GPS.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
          );
          isLoading(false);
        },
        cancelOnError: false, // Jangan cancel stream saat error
      );
      
    } catch (e) {
      print('Error starting location stream: $e');
      Get.snackbar(
        'Error', 
        'Gagal memulai GPS: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
      isLoading(false);
    }
  }

  Future<bool> _handleLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Nonaktif', 
          'Aktifkan GPS di pengaturan perangkat Anda.',
          backgroundColor: Colors.red, 
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(10),
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak', 
            'Aplikasi memerlukan izin lokasi untuk berfungsi.',
            backgroundColor: Colors.red, 
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
          );
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Permanen Ditolak', 
          'Buka Pengaturan > Aplikasi > Izin untuk mengaktifkan lokasi.',
          backgroundColor: Colors.red, 
          colorText: Colors.white, 
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(10),
        );
        return false;
      }
      
      return true;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  LocationData _mapPositionToLocationData(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: DateTime.now().toLocal().toIso8601String().substring(11, 19), 
      method: method,
      color: Colors.blue,
    );
  }
}