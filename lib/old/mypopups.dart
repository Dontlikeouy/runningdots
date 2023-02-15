// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:runningdots/fileMethode.dart';
// import 'package:runningdots/mytemplate.dart';

// class MyPopUp extends StatelessWidget {
//   late Widget? myWidget, myButtonWidget;
//   late String title;
//   bool? myScroll = false;
//   MyPopUp(this.title, this.myWidget,
//       {this.myScroll, this.myButtonWidget, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Color(0xff212121),
//               border: Border(
//                 top: BorderSide(
//                   color: Color(0xff42377E),
//                   width: 5,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(left: 10),
//                     child: Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Material(
//                   color: Color(0xff42377E),
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               color: Color(0xff212121),
//               child: Padding(
//                   padding: EdgeInsets.all(10),
//                   child: myScroll == false
//                       ? SingleChildScrollView(child: myWidget)
//                       : myWidget),
//             ),
//           ),
//           if (myButtonWidget != null) myButtonWidget!
//         ],
//       ),
//     );
//   }
// }

// class MyPopUp_Enumeration extends StatelessWidget {
//   String? description;
//   late List<String> valueList;
//   late int myColumns;
//   late String title;

//   MyPopUp_Enumeration(this.title, this.valueList,
//       {this.myColumns = 1, this.description, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MyPopUp(
//       title,
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (description != null)
//             Container(
//               padding: EdgeInsets.all(10),
//               margin: EdgeInsets.only(bottom: 10),
//               color: Color(0xff4D4D4D),
//               alignment: Alignment.center,
//               child: Text(
//                 description!,
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           Column(
//             children: [
//               for (int i = 0, f = 0;
//                   i < (valueList.length / myColumns).ceil();
//                   i++)
//                 Container(
//                   margin: EdgeInsets.only(bottom: 10),
//                   child: Row(
//                     children: [
//                       for (int j = f;
//                           f < j + myColumns && f < valueList.length;
//                           f++)
//                         Expanded(
//                           child: Container(
//                             margin: f + 1 < j + myColumns &&
//                                     f + 1 < valueList.length
//                                 ? EdgeInsets.only(right: 10)
//                                 : EdgeInsets.zero,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color(0xff7F69FF),
//                                 width: 2,
//                               ),
//                             ),
//                             child: MyTextButton(
//                               valueList[f],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MyPopUp_AdvancedEnumeration extends StatefulWidget {
//   late String title;
//   String? description;
//   late List<String> valueList;
//   late int myColumns;

//   MyPopUp_AdvancedEnumeration(this.title, this.valueList,
//       {this.description, super.key});

//   @override
//   State<MyPopUp_AdvancedEnumeration> createState() =>
//       _MyPopUp_AdvancedEnumerationState();
// }

// class _MyPopUp_AdvancedEnumerationState
//     extends State<MyPopUp_AdvancedEnumeration> {
//   TextEditingController newFile = TextEditingController(text: "");
//   @override
//   Widget build(BuildContext context) {
//     return MyPopUp(
//       widget.title,
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (widget.description != null)
//             Container(
//               padding: EdgeInsets.all(10),
//               margin: EdgeInsets.only(bottom: 10),
//               color: Color(0xff4D4D4D),
//               alignment: Alignment.center,
//               child: Text(
//                 widget.description!,
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           Container(
//             margin: EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: const Color(0xff7F69FF),
//                 width: 2,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                     child: MyTextField(
//                   newFile,
//                   hintText: 'Добавить новый объект',
//                 )),
//                 Material(
//                   color: Color(0xff7F69FF),
//                   child: InkWell(
//                     onTap: () async {
//                       newFile.value =
//                           TextEditingValue(text: newFile.text.trim());

//                       if (newFile.text != '') {
//                         if (RegExp(r'[\\/:*?"<>]').firstMatch(newFile.text) !=
//                             null) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => MyPopUp_QuestionOrNotice(
//                                       "Предупреждение",
//                                       'Имя файла не должно содеражать:\n/ \\ : * ? " < > ',
//                                       notice: true,
//                                     )),
//                           );
//                           return;
//                         }
//                         if (existsFile(newFile.text) == true) {
//                           String result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => MyPopUp_QuestionOrNotice(
//                                         "Предупреждение",
//                                         "Данный файл существует. Пересоздать?")),
//                               ) ??
//                               '';

//                           if (result != 'Да') {
//                             newFile.value = TextEditingValue(text: "");

//                             return;
//                           }
//                         }

//                         createFile(newFile.text);
//                         newFile.value = TextEditingValue(text: "");

//                         var tempList = getFiles();

//                         setState(() {
//                           widget.valueList = tempList;
//                         });
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Icon(
//                         Icons.check,
//                         color: Color(0xff212121),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           for (int i = 0; i < widget.valueList.length; i++)
//             Container(
//               margin: EdgeInsets.only(bottom: 10),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: const Color(0xff7F69FF),
//                   width: 2,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: MyTextButton(
//                       widget.valueList[i],
//                     ),
//                   ),
//                   Material(
//                     color: Color(0xff7F69FF),
//                     child: InkWell(
//                       onTap: () async {
//                         String result = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => MyPopUp_QuestionOrNotice(
//                                       "Предупреждение",
//                                       "Данный файл будет удалён безвозратно. Удалить?")),
//                             ) ??
//                             '';

//                         if (result == 'Да') {
//                           deleteFile(widget.valueList[i]);
//                           setState(() {
//                             widget.valueList.removeAt(i);
//                           });
//                         }
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Icon(
//                           Icons.delete,
//                           color: Color(0xff212121),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class MyPopUp_QuestionOrNotice extends StatelessWidget {
//   final String title;
//   final String question;
//   bool notice;

//   MyPopUp_QuestionOrNotice(this.title, this.question,
//       {this.notice = false, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MyPopUp(
//         myScroll: true,
//         title,
//         Align(
//           alignment: Alignment.center,
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 30,
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Color(0xff42377E),
//                 width: 5,
//               ),
//             ),
//             child: Text(
//               question,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//         ),
//         myButtonWidget: notice == false
//             ? MyInkWellButtons(const ["Нет", "Да"],
//                 const [Color(0xff212121), Color(0xff42377E)])
//             : null);
//   }
// }

// class MyInkWellButtons extends StatelessWidget {
//   final List<String> text;
//   final List<Color> color;
//   const MyInkWellButtons(this.text, this.color, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xff212121),
//         border: Border(
//           top: BorderSide(
//             color: Color(0xff42377E),
//             width: 5,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           for (int i = 0; i < text.length; i++)
//             Expanded(
//               child: Material(
//                 shadowColor: Colors.transparent,
//                 color: color[i],
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.pop(context, text[i]);
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Text(
//                       text[i],
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
