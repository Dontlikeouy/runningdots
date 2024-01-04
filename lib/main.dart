import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/page/visualizer.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _title = 'RunningDots';
  Widget _page = const Visualizer();

  void _updatePage(Widget page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white, decorationColor: Colors.white);
    return MaterialApp(
      title: _title,
      theme: ThemeData(
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            displayLarge: textStyle,
            displayMedium: textStyle,
            displaySmall: textStyle,
            headlineLarge: textStyle,
            headlineMedium: textStyle,
            headlineSmall: textStyle,
            titleLarge: textStyle,
            titleMedium: textStyle,
            titleSmall: textStyle,
            bodyLarge: textStyle,
            bodyMedium: textStyle,
            bodySmall: textStyle,
            labelLarge: textStyle,
            labelMedium: textStyle,
            labelSmall: textStyle,
          )),
      home: Scaffold(
        //Title
        appBar: AppBar(title: Text(_title)),

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
                child: Text(_title),
              ),

              //Page
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          child: const Text('Визуализатор'),
                          onTap: () {
                            _updatePage(const Text("sad"));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          child: const Text('Настройки матрицы'),
                          onTap: () {
                            _updatePage(const Text("sad"));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.additional,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          child: const Text('Общие настройки'),
                          onTap: () {
                            _updatePage(const Text("sad"));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
