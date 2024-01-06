import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/assets/names.dart';
import 'package:runningdots/assets/style.dart';
import 'package:runningdots/page/visualizer.dart';
import 'package:runningdots/widget/button.dart';

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
          fontFamily: 'Inter',
          textTheme: const TextTheme(
              displayLarge: AppStyles.whiteText,
              displayMedium: AppStyles.whiteText,
              displaySmall: AppStyles.whiteText,
              headlineLarge: AppStyles.whiteText,
              headlineMedium: AppStyles.whiteText,
              headlineSmall: AppStyles.whiteText,
              titleLarge: AppStyles.whiteText,
              titleMedium: AppStyles.whiteText,
              titleSmall: AppStyles.whiteText,
              bodyLarge: AppStyles.whiteText,
              bodyMedium: AppStyles.whiteText,
              bodySmall: AppStyles.whiteText,
              labelLarge: AppStyles.whiteText,
              labelMedium: AppStyles.whiteText,
              labelSmall: AppStyles.whiteText)),
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
  //Default page - Visualizer
  Widget _page = const Visualizer();
  String _titleAppBar = AppNamesPage.visualizer;

  void _updatePage(Widget page) {
    setState(() {
          _page = page;

    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      //Title
      appBar: AppBar(
        toolbarHeight: 52,
        elevation: 0.0,
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
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
        title: Text(
          _titleAppBar,
          style: AppStyles.whiteText,
        ),
      ),

      //Content
      body: _page,

      //Sidebar
      drawer: Drawer(
        backgroundColor: AppColors.background,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
                    _titleAppBar = AppNamesPage.visualizer,
                    () => _updatePage(const Visualizer()),
                    AppColors.primary,
                  ),
                  const SizedBox(height: 15),
                  SideButton(
                    "Настройки матрицы",
                    () => _updatePage(const Button()),
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
