import 'package:get/get.dart';
import '../../../data/models/laundry_service_model.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DioService _dioService = DioService();

  final isLoading = false.obs;
  final services = <LaundryService>[].obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('🏠 Home Controller initialized');
    fetchServices();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  //fungsi logout
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
    }catch (e) {
      print('Error during logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _dioService.fetchServices();
      
      if (result['success']) {
        services.value = result['data'];
        print('✅ Loaded ${services.length} services');
      } else {
        errorMessage.value = result['error'];
        Get.snackbar(
          'Error',
          'Failed to load services: ${result['error']}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}