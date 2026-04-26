import '../../../../api/model/task.dart';
import 'task_list_controller.dart';

class TaskAllController extends TaskListController {
  TaskAllController()
      : super([], (a, b) {
          if (a.status == Status.running && b.status != Status.running) {
            return -1;
          } else if (a.status != Status.running && b.status == Status.running) {
            return 1;
          } else {
            return b.updatedAt.compareTo(a.updatedAt);
          }
        });
}
