import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_app/feature/profile/provider/language_provider.dart';
import 'package:todo_app/product/constants/project_colors.dart';
import 'package:todo_app/product/extensions/assets/png_extension.dart';
import 'package:todo_app/product/extensions/context_extensions.dart';
import 'package:todo_app/product/navigate/app_router.dart';
import 'package:todo_app/product/widgets/app_name_text.dart';
import 'package:todo_app/product/widgets/project_button.dart';
import 'package:todo_app/product/widgets/transparent_button.dart';

@RoutePage()
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const _ImagePage(),
          const _CustomContainerAndAppName(),
          Expanded(
            flex: 50,
            child: Column(
              children: [
                const Spacer(flex: 5),
                const _DescriptionText(),
                const Spacer(flex: 10),
                Padding(
                  padding: context.paddingHorizontalHeigh,
                  child: ProjectButton(
                    text: 'loginButton'.localize(ref),
                    onPressed: () {
                      context.pushRoute(const LoginRoute());
                    },
                  ),
                ),
                const Spacer(flex: 8),
                Padding(
                  padding: context.paddingHorizontalHeigh,
                  child: TransparentButton(
                    text: 'registerButton'.localize(ref),
                    onPressed: () {
                      context.pushRoute(const RegisterRoute());
                    },
                  ),
                ),
                const Spacer(flex: 15)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ImagePage extends StatelessWidget {
  const _ImagePage();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 50,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          PngItems.woman_shopping.path(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _CustomContainerAndAppName extends StatelessWidget {
  const _CustomContainerAndAppName();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ProjectColors.iris, width: 1.5),
      ),
      width: context.dynamicWidht(1),
      height: context.dynamicHeight(0.1),
      child: Center(child: AppNameText()),
    );
  }
}

class _DescriptionText extends ConsumerWidget {
  const _DescriptionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: context.paddingHorizontalMedium,
      child: Text(
        'welcomeDescription'.localize(ref),
        textAlign: TextAlign.center,
        style: context.textTheme().titleMedium?.copyWith(
              color: ProjectColors.grey,
            ),
      ),
    );
  }
}