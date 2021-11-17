// ignore_for_file: prefer_const_constructors, unnecessary_new, avoid_print, await_only_futures

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/utils/product_validations.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProductEdit extends StatefulWidget {
  final String? productId, name, barcode, category, photoUrl, expiryDate;
  final double? price;
  final int? quantity;

  // final ProductModel? products;
  final QueryDocumentSnapshot<Object?>? data;

  const ProductEdit({
    Key? key,
    this.data,
    this.productId,
    this.name,
    this.barcode,
    this.category,
    this.photoUrl,
    this.price,
    this.quantity,
    this.expiryDate,
  }) : super(key: key);

  @override
  _ProductEditState createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final _authController = Get.find<AuthController>();

  final focus = FocusNode();
  File? _pickedImage;
  DateTime? date;

  final ProductDB db = ProductDB();
  final SalesDB sdb = SalesDB();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  final GlobalKey<FormState> _productEditFormKey = GlobalKey<FormState>();

  String? scanResult;
  String barcode = '';
  String photoUrl = '';
  String productId = '';
  String dateMonth = DateFormat('MMMM').format(DateTime.now());

  final List<String> productCategories = [
    'Appliances',
    'Clothing',
    'Drinks',
    'Equipments',
    'Food',
    'Games',
    'Shoes',
    'Sports',
    'Technology',
    'Others',
  ];
  String? pCategory;

  @override
  void initState() {
    _barcodeController.text =
        widget.data != null ? widget.data!.get('barcode') : widget.barcode;
    _nameController.text =
        widget.data != null ? widget.data!.get('name') : widget.name;
    pCategory =
        widget.data != null ? widget.data!.get('category') : widget.category;

    _quantityController.text = widget.data != null
        ? widget.data!.get('quantity').toString()
        : widget.quantity.toString();
    _priceController.text = widget.data != null
        ? widget.data!.get('price').toString()
        : widget.price.toString();
    _expiryDateController.text = widget.data != null
        ? widget.data!.get('expiryDate')
        : widget.expiryDate;
    photoUrl =
        widget.data != null ? widget.data!.get('photoURL') : widget.photoUrl;
    productId = (widget.data != null ? widget.data!.id : widget.productId)!;

    super.initState();
  }

  // @override
  // void dispose() {
  //   _barcodeController.dispose();
  //   _nameController.dispose();
  //   _typeController.dispose();
  //   _quantityController.dispose();
  //   _priceController.dispose();
  //   _expiryDateController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Delete Product',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                        'Deleting an item, will also reduce the total sales of this item this month. \n\nDo you wish to proceed?'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          double totalToDeduct =
                              widget.data!.get('numOfItemSold') *
                                  widget.data!.get('price');
                          double totalSales;
                          var sales =
                              await sdb.salesCollection.doc(dateMonth).get();
                          //*ELSE(UPDATE DOC)
                          var salesDS =
                              await sdb.salesCollection.doc(dateMonth);
                          if (sales.exists) {
                            salesDS.get().then((doc) async {
                              totalSales = doc.get('totalSales');
                              await sdb.updateSales(
                                month: dateMonth,
                                totalSales: totalSales - totalToDeduct,
                              );
                            });
                          }
                          db.deleteProduct(id: productId);
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                          showToast(msg: 'Product Deleted');
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text('No'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Scrollbar(
            showTrackOnHover: true,
            child: SingleChildScrollView(
              child: Form(
                key: _productEditFormKey,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 80.0),
                  child: Column(
                    children: [
                      Text(
                        'Edit Product',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      //*IMAGE PICKER HERE
                      productImage(),
                      SizedBox(height: 15.0),
                      //*BARCODE
                      productBarcode(),
                      SizedBox(height: 15.0),
                      //*NAME
                      productName(),
                      SizedBox(height: 15.0),
                      Row(
                        children: [
                          //*PRICE
                          Expanded(
                            child: productPrice(),
                            flex: 4,
                          ),
                          SizedBox(width: 5.0),

                          //*QUANTITY
                          Expanded(
                            child: productQuantity(),
                            flex: 3,
                          ),
                        ],
                      ),
                      SizedBox(height: 15.0),
                      //*CATEGORY
                      productCategory(),
                      SizedBox(height: 15.0),

                      //*EXPIRY DATE
                      productExpiryDate(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: productEdit(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  //****WIDGETS **/

  //*IMAGE PICKER
  void _pickImageFrom(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: source, imageQuality: 15);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  Widget chooseImageFrom() {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose image from:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.camera_alt_sharp, color: Colors.black),
              onPressed: () {
                _pickImageFrom(ImageSource.camera);
              },
              label: Text(
                'Camera',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo_sharp, color: Colors.black),
              onPressed: () {
                _pickImageFrom(ImageSource.gallery);
              },
              label: Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productImage() {
    return Center(
      child: Container(
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
                context: context, builder: (context) => chooseImageFrom());
          },
          child: CircleAvatar(
              backgroundImage: _pickedImage != null
                  ? FileImage(File(_pickedImage!.path))
                  : photoUrl == ""
                      ? AssetImage('assets/images/def_prod_image.jpg')
                      : NetworkImage(photoUrl) as ImageProvider,
              radius: 70,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue),
        ),
        padding: const EdgeInsets.all(1.5), // borde width
        decoration: new BoxDecoration(
          color: Colors.orange, // border color
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  //*BARCODE
  Widget productBarcode() {
    //*NOTE: NOT REQUIRED FIELD
    return RoundRectTextFormField(
      controller: _barcodeController,
      prefixIcon: Icons.code_sharp,
      hintText: 'Enter Barcode',
      labelText: 'Barcode',
      suffixIcon: Icons.camera_alt_sharp,
      suffixIconOnPressed: scanBarcode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(focus);
      },
    );
  }

  Future scanBarcode() async {
    String scanResult;

    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      scanResult = 'Failed to get platform version';
    }

    if (!mounted) return;

    if (scanResult != '-1') {
      setState(() {
        this.scanResult = scanResult;
        _barcodeController.text = this.scanResult!;
      });
    } else {
      setState(() {
        showToast(msg: 'Scan Cancelled');
      });
    }
  }

  //*NAME
  Widget productName() {
    return RoundRectTextFormField(
      controller: _nameController,
      prefixIcon: Icons.description_sharp,
      hintText: 'Enter Product Name',
      labelText: 'Name',
      suffixIcon: null,
      textInputAction: TextInputAction.next,
      validator: validateProductFields,
    );
  }

  //*PRICE
  Widget productPrice() {
    return RoundRectTextFormField(
      controller: _priceController,
      prefixIcon: Icons.price_check_sharp,
      hintText: 'Price',
      labelText: 'Price',
      suffixIcon: null,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: validateProductFields,
    );
  }

  //*QUANTITY
  Widget productQuantity() {
    return RoundRectTextFormField(
      controller: _quantityController,
      prefixIcon: Icons.workspaces,
      hintText: 'Quantity',
      labelText: 'Quantity',
      suffixIcon: null,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: validateProductFields,
    );
  }

  //*TYPE
  Widget productCategory() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.orange,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        hint: Text('Select Category'),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_sharp,
            color: Colors.orange,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10.0),
          ),
          isDense: true,
        ),
        isExpanded: true,
        iconSize: 36,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
        ),
        items: productCategories.map(buildMenuItem).toList(),
        value: pCategory,
        onChanged: (value) {
          setState(() {
            pCategory = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Field is required';
          }
          return null;
        },
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
      ),
    );
  }

  //*EXPIRY DATE
  Widget productExpiryDate() {
    return RoundRectTextFormField(
      controller: _expiryDateController,
      prefixIcon: Icons.calendar_today_outlined,
      hintText: 'Expiration Date',
      labelText: 'Expiration Date',
      suffixIcon: Icons.close,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      suffixIconOnPressed: () {
        _expiryDateController.clear();
      },
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          pickDate(context);
        });
      },
    );
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 30),
    );
    if (newDate == null) return;
    setState(() {
      date = newDate;
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(newDate);
    });
  }

  //*EDIT PRODUCT BUTTON
  Widget productEdit() {
    return FloatingActionButton(
      onPressed: () async {
        try {
          if (_productEditFormKey.currentState!.validate()) {
            String barcode = _barcodeController.text;
            String name = _nameController.text;
            int quantity = int.parse(_quantityController.text);
            double price = double.parse(_priceController.text);
            String expiryDate = _expiryDateController.text;
            String category = pCategory!;

            if (_pickedImage == null) {
            } else {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('productUserImages')
                  .child(_authController.user!.displayName!)
                  .child(name + '.jpg');

              await ref.putFile(_pickedImage!);
              photoUrl = await ref.getDownloadURL();
            }

            await db
                .updateProduct(
              id: productId,
              photoURL: photoUrl,
              barcode: barcode,
              name: name,
              category: category,
              quantity: quantity,
              price: price,
              expiryDate: expiryDate,
            )
                .then((value) {
              _barcodeController.clear();
              _nameController.clear();
              _priceController.clear();
              _quantityController.clear();
              _expiryDateController.clear();
            });

            showToast(msg: "Product Updated");
            Get.back();
          }
        } catch (e) {
          showToast(msg: 'An error has occured');
        }
      },
      child: Icon(
        Icons.save,
        color: Colors.white,
      ),
    );
  }
}
