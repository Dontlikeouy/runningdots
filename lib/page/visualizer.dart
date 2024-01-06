import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/assets/style.dart';
import 'package:runningdots/widget/button.dart';

class Visualizer extends StatelessWidget {
  const Visualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Choose path
          const Text("Изображения. формат: .png"),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                width: 2,
                color: AppColors.primary,
              )),
              child: const Text("Путь..."),
            ),
          ),

          const SizedBox(height: 15),

          //Button - translate images
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Material(
              color: AppColors.primary,
              child: InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      "Передать",
                      style: AppStyles.blackText,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        width: 2,
                        color: AppColors.primary,
                      )),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Button(),
        ],
      ),
    );
  }
}
