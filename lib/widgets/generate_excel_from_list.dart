import 'package:excel/excel.dart';

class GenerateExcelFromList {
  final List listData;
  final String keyMain;
  final String? key1;
  final String? key2;
  final String? key3;
  final String? key4;

  GenerateExcelFromList({
    required this.listData,
    required this.keyMain,
    this.key1,
    this.key2,
    this.key3,
    this.key4,
  });

  Future<List<int>> generateExcel() async {
    var rows = listData.length;

    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        keyMain;
    if (key1 != null) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = key1;
    }
    if (key2 != null) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = key2;
    }
    if (key3 != null) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = key3;
    }
    if (key4 != null) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = key4;
    }

    for (var row = 0; row < rows; row++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1))
          .value = listData[row][keyMain];
      if (key1 != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1))
            .value = listData[row][key1];
      }
      if (key2 != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1))
            .value = listData[row][key2];
      }
      if (key3 != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1))
            .value = listData[row][key3];
      }
      if (key3 != null) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1))
            .value = listData[row][key4];
      }
    }
    final fileBytes = excel.save();
    return fileBytes!;
  }
}
