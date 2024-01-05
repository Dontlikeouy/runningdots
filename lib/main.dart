import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/assets/names.dart';
import 'package:runningdots/assets/style.dart';
import 'package:runningdots/page/visualizer.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _title = 'RunningDots';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      title: _title,
      theme: ThemeData(
          fontFamily: 'Inter', textTheme: const TextTheme(displayLarge: AppStyles.text, displayMedium: AppStyles.text, displaySmall: AppStyles.text, headlineLarge: AppStyles.text, headlineMedium: AppStyles.text, headlineSmall: AppStyles.text, titleLarge: AppStyles.text, titleMedium: AppStyles.text, titleSmall: AppStyles.text, bodyLarge: AppStyles.text, bodyMedium: AppStyles.text, bodySmall: AppStyles.text, labelLarge: AppStyles.text, labelMedium: AppStyles.text, labelSmall: AppStyles.text)),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _page = const Visualizer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      //Title
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0.0,
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return Material(
              color: AppColors.primary,
              child: InkWell(
                child: const Icon(
                  Icons.menu,
                  color: AppColors.background,
                ),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),
        title: const Text(
          AppNames.title,
          style: AppStyles.text,
        ),
      ),

      //Content
      body: Center(
        child: _page,
      ),

      //Sidebar
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              child: const Text(AppNames.title),
            ),

            //Page
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                children: [
                  SideButton(
                    "Визуализатор",
                    () => Navigator.of(context).pop(),
                    AppColors.primary,
                  ),
                  const SizedBox(height: 15),
                  SideButton(
                    "Настройки матрицы",
                    () => _page = const Text("data"),
                    AppColors.primary,
                  ),
                  const SizedBox(height: 15),
                  SideButton(
                    "das",
                    () => _page = const Text("data"),
                    AppColors.additional,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SideButton extends StatelessWidget {
  final void Function() onTap;
  final String textButton;
  final Color colorCircle;
  const SideButton(this.textButton, this.onTap, this.colorCircle, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colorCircle,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(textButton)
        ],
      ),
    );
  }
}
