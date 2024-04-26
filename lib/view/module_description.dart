// import 'package:flutter/material.dart';

// class ModuleDescriptions extends StatefulWidget {
//  @override
//  _ModuleDescriptionsState createState() => _ModuleDescriptionsState();
// }

// class _ModuleDescriptionsState extends State<ModuleDescriptions> {
//  List<Item> _data = generateItems(5);

//  @override
//  Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         ExpansionPanelList(
//           expansionCallback: (int index, bool isExpanded) {
//             setState(() {
//               _data[index].isExpanded = !isExpanded;
//             });
//           },
//           children: _data.map<ExpansionPanel>((Item item) {
//             return ExpansionPanel(
//               headerBuilder: (BuildContext context, bool isExpanded) {
//                 return ListTile(
//                  title: Text(item.headerValue),
//                 );
//               },
//               body: ListTile(
//                 title: Text(item.expandedValue),
//               ),
//               isExpanded: item.isExpanded,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//  }
// }

// class Item {
//  Item({
//     required this.expandedValue,
//     required this.headerValue,
//     this.isExpanded = false,
//  });

//  String expandedValue;
//  String headerValue;
//  bool isExpanded;
// }

// List<Item> generateItems(int numberOfItems) {
//  return List<Item>.generate(numberOfItems, (int index) {
//     return Item(
//       headerValue: 'Module ${index + 1}',
//       expandedValue: 'This is the description for Module ${index + 1}.',
//     );
//  });
// }