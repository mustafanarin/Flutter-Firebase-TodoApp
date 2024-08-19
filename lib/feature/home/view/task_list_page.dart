import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/feature/home/viewmodel/task_crud_viewmodel.dart';
import 'package:todo_app/product/constants/category_id_enum.dart';
import 'package:todo_app/product/extensions/context_extensions.dart';
import 'package:todo_app/product/navigate/app_router.dart';

@RoutePage()
class TaskListPage extends HookConsumerWidget {
  final int categoryId;
  final CategoryId category;
  final String categoryName;
  TaskListPage(this.categoryId, this.category, this.categoryName, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Color> cardColor = CardColor().colorByCategory(category);
    final taskNotifier = ref.read(taskProvider.notifier);
    final taskState = ref.watch(taskProvider);
    final shortBy = ref.read(taskProvider.notifier);
    useEffect(() {
      Future.microtask(() => taskNotifier.loadTasks(categoryId));
      return null;
    }, [categoryId]);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu_outlined),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                onTap: () => shortBy.sortTasks(SortType.name),
                child: const Text('Sort by name'),
              ),
              PopupMenuItem<String>(
                onTap: () => shortBy.sortTasks(SortType.importance),
                child: const Text('Sort by importance'),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: context.paddingHorizontalLow,
        child: taskState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : taskState.tasks.isEmpty
                ?  Center(
                    child: Text("No ${categoryName.toLowerCase()} missions yet.",
                        style: TextStyle(color: Colors.black)))
                : ListView.builder(
                    itemCount: taskState.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskState.tasks[index];
                      return Slidable(
                        key: ValueKey(index),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                taskNotifier.deleteTask(task);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Sil',
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: context.paddingAllLow1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: cardColor),
                            ),
                            child: ListTile(
                              onTap: () => context.pushRoute(TaskDetailRoute(
                                  model: task, category: category)),
                              title: Text(
                                task.name,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              subtitle: Row(
                                children: [
                                  RatingBar.builder(
                                    ignoreGestures: true,
                                    itemSize: 20,
                                    initialRating: task.importance.toDouble(),
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double value) {},
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${task.createdAt}",
                                    style: TextStyle(
                                        color: Colors.grey[300], fontSize: 15),
                                  )
                                ],
                              ),
                              leading: Icon(
                                IconData(task.iconCodePoint,
                                    fontFamily: 'MaterialIcons'),
                                color: Colors.white,
                              ),
                              trailing: Icon(Icons.arrow_outward,
                                  color: Colors.white.withOpacity(0.6)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
