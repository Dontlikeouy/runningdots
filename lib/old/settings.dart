// // ignore_for_file: prefer_const_constructors

// import 'dart:convert';
// import 'dart:ffi';

// import 'package:flutter/material.dart';
// import 'package:runningdots/fileMethode.dart';
// import 'package:runningdots/mytemplate.dart';
// import 'package:runningdots/mypopups.dart';

// class Settings extends StatelessWidget {
//   Settings({super.key});
//   TextEditingController widthMatrix = TextEditingController(text: "");
//   TextEditingController heightMatrix = TextEditingController(text: "");
//   InfoMatrix infoMatrix = InfoMatrix();
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         MyInputText_Push(
//           "Файл",
//           MyPopUp_AdvancedEnumeration(
//             "Файл",
//             getFiles(),
//           ),
//         ),
//         MyInputText_Push(
//           "Pin",
//           MyPopUp_Enumeration(
//             "Pin",
//             const ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
//             myColumns: 2,
//             description: "Порт на плате arduino к которому подключена матрица",
//           ),
//         ),
//         MyInputTextAdvanced(
//           "Размер матрицы:",
//           const ["Ширина", "Высота"],
//           [widthMatrix, heightMatrix],
//         ),
//         MyInputText_Push(
//           "Расположение",
//           MyPopUp_Enumeration(
//             "Расположение",
//             const ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
//             myColumns: 2,
//             description: "Расположение относительно предыдущей.\nЗначение 'Пусто' в обоих полях обозначет начальную матрицу",
//           ),
//         ),
//         Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               color: Color(0xff5D4EB6),
//             ),
//             child: MyTextButton(
//               "Сохранить/Добавить",
//               myFunction: () {
//                 if (myContent["Файл"] != '' &&
//                     myContent["Pin"] != '' &&
//                     heightMatrix.text != '' &&
//                     widthMatrix.text != '') {
//                   String tText = readTextInFile(myContent["Файл"]!);
//                   if (tText != '') {
//                     try {
//                       InfoMatrix.fromJson(
//                           jsonDecode(readTextInFile(myContent["Файл"]!)));
//                     } catch (e) {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MyPopUp_QuestionOrNotice(
//                                 "Оповещние",
//                                 "Ошибка. Не удалось считать файл с настройками",
//                                 notice: true),
//                           ));
//                       return;
//                     }
//                   }
//                   infoMatrix.pinMatrix.addAll({
//                     myContent["Pin"]!: SizeMatrix(int.parse(heightMatrix.text),
//                         int.parse(widthMatrix.text))
//                   });
//                   var heightMatrix_pluse =
//                       infoMatrix.mainsizeMatrix.heightMatrix +
//                           infoMatrix.pinMatrix[myContent["Pin"]]!.heightMatrix;

//                   var widthMatrix_pluse =
//                       infoMatrix.mainsizeMatrix.widthMatrix +
//                           infoMatrix.pinMatrix[myContent["Pin"]]!.widthMatrix;

//                   if (infoMatrix.mainsizeMatrix.heightMatrix <
//                       heightMatrix_pluse) {
//                     infoMatrix.mainsizeMatrix.heightMatrix = heightMatrix_pluse;
//                   }

//                   if (infoMatrix.mainsizeMatrix.widthMatrix <
//                       heightMatrix_pluse) {
//                     infoMatrix.mainsizeMatrix.widthMatrix = widthMatrix_pluse;
//                   }

//                   writeTextToFile(
//                       myContent["Файл"]!, jsonEncode(infoMatrix.toJson()));

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyPopUp_QuestionOrNotice(
//                           "Оповещние", "Успешно сохранено/добавлено",
//                           notice: true),
//                     ),
//                   );
//                 }
//               },
//               myAlignment: Alignment.center,
//             ))
//       ],
//     );
//   }
// }
