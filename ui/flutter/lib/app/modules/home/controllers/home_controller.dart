import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  DateTime? _lastBackPressedAt;

  bool shouldExitOnBack() {
    final now = DateTime.now();
    if (_lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > const Duration(seconds: 2)) {
      _lastBackPressedAt = now;
      return false;
    }
    _lastBackPressedAt = null;
    return true;
  }
}
