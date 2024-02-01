import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:runningdots/Bluetooth/Bluetooth.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/assets/style/style.dart';
import 'package:runningdots/widget/button.dart';

import 'package:runningdots/Bluetooth/BluetoothWin.dart';
// if (Platform.isWindows) 'package:runningdots/Bluetooth/BluetoothAndroid.dart' ;

class PopUp extends StatefulWidget {
  final Widget? title;
  final Widget? upperElement;
  final String? hit;

  final Widget? child;

  const PopUp({super.key, required this.title, this.upperElement, this.hit, this.child});

  @override
  State<PopUp> createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  Widget? hit;

  @override
  void initState() {
    //InitHit
    if (widget.hit != null) {
      hit = Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                widget.hit!,
                style: AppStyles.blackText,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }
    // _startFind();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // //Head
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 2, color: AppColors.primary),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(child: widget.title),
                  ),
                  Button(
                    childPadding: const EdgeInsets.all(15),
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.background,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            //Upper element
            Container(child: widget.upperElement),

            //Body
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    //Hit
                    Container(
                      child: hit,
                    ),

                    //Content
                    Expanded(child: Container(child: widget.child)
                        // RefreshIndicator(
                        //   onRefresh: _startFind(),
                        //   child: ListView.builder(
                        //     shrinkWrap: true,
                        //     padding: EdgeInsets.zero,
                        //     itemCount: widget.list!.length,
                        //     itemBuilder: widget.itemBuilder,
                        //   ),
                        // ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
