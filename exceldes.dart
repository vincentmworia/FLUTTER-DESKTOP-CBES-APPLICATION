// import 'dart:io';
//
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
//
// class GenerateExcelFromList {
//   GenerateExcelFromList();
//
//   Future<void> generateExcel(List<Map<String, dynamic>> list) async {
//     var rows = 20;
//
//     final excel = Excel.createExcel();
//     final Sheet sheet = excel[excel.getDefaultSheet()!];
//
//     for (var row = 0; row < rows; row++) {
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//           .value = 'FLUTTER';
//
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//           .value = 'is';
//
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
//           .value = "Vincent's";
//
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
//           .value = "UI";
//
//       sheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
//           .value = "toolkit";
//     }
//
//     excel.save(fileName: "MyData.xlsx");
//     var fileBytes = excel.save();
//     // todo, error handling, if it is opened, then prevent the opening
//     // todo Logic to read excel file from a given list of map of String, dynamic
//     var directory = await getApplicationDocumentsDirectory();
//     File(("${directory.path}/output_file.xlsx"))
//       ..createSync(recursive: true)
//       ..writeAsBytesSync(fileBytes!);
//   }
// }

void main() {
  List temp1 = [
    {"1": "data1"},
    {"2": "data2"},
    {"3": "data3"},
  ];
  List temp2 = [
    {"1": "data4"},
    {"2": "data5"},
    {"3": "data6"},
  ];
  List temp3 = [
    {"1": "data7"},
    {"2": "data8"},
    {"3": "data9"},
  ];
  List tempDataCombination = [];
  int i = 0;
  for (Map data in temp1) {
    tempDataCombination.add({
      "datetime": data.keys.toList()[0],
      "temp1": temp1[i][data.keys.toList()[0]],
      "temp2": temp2[i][data.keys.toList()[0]],
      "temp3": temp3[i][data.keys.toList()[0]]
    });
    i += 1;
  }
}
