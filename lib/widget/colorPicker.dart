import 'package:flutter/material.dart';
import 'package:runningdots/style/color.dart';

class ColorPicker extends StatefulWidget {
  final String name;
  const ColorPicker(this.name, {super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  double _value = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: color[0],
      content: SingleChildScrollView(
        child: Row(
          children: [
            Text(
              "${widget.name} ${_value.toInt()}",
              style: TextStyle(
                color: colorText[0],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red[700],
                inactiveTrackColor: Colors.red[100],
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Colors.redAccent,
                overlayColor: Colors.transparent,
              ),
              child: Slider(
                value: _value,
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(
                    () {
                      _value = value;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
