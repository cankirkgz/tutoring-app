import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/models/student_request_model.dart';
import 'package:tutoring/data/models/teacher_ad_model.dart';
import 'package:tutoring/data/models/user_model.dart';

class AdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var adsList = <dynamic>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _setupRoleListener();
  }

  void _setupRoleListener() {
    ever(_authController.rxUser, (UserModel? user) {
      if (user != null) {
        _fetchAdsBasedOnRole();
      } else {
        adsList.clear();
        _subscription?.cancel();
      }
    });
  }

  void _fetchAdsBasedOnRole() {
    _subscription?.cancel();

    String collectionName =
        _authController.isTeacher ? "student_requests" : "teacher_ads";

    _subscription =
        _firestore.collection(collectionName).snapshots().listen((snapshot) {
      adsList.value = snapshot.docs.map((doc) {
        return _authController.isTeacher
            ? StudentRequestModel.fromJson(doc.data(), doc.id)
            : TeacherAdModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
