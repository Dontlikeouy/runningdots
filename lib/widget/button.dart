import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    this.title,
    this.child,
    this.onTap,
    this.childPadding,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.backgroundColor = Colors.transparent,
    this.circleColor,
  });
  final Widget? title;

  final void Function()? onTap;

  final BorderRadius borderRadius;

  final BoxBorder? border;
  final Color? backgroundColor;
  final Color? circleColor;

  final EdgeInsets? childPadding;
  final Widget? child;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: widget.title,
            ),
            widget.title != null ? SizedBox(height: 5) : SizedBox(),
            Ink(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: widget.border,
                borderRadius: widget.borderRadius,
              ),
              child: InkWell(
                borderRadius: widget.borderRadius,
                onTap: widget.onTap,
                child: Container(
                  padding: widget.childPadding,
                  child: Row(
                    children: [
                      widget.circleColor != null
                          ? Container(
                              width: 12,
                              height: 12,
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: widget.circleColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Container(),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
