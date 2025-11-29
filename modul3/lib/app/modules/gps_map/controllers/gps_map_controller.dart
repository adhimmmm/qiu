import 'dart:async';
import 'dart:io'; // Penting untuk cek Platform.isAndroid/isIOS
import 'package:flutter/material.dart'; // Untuk Get.snackbar dan Color
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

// --- MODEL DATA LOKASI (Dibutuhkan untuk Controller) ---
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
// --- AKHIR MODEL ---

class GpsMapController extends GetxController {
  
  // Data Lokasi yang diobservasi
  final currentGpsLocation = Rxn<LocationData>();
  final isLoading = true.obs;
  
  // Stream dan Pengaturan
  StreamSubscription<Position>? _gpsSubscription;
  final Duration _updateInterval = const Duration(seconds: 15);
  final String method = 'GPS (Akurasi Terbaik)';

  @override
  void onInit() {
    super.onInit();
    startLocationStream();
  }

  @override
  void onClose() {
    // Memastikan stream dihentikan saat Controller dimusnahkan
    _gpsSubscription?.cancel();
    super.onClose();
  }

  Future<void> startLocationStream() async {
    isLoading(true);
    
    // 1. Cek Izin dan Service Lokasi
    if (!await _handleLocationPermission()) {
        isLoading(false);
        return;
    }
    
    _gpsSubscription?.cancel();
    Get.snackbar('Status', 'Memulai pemantauan GPS...', backgroundColor: Colors.blue, colorText: Colors.white);

    // 2. Tentukan LocationSettings berdasarkan Platform
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
    
    if (Platform.isAndroid) {
      // Konfigurasi spesifik Android
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: _updateInterval,
        forceLocationManager: true, // Untuk prioritas GPS di Android
        // forceLocationManager: true membutuhkan izin ACCESS_FINE_LOCATION
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // Konfigurasi spesifik iOS/macOS
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: true,
      );
    }
    
    // 3. Mulai Streaming Posisi
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings, 
    ).listen((Position position) {
      currentGpsLocation.value = _mapPositionToLocationData(position);
      isLoading(false);
    });
  }

  // --- Fungsi Pembantu ---

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Layanan Lokasi (GPS) tidak aktif.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Izin lokasi ditolak.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi.',
          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
      return false;
    }
    return true;
  }

  LocationData _mapPositionToLocationData(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      // Ambil format jam (HH:MM:SS)
      timestamp: DateTime.now().toLocal().toIso8601String().substring(11, 19), 
      method: method,
      color: Colors.blue,
    );
  }
}