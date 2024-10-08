import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/feature/home/providers/home_provider.dart';
import 'package:todo_app/feature/profile/provider/language_provider.dart';
import 'package:todo_app/product/constants/category_id_enum.dart';
import 'package:todo_app/product/constants/project_colors.dart';
import 'package:todo_app/product/extensions/context_extensions.dart';
import 'package:todo_app/product/navigate/app_router.dart';
import 'package:todo_app/product/widgets/app_name_text.dart';

@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(taskCountProvider.notifier).updateTaskCounts();
  }

  @override
  Widget build(BuildContext context) {
    final taskCountState = ref.watch(taskCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const _AppbarTitle(),
      ),
      body: taskCountState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CardWidget(
                  title: "newTaskCard".localize(ref),
                  color: ProjectColors.green600,
                  categoryId: CategoryId.newTask.value,
                  category: CategoryId.newTask,
                ),
                _CardWidget(
                  title: "continuesTaskCard".localize(ref),
                  color: ProjectColors.blue600,
                  categoryId: CategoryId.continueTask.value,
                  category: CategoryId.continueTask,
                ),
                _CardWidget(
                  title: "finishedTaskCard".localize(ref),
                  color: ProjectColors.red600,
                  categoryId: CategoryId.finishTask.value,
                  category: CategoryId.finishTask,
                ),
              ],
            ),
    );
  }
}

class _AppbarTitle extends StatelessWidget {
  const _AppbarTitle();

  @override
  Widget build(BuildContext context) {
    return AppNameText();
  }
}

class _CardWidget extends ConsumerWidget {
  final String title;
  final Color color;
  final int categoryId;
  final CategoryId category;

  const _CardWidget({
    required this.title,
    required this.color,
    required this.categoryId,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskCount = ref.watch(taskCountProvider).taskCounts[categoryId] ?? 0;

    final List<Color> cardColor = CardColor().colorByCategory(category);

    return Padding(
      padding: context.paddingHorizontalHeigh,
      child: GestureDetector(
        onTap: () => context.pushRoute(TaskListRoute(
            categoryId: categoryId, category: category, categoryName: title)),
        child: Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: cardColor,
              ),
            ),
            width: context.dynamicWidht(1),
            height: context.dynamicHeight(0.22),
            child: Center(
              child: Text(
                '$title ($taskCount)',
                style: context
                    .textTheme()
                    .titleMedium
                    ?.copyWith(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
