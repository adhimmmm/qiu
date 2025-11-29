import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/gps_map_controller.dart';

class GpsMapView extends GetView<GpsMapController> {
  const GpsMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta & Data GPS 🛰️'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            return IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.startLocationStream,
              icon: Icon(
                Icons.refresh,
                color: controller.isLoading.value
                    ? Colors.blue.shade100
                    : Colors.white,
              ),
              tooltip: 'Muat Ulang Lokasi',
            );
          }),
        ],
      ),
      body: Obx(() {
        final data = controller.currentGpsLocation.value;

        if (controller.isLoading.value && data == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Memulai pemantauan lokasi GPS...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMapContainer(data),
              const SizedBox(height: 20),
              _buildDataCard(context, data),
              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  // PETA AKTIF (Flutter Map)
  // -------------------------------------------------------------------------
  Widget _buildMapContainer(LocationData? data) {
    if (data == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text("Menunggu data GPS pertama..."),
      );
    }

    final point = LatLng(data.latitude, data.longitude);

    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.gpsapp',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: point,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // CARD INFORMASI DATA GPS
  // -------------------------------------------------------------------------
  Widget _buildDataCard(BuildContext context, LocationData? data) {
    final bodyStyle = TextStyle(color: Get.theme.textTheme.bodyLarge?.color);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Lokasi',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const Divider(),
          if (data == null)
            Text(
              'Memuat data...',
              style: bodyStyle.copyWith(fontStyle: FontStyle.italic),
            )
          else ...[
            _buildDataRow('Latitude', data.latitude.toStringAsFixed(6)),
            _buildDataRow('Longitude', data.longitude.toStringAsFixed(6)),
            _buildDataRow(
              'Accuracy (m)',
              data.accuracy.toStringAsFixed(2),
              isImportant: true,
              valueColor: data.accuracy < 10
                  ? Colors.green
                  : (data.accuracy < 50 ? Colors.orange : Colors.red),
            ),
            _buildDataRow('Timestamp', data.timestamp),
            const SizedBox(height: 8),
            Text(
              'Diperbarui setiap 15 detik.',
              style: bodyStyle.copyWith(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {bool isImportant = false, Color? valueColor}) {
    final bodyColor = Get.theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
