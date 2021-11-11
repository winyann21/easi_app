import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/api/pdf_api.dart';
import 'package:easi/models/invoice.dart';
import 'package:easi/utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfInvoiceApi {
  static String dateMonth = DateFormat('MMMM').format(DateTime.now());
  static String date = DateFormat('MMMM-dd-yyyy').format(DateTime.now());
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
    ));

    return PdfApi.saveDocument(
        name: '$dateMonth-Inventory-Report.pdf', pdf: pdf);
  }

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dateMonth Monthly Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(date),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      //ito yung title sa list boi, edit mo nalang mga names
      'Name',
      'Barcode',
      'Date Added',
      'Expiry Date',
      'Quantity',
      'Item Sold',
      'Price',
      'Total',
    ];
    final data = invoice.items.map((item) {
      //*CALCULATE TOTAL SALES
      String prodName;
      String barcode;
      Timestamp dateAdded;
      DateTime dateAdd;
      String strDateAdd;
      String dateExpiry;
      double prodPrice;
      int prodNumOfItemSold;
      int prodQuantity;
      double totalPrice;
      double totalSales = 0.0;

      prodName = item.get('name');
      barcode = item.get('barcode');
      dateAdded = item.get('dateAdded');
      dateExpiry = item.get('expiryDate');
      prodPrice = item.get('price');
      prodQuantity = item.get('quantity');
      prodNumOfItemSold = item.get('numOfItemSold');

      dateAdd = DateTime.parse(dateAdded.toDate().toString());
      strDateAdd = DateFormat('MM-dd-yyyy').format(dateAdd);
      totalPrice = (prodPrice * double.parse(prodNumOfItemSold.toString()));
      totalSales = (totalSales + totalPrice);

      return [
        // ito para madisplay yung mga product data (name, quantity, etc.....)
        item.get('name'),
        item.get('barcode'),
        strDateAdd,
        item.get('expiryDate'),
        item.get('quantity'),
        item.get('numOfItemSold'),
        item.get('price'),
        totalPrice,
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 40,
      cellStyle: pw.TextStyle(fontSize: 8),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerLeft,
        3: Alignment.centerLeft,
        4: Alignment.centerLeft,
        5: Alignment.centerLeft,
        6: Alignment.centerLeft,
        7: Alignment.centerLeft,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    double totalSales = 0.0;
    final data = invoice.items.map((item) {
      //*CALCULATE TOTAL SALES
      String prodName;
      String barcode;
      Timestamp dateAdded;
      DateTime dateAdd;
      String strDateAdd;
      String dateExpiry;
      double prodPrice;
      int prodNumOfItemSold;
      int prodQuantity;
      double totalPrice;

      prodName = item.get('name');
      barcode = item.get('barcode');
      dateAdded = item.get('dateAdded');
      dateExpiry = item.get('expiryDate');
      prodPrice = item.get('price');
      prodQuantity = item.get('quantity');
      prodNumOfItemSold = item.get('numOfItemSold');

      dateAdd = DateTime.parse(dateAdded.toDate().toString());
      strDateAdd = DateFormat('MM-dd-yyyy').format(dateAdd);
      totalPrice = (prodPrice * double.parse(prodNumOfItemSold.toString()));
      totalSales = (totalSales + totalPrice);
      return [
        // ito para madisplay yung mga product data (name, quantity, etc.....)
        item.get('name'),
        item.get('barcode'),
        strDateAdd,
        item.get('expiryDate'),
        item.get('quantity'),
        item.get('numOfItemSold'),
        item.get('price'),
        totalPrice,
      ];
    }).toList();

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Total Sales',
                  value: Utils.formatPrice(totalSales),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
