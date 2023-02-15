// // ignore_for_file: prefer_const_constructors

// import 'dart:io';
// import 'dart:math';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:json_annotation/json_annotation.dart';

// class SizeMatrix {
//   SizeMatrix(this.heightMatrix, this.widthMatrix);
//   int heightMatrix = 0, widthMatrix = 0;

//   Map<String, int> toJson() => {
//         'heightMatrix': heightMatrix,
//         'widthMatrix': widthMatrix,
//       };
// }

// @JsonSerializable()
// class InfoMatrix {
//   SizeMatrix mainsizeMatrix = SizeMatrix(0, 0);
//   Map<String, SizeMatrix> pinMatrix = {};
//   InfoMatrix();
  
//   InfoMatrix.fromJson(Map<String, dynamic> json)
//       : pinMatrix = {
//           for (MapEntry<String, dynamic> entry in json['pinMatrix'].entries)
//             entry.key: SizeMatrix(
//               entry.value["heightMatrix"],
//               entry.value["widthMatrix"],
//             ),
//         },
//         mainsizeMatrix = SizeMatrix(
//           json['mainsizeheightMatrix'],
//           json['mainsizewidthMatrix'],
//         );

//   Map<String, dynamic> toJson() => {
//         'pinMatrix': {
//           for (var entry in pinMatrix.entries) entry.key: entry.value.toJson(),
//         },
//         'mainsizeheightMatrix': mainsizeMatrix.heightMatrix,
//         'mainsizewidthMatrix': mainsizeMatrix.widthMatrix,
//       };
// }

// Map<String, String> myContent = {};

// Container CreateTitle(String title, [double myFontSize = 15]) {
//   return Container(
//     alignment: Alignment.centerLeft,
//     margin: EdgeInsets.only(bottom: 3),
//     child: Text(
//       title,
//       style: TextStyle(
//         color: Color(0xffB1BEFF),
//         fontSize: myFontSize,
//       ),
//     ),
//   );
// }

// class MyInputText_File extends StatefulWidget {
//   MyInputText_File(this.title, {super.key}) {
//     if (!myContent.containsKey(title)) {
//       myContent.addAll({title: ""});
//     }
//   }
//   String title;

//   @override
//   State<MyInputText_File> createState() => _MyInputText_FileState();
// }

// class _MyInputText_FileState extends State<MyInputText_File> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           CreateTitle(widget.title),
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: const Color(0xff7F69FF),
//                 width: 2,
//               ),
//             ),
//             child: MyTextButton(
//               myContent[widget.title]!,
//               myFunction: () async {
//                 FilePickerResult? result = await FilePicker.platform.pickFiles(
//                     type: FileType.custom,
//                     allowedExtensions: ['png', 'jpg', 'gif']);
//                 if (result != null) {
//                   setState(
//                     () {
//                       myContent[widget.title] = result.files.first.path!;
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyInputText_Push extends StatefulWidget {
//   String title;
//   Widget myPopUp;
//   Function(String text)? function;
//   MyInputText_Push(this.title, this.myPopUp, {this.function, super.key}) {
//     if (!myContent.containsKey(title)) {
//       myContent.addAll({title: ""});
//     }
//   }

//   State<MyInputText_Push> createState() => _MyInputText_PushState();
// }

// class _MyInputText_PushState extends State<MyInputText_Push> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           CreateTitle(widget.title),
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: const Color(0xff7F69FF),
//                 width: 2,
//               ),
//             ),
//             child: MyTextButton(
//               myContent[widget.title]!,
//               myFunction: () async {
//                 String result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => widget.myPopUp),
//                     ) ??
//                     '';
//                 if (result != '') {
//                   if (widget.function != null) {
//                     var turned = widget.function!(result);
//                     if (turned == false) return;
//                   }
//                   setState(
//                     () {
//                       myContent[widget.title] = result;
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyTextButton extends StatelessWidget {
//   final String text;
//   final Function()? myFunction;
//   final AlignmentGeometry myAlignment;
//   const MyTextButton(this.text,
//       {this.myFunction, this.myAlignment = Alignment.centerLeft, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: myFunction ??
//           () {
//             Navigator.pop(context, text);
//           },
//       style: TextButton.styleFrom(
//         alignment: myAlignment,
//         minimumSize: Size.zero,
//         padding: EdgeInsets.all(0),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 15,
//             color: Colors.white,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyInputText extends StatefulWidget {
//   TextEditingController textEditingController;
//   String title;
//   bool inputNumber;

//   MyInputText(this.title, this.textEditingController,
//       {this.inputNumber = false, super.key});

//   @override
//   State<MyInputText> createState() => _MyInputTextState();
// }

// class _MyInputTextState extends State<MyInputText> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CreateTitle(widget.title),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: const Color(0xff7F69FF),
//               width: 2,
//             ),
//           ),
//           child: MyTextField(
//             widget.textEditingController,
//             inputNumber: widget.inputNumber,
//           ),
//         ),
//       ],
//     );
//     ;
//   }
// }

// class MyInputTextAdvanced extends StatelessWidget {
//   List<String> title;
//   List<TextEditingController> textEditingController;
//   String mainTitle;
//   bool inputNumber;
//   MyInputTextAdvanced(this.mainTitle, this.title, this.textEditingController,
//       {this.inputNumber = true, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       child: Column(
//         children: [
//           CreateTitle(mainTitle, 18),
//           Row(
//             children: [
//               for (int i = 0; i < title.length; i++)
//                 Expanded(
//                   child: Container(
//                     margin: i + 1 < title.length
//                         ? EdgeInsets.only(right: 10)
//                         : null,
//                     child: MyInputText(
//                       title[i],
//                       textEditingController[i],
//                       inputNumber: true,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyTextField extends StatelessWidget {
//   String? hintText;
//   bool inputNumber;
//   TextEditingController textEditingController;
//   MyTextField(this.textEditingController,
//       {this.hintText, this.inputNumber = false, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       keyboardType: inputNumber == true ? TextInputType.number : null,
//       inputFormatters: inputNumber == true
//           ? [
//               LengthLimitingTextInputFormatter(5),
//               FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//               TextInputFormatter.withFunction(
//                 (oldValue, newValue) => newValue.copyWith(
//                   text: newValue.text,
//                 ),
//               ),
//             ]
//           : null,
//       textAlign: TextAlign.left,
//       controller: textEditingController,
//       decoration: InputDecoration(
//         border: InputBorder.none,
//         isDense: true,
//         errorText: '',
//         errorStyle: TextStyle(
//           color: Colors.transparent,
//           height: 0,
//         ),
//         hintText: hintText,
//         contentPadding: EdgeInsets.all(15),
//         hintStyle: TextStyle(
//           color: Colors.grey,
//           fontSize: 15,
//         ),
//         focusColor: Colors.grey,
//         floatingLabelStyle: TextStyle(
//           color: Colors.grey,
//           fontSize: 15,
//         ),
//       ),
//       style: TextStyle(
//         color: Colors.white,
//         fontSize: 15,
//       ),
//     );
//     ;
//   }
// }
