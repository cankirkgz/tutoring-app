import 'package:get/get.dart';
import 'package:tutoring/config/routes.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepo = Get.find();

  var user = Get.find<AuthController>().user;

  Future<void> completeProfile() async {
    try {
      await _userRepo.updateUserProfile(user!);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Hata', 'Profil güncellenemedi: ${e.toString()}');
    }
  }
}
