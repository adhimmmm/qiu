import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BookingView'), centerTitle: true),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext content) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih teknologi yang akan anda gunakan untuk melacak posisi di peta secara real-time',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // tombol 1: peta Gps
            ElevatedButton.icon(
              onPressed: controller.goToGpsMap, // Memanggil fungsi navigasi GPS
              icon: const Icon(Icons.satellite_alt, size: 28),
              label: const Text(
                'Peta & Data GPS (Akurasi Tinggi)',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Tombol 2: Peta Jaringan
            ElevatedButton.icon(
              onPressed: controller
                  .goToNetworkMap, // Memanggil fungsi navigasi Network
              icon: const Icon(Icons.wifi, size: 28),
              label: const Text(
                'Peta & Data Jaringan (Akurasi Rendah)',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
