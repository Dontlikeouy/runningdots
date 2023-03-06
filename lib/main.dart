import 'package:flutter/material.dart';
import 'package:runningdots/pages/settingsV2.dart';
import 'package:runningdots/pages/settingsImage.dart';
import 'package:runningdots/pages/visualizerV2.dart';
import 'package:runningdots/style/color.dart';

import 'fileMe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    getGlobalPath();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: purple[0],
            body: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: purple[1],
                    border: Border(
                      top: BorderSide(
                        color: purple[1],
                        width: 5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    labelPadding: const EdgeInsets.all(10),
                    isScrollable: true,
                    unselectedLabelColor: textColor[0],
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    indicator: BoxDecoration(
                      color: purple[0],
                    ),
                    tabs: const [
                      Text("Настройки"),
                      Text("Визуализатор"),
                      Text("Изменить размер"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Container(padding: const EdgeInsets.all(10), child: const Settings()),
                      Container(padding: const EdgeInsets.all(10), child: const Visualizer()),
                      Container(padding: const EdgeInsets.all(10), child: const SettingsImage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
