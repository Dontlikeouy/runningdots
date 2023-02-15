// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:runningdots/fileMethode.dart';
// import 'package:runningdots/mypopups.dart';
// import 'package:runningdots/mytemplate.dart';
// import 'dart:io';

// class Visualizer extends StatelessWidget {
//   Visualizer({super.key});

//   InfoMatrix infoMatrix = InfoMatrix();

//   TextEditingController widthImage = TextEditingController(text: "");
//   TextEditingController heightImage = TextEditingController(text: "");
  
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         MyInputText_Push(
//           "Файл настроек",
//           MyPopUp_Enumeration(
//             "Файл настроек",
//             getFiles(),
//           ),
//           function: (text) {
//             String tText = readTextInFile(text);
//             if (tText != '') {
//               try {
//                 infoMatrix = jsonDecode(readTextInFile(text));
//               } catch (e) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => MyPopUp_QuestionOrNotice("Оповещние",
//                         "Ошибка. Не удалось считать файл с настройками",
//                         notice: true),
//                   ),
//                 );
//                 return false;
//               }
//             }
//             return true;
//           },
//         ),
//         MyInputText_File("Изображение"),
//         MyInputTextAdvanced(
//           "Размер изображения",
//           const ["Ширина", "Высота"],
//           [widthImage, heightImage],
//         ),
//         Container(
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               color: Color(0xff5D4EB6),
//             ),
//             child: MyTextButton(
//               "Предпросмотр",
//               myFunction: () {
//                 if (myContent["Файл"] != '' &&
//                     myContent["Изображение"] != '' &&
//                     widthImage.text != '' &&
//                     widthImage.text != '') {}
//               },
//               myAlignment: Alignment.center,
//             ))
//       ],
//     );
//   }
// }
