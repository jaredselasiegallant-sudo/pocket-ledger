import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';

/// Export Engine for generating Excel (.xlsx) and PDF statements
/// All amounts are denominated in the active currency
class ExportEngine {
  ExportEngine._();

  // ─── Excel Export ───
  static Future<String> exportToExcel({
    required List<Map<String, dynamic>> transactions,
    String fileName = 'pocket_ledger_export',
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    final currentSymbol = CurrencyFormatter.symbolFor(CurrencyFormatter.activeCode);

    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#006B3F'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
    );

    // Headers
    final headers = [
      'Date',
      'Title',
      'Type',
      'Category',
      'Amount ($currentSymbol)',
      'Provider',
      'Reference',
      'Notes',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: i,
        rowIndex: 0,
      ));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (int i = 0; i < transactions.length; i++) {
      final txn = transactions[i];
      final row = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue(txn['date'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        ..value = TextCellValue(txn['title'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        ..value = TextCellValue(txn['type'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        ..value = TextCellValue(txn['category'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
        ..value = DoubleCellValue(txn['amount'] ?? 0.0)
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
        ..value = TextCellValue(txn['provider'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
        ..value = TextCellValue(txn['reference'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
        ..value = TextCellValue(txn['notes'] ?? '')
        ..cellStyle = CellStyle(
          backgroundColorHex: row.isOdd
              ? ExcelColor.fromHexString('#F8FAF5')
              : ExcelColor.fromHexString('#FFFFFF'),
        );
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    // Summary row
    final summaryRow = transactions.length + 2;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: summaryRow))
      ..value = TextCellValue('Total')
      ..cellStyle = CellStyle(bold: true, fontSize: 12);

    final total = transactions.fold<double>(
      0,
      (sum, txn) => sum + (txn['amount'] ?? 0.0),
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: summaryRow))
      ..value = DoubleCellValue(total)
      ..cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/pocket_ledger/$fileName.xlsx',
    );
    await file.parent.create(recursive: true);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }

    return file.path;
  }

  // ─── PDF Export ───
  static Future<String> exportToPdf({
    required List<Map<String, dynamic>> transactions,
    String fileName = 'pocket_ledger_statement',
    double? totalIncome,
    double? totalExpenses,
  }) async {
    final pdf = pw.Document();

    final currentSymbol = CurrencyFormatter.symbolFor(CurrencyFormatter.activeCode);

    final green = PdfColor.fromHex('#006B3F');
    final lightGreen = PdfColor.fromHex('#F0FFF5');
    final gray = PdfColor.fromHex('#717971');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  AppConstants.appName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: green,
                  ),
                ),
                pw.Text(
                  'Statement',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: gray,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: green),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated by PocketLedger',
                  style: pw.TextStyle(fontSize: 10, color: gray),
                ),
                pw.Text(
                  'All amounts in $currentSymbol',
                  style: pw.TextStyle(fontSize: 10, color: gray),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          // Summary
          if (totalIncome != null || totalExpenses != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightGreen,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Income', totalIncome ?? 0, green),
                  _summaryItem('Expenses', totalExpenses ?? 0, PdfColors.red),
                  _summaryItem(
                    'Balance',
                    (totalIncome ?? 0) - (totalExpenses ?? 0),
                    green,
                  ),
                ],
              ),
            ),

          pw.SizedBox(height: 20),

          // Transactions Table
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              color: green,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(4),
                topRight: pw.Radius.circular(4),
              ),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 32,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
            headerAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
            headers: ['Date', 'Description', 'Type', 'Amount ($currentSymbol)'],
            data: transactions.map((txn) {
              final amount = txn['amount'] ?? 0.0;
              final type = txn['type'] ?? '';
              return [
                txn['date'] ?? '',
                txn['title'] ?? '',
                type.toUpperCase(),
                '${amount >= 0 ? '+' : ''}${CurrencyFormatter.formatGhs(amount)}',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/pocket_ledger/$fileName.pdf',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _summaryItem(String label, double amount, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: color),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          CurrencyFormatter.formatGhs(amount),
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─── Share File ───
  static Future<void> shareFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'PocketLedger Export',
      );
    }
  }
}
