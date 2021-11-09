import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final List<DocumentSnapshot> items;

  const Invoice({
    required this.items,
  });
}

class InvoiceItem {
  final String name;
  final int numOfItemSold;
  final double price;
  final double total;

  const InvoiceItem({
    required this.name,
    required this.numOfItemSold,
    required this.price,
    required this.total,
  });
}
