import 'package:get/get.dart';

import '../controllers/task_all_controller.dart';
import '../controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(
      () => TaskController(),
    );
    Get.lazyPut<TaskAllController>(
      () => TaskAllController(),
    );
  }
}
