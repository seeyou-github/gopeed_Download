import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;

import '../../../../api/model/task.dart';
import '../../../../util/file_explorer.dart';
import '../../../../util/util.dart';
import '../../../routes/app_pages.dart';
import '../../../views/copy_button.dart';
import '../../../views/buid_task_list_view.dart';
import '../controllers/task_all_controller.dart';
import '../controllers/task_controller.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({Key? key}) : super(key: key);

  String? _displayTaskUrl(Task? task) {
    final rawUrl = task?.meta.req.rawUrl;
    if (rawUrl != null && rawUrl.isNotEmpty) {
      return rawUrl;
    }
    return task?.meta.req.url;
  }

  @override
  Widget build(BuildContext context) {
    final selectTask = controller.selectTask;
    final taskAllController = Get.find<TaskAllController>();

    return Scaffold(
      key: controller.scaffoldKey,
      body: BuildTaskListView(
        tasks: taskAllController.tasks,
        selectedTaskIds: taskAllController.selectedTaskIds,
        taskListController: taskAllController,
      ),
      endDrawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Obx(() => ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 65,
                    child: DrawerHeader(
                        child: Text(
                      'taskDetail'.tr,
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
                  ),
                  ListTile(
                      title: Text('taskName'.tr),
                      subtitle: buildTooltipSubtitle(selectTask.value?.name)),
                  ListTile(
                    title: Text('taskUrl'.tr),
                    subtitle: buildTooltipSubtitle(_displayTaskUrl(selectTask.value)),
                    trailing: CopyButton(_displayTaskUrl(selectTask.value)),
                  ),
                  ListTile(
                    title: Text('downloadPath'.tr),
                    subtitle:
                        buildTooltipSubtitle(selectTask.value?.explorerUrl),
                    trailing: IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: () {
                        selectTask.value?.explorer();
                      },
                    ),
                  ),
                ],
              )),
      ),
    );
  }

  Widget buildTooltipSubtitle(String? text) {
    final showText = text ?? "";
    return Tooltip(
      message: showText,
      child: Text(
        showText,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

extension TaskEnhance on Task {
  bool get isFolder {
    return meta.res?.name.isNotEmpty ?? false;
  }

  String get explorerUrl {
    return path.join(Util.safeDir(meta.opts.path), Util.safeDir(name));
  }

  Future<void> explorer() async {
    if (Util.isDesktop()) {
      await FileExplorer.openAndSelectFile(explorerUrl);
    } else {
      Get.rootDelegate.toNamed(Routes.TASK_FILES, parameters: {'id': id});
    }
  }

  Future<void> open() async {
    if (status != Status.done) {
      return;
    }

    if (isFolder) {
      await explorer();
    } else {
      await OpenFilex.open(explorerUrl);
    }
  }
}
