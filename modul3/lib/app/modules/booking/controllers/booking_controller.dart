import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class BookingController extends GetxController {
  void goToGpsMap() {
    Get.toNamed(Routes.GPS_MAP);
  }

  // Fungsi navigasi ke halaman Peta Jaringan
  void goToNetworkMap() {
    Get.toNamed(Routes.NETWORK_MAP);
    
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
