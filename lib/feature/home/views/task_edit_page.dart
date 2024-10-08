import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/feature/home/model/task_model.dart';
import 'package:todo_app/feature/home/views/task_add_page.dart';
import 'package:todo_app/feature/home/providers/task_crud_provider.dart';
import 'package:todo_app/feature/profile/provider/language_provider.dart';
import 'package:todo_app/product/constants/project_colors.dart';
import 'package:todo_app/product/extensions/context_extensions.dart';
import 'package:todo_app/product/navigate/app_router.dart';
import 'package:todo_app/product/validators/validators.dart';
import 'package:todo_app/product/widgets/project_button.dart';
import 'package:todo_app/product/widgets/project_dropdown.dart';

import '../../../product/widgets/project_textfield.dart';

@RoutePage()
class TaskEditPage extends StatefulHookConsumerWidget {
  final TaskModel model;
  const TaskEditPage(this.model, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  @override
  Widget build(BuildContext context) {
    final formkey = useMemoized(() => GlobalKey<FormState>());
    final taskNotifier = ref.read(taskProvider.notifier);
    final newTask = useState(widget.model);
    final isLoading = useState(false);

    Future<void> submitForm() async {
      if (formkey.currentState!.validate()) {
        isLoading.value = true;
        try {
          await taskNotifier.updateTask(newTask.value);
          Fluttertoast.showToast(
              msg: "toastSuccessUpdateMessage".localize(ref),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: ProjectColors.grey,
              textColor: ProjectColors.white,
              fontSize: 16.0);
          context.mounted
              ? context.router.replaceAll([const TabbarRoute()])
              : null;
        } catch (error) {
          isLoading.value = false;
          Fluttertoast.showToast(
              msg: '${"toastErrorAddMessage".localize(ref)} $error',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: ProjectColors.black,
              textColor: ProjectColors.white,
              fontSize: 16.0);
        }
      }
    }

    return isLoading.value
        ? Container(
            color: ProjectColors.white,
            child: const Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("taskEditAppbarTitle".localize(ref)),
            ),
            body: Padding(
              padding: context.paddingHorizontalMedium,
              child: Form(
                key: formkey,
                child: ListView(
                  children: [
                    SizedBox(height: context.lowValue2),
                    _TextfieldTaskName(
                      newTask: newTask,
                      model: widget.model,
                    ),
                    SizedBox(height: context.lowValue2),
                    _TextfieldDescription(
                      model: widget.model,
                      newTask: newTask,
                    ),
                    SizedBox(height: context.lowValue2),
                    _DropdownImportanceScore(widget: widget, newTask: newTask),
                    SizedBox(height: context.lowValue2),
                    _DropdownChangeCategory(widget: widget, newTask: newTask),
                    SizedBox(height: context.lowValue2),
                    const _TaskIconListTitle(),
                    SizedBox(height: context.lowValue1),
                    _GridviewTaskIconList(newTask: newTask),
                    SizedBox(height: context.highValue),
                    ProjectButton(
                        text: "saveButtonText".localize(ref),
                        onPressed: submitForm),
                    SizedBox(height: context.mediumValue),
                  ],
                ),
              ),
            ),
          );
  }
}

class _TextfieldTaskName extends HookConsumerWidget {
  const _TextfieldTaskName({
    required this.newTask,
    required this.model,
  });

  final ValueNotifier<TaskModel> newTask;
  final TaskModel model;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final tfTitle = useTextEditingController(text: model.name);
    return ProjectTextfield(
      controller: tfTitle,
      keyBoardType: TextInputType.text,
      validator: Validators().validateTaskNameNotEmpty,
      label: Text("tfhintTaskName".localize(ref)),
      onChanged: (value) {
        newTask.value = newTask.value.copyWith(name: value);
      },
    );
  }
}

class _TextfieldDescription extends HookConsumerWidget {
  const _TextfieldDescription({
    required this.model,
    required this.newTask,
  });

  final ValueNotifier<TaskModel> newTask;
  final TaskModel model;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final descriptionLength = useState<int>(model.description.length);
    final tfDescription = useTextEditingController(text: model.description);
    return ProjectTextfield(
      controller: tfDescription,
      keyBoardType: TextInputType.multiline,
      validator: null,
      label: Text("tfhintTaskDes".localize(ref)),
      decoration: InputDecoration(
        counterText: "${descriptionLength.value}/200",
        alignLabelWithHint: true,
      ),
      maxLength: 200,
      maxLines: 3,
      onChanged: (value) {
        descriptionLength.value = value.length;
        newTask.value = newTask.value.copyWith(description: value);
      },
    );
  }
}

class _DropdownImportanceScore extends ConsumerWidget {
  final TaskEditPage widget;
  final ValueNotifier<TaskModel> newTask;

  const _DropdownImportanceScore({
    required this.widget,
    required this.newTask,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return ProjectDropdown(
      labelText: "dropdownImportance".localize(ref),
      value: widget.model.importance,
      itemValues: [1, 2, 3, 4, 5],
      onChanged: (value) {
        newTask.value = newTask.value.copyWith(importance: value);
      },
    );
  }
}

class _DropdownChangeCategory extends ConsumerWidget {
  final TaskEditPage widget;
  final ValueNotifier<TaskModel> newTask;

  const _DropdownChangeCategory({
    required this.widget,
    required this.newTask,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    String getCategoryName(int value) {
      switch (value) {
        case 1:
          return "categoryNameNew".localize(ref);
        case 2:
          return "categoryNameContinue".localize(ref);
        case 3:
          return "categoryNameFinished".localize(ref);
      }
      return "";
    }

    return ProjectDropdown(
      labelText: "dropdownCategory".localize(ref),
      value: widget.model.categoryId,
      itemValues: [1, 2, 3],
      itemBuilder: getCategoryName,
      onChanged: (value) {
        newTask.value = newTask.value.copyWith(categoryId: value);
        newTask.value =
            newTask.value.copyWith(category: getCategoryName(value ?? 1));
      },
    );
  }
}

class _TaskIconListTitle extends ConsumerWidget {
  const _TaskIconListTitle();

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Text("iconListTitle".localize(ref),
        style: context.textTheme().titleMedium);
  }
}

class _GridviewTaskIconList extends HookWidget {
  const _GridviewTaskIconList({
    required this.newTask,
  });

  final ValueNotifier<TaskModel> newTask;

  @override
  Widget build(BuildContext context) {
    late final List<IconData> icons;
    useEffect(() {
      icons = MyIconList().icons;
      return () {};
    });
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            newTask.value =
                newTask.value.copyWith(iconCodePoint: icons[index].codePoint);
          },
          child: Container(
            decoration: BoxDecoration(
              color: newTask.value.iconCodePoint == icons[index].codePoint
                  ? Colors.blue.withOpacity(0.4)
                  : Colors.transparent,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icons[index], size: 30),
          ),
        );
      },
    );
  }
}
