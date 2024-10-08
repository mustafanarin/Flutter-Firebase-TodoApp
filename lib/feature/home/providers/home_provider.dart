import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../product/constants/category_id_enum.dart';
import '../../../service/task_service.dart';
import '../states/task_count_state.dart';

// Task count state notifier provider
final taskCountProvider =
    AutoDisposeNotifierProvider<TaskCountProvider, TaskCountState>(
      () => TaskCountProvider.new(TaskService()));

class TaskCountProvider extends AutoDisposeNotifier<TaskCountState> {
  final TaskService _taskService;

  TaskCountProvider(this._taskService);

  @override
  TaskCountState build() {
    return TaskCountState({}, true);
  }

  Future<void> updateTaskCounts() async {
    try {
      final newTasks = await _taskService.getTasks(CategoryId.newTask.value);
      final continueTasks =
          await _taskService.getTasks(CategoryId.continueTask.value);
      final finishedTasks =
          await _taskService.getTasks(CategoryId.finishTask.value);

      state = state.copyWith(
        taskCounts: {
          CategoryId.newTask.value: newTasks.length,
          CategoryId.continueTask.value: continueTasks.length,
          CategoryId.finishTask.value: finishedTasks.length,
        },
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("The number of tasks did not arrive: ${e.toString()}");
    }
  }
}
