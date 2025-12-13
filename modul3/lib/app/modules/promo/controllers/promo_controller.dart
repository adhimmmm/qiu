import 'package:get/get.dart';

class PromoController extends GetxController {
  late final Map<String, dynamic> promoData;

  @override
  void onInit() {
    super.onInit();
    promoData = Get.arguments ?? {};
  }
}
