// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new, unused_catch_clause, await_only_futures, avoid_function_literals_in_foreach_calls, avoid_print
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/controllers/auth_controller.dart';
import 'package:easi/services/product_database.dart';
import 'package:easi/services/sales_database.dart';
import 'package:easi/utils/notification_id.dart';
import 'package:easi/utils/product_validations.dart';
import 'package:easi/widgets/app_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easi/widgets/app_textformfield.dart';
import 'package:easi/widgets/app_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProductAdd extends StatefulWidget {
  final String? getBarcode;
  const ProductAdd({Key? key, this.getBarcode}) : super(key: key);

  @override
  _ProductAddState createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final _authController = Get.find<AuthController>();
  late final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(_authController.user!.uid)
      .collection('products');
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

  final GlobalKey<FormState> _productAddFormKey = GlobalKey<FormState>();

  String? scanResult;
  String barcode = '';
  String photoUrl = '';
  String dateMonth = DateFormat('MMMM').format(DateTime.now()); //*GET MONTH

  final List<String> productCategories = [
    'All',
    'Appliances',
    'Clothing',
    'Cosmetics',
    'Drinks',
    'Equipments',
    'Food',
    'Games',
    'Music',
    'Shoes',
    'Sports',
    'Technology',
    'Others',
  ];
  String? value;
  bool _nameExist = false;
  @override
  void initState() {
    _barcodeController.text = widget.getBarcode!;

    //!! TRY
    if (_barcodeController.text != "") {
      _quantityController.text = '1';
    }
    super.initState();
  }

  // @override
  // void dispose() {
  //   _barcodeController.dispose();
  //   _nameController.dispose();
  //   _quantityController.dispose();
  //   _priceController.dispose();
  //   _expiryDateController.dispose();
  //   _typeController.dispose();

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
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Scrollbar(
            showTrackOnHover: true,
            child: SingleChildScrollView(
              child: Form(
                key: _productAddFormKey,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 80.0),
                  child: Column(
                    children: [
                      Text(
                        'Add Product',
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
        floatingActionButton: productAdd(),
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
              backgroundImage: _pickedImage == null
                  ? AssetImage('assets/images/def_prod_image.jpg')
                  : FileImage(File(_pickedImage!.path)) as ImageProvider,
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
        if (_barcodeController.text != "") {
          _quantityController.text = '1';
        }
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
      textCapitalization: TextCapitalization.words,
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

  //*CATEGORY
  Widget productCategory() {
    return DropdownButtonFormField<String>(
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
      value: value,
      onChanged: (value) {
        setState(() {
          this.value = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Field is required';
        }
        return null;
      },
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

  //*ADD PRODUCT BUTTON
  Widget productAdd() {
    return FloatingActionButton(
      onPressed: () async {
        try {
          if (_productAddFormKey.currentState!.validate()) {
            String barcode = _barcodeController.text;
            String name = _nameController.text.toLowerCase();
            int quantity = int.parse(_quantityController.text);
            double price = double.parse(_priceController.text);
            String expiryDate = _expiryDateController.text;
            String category = value!;
            String tName = '';

            await _productCollection
                .limit(1)
                .where('name', isEqualTo: name)
                .get()
                .then((querySnapshot) {
              if (querySnapshot.docs.isEmpty) {
                print('No data to compare');
              } else {
                querySnapshot.docs.forEach((doc) async {
                  tName = doc.get('name');
                });
              }
            });

            if (_pickedImage == null) {
              photoUrl = "";
              // showToast(msg: "Please pick an image");
            } else {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('productUserImages')
                  .child(_authController.user!.displayName!)
                  .child(name + '.jpg');

              await ref.putFile(_pickedImage!);
              photoUrl = await ref.getDownloadURL();
            }

            if (name == tName) {
              showToast(msg: 'Name already exists');
            } else {
              Loading();
              await db
                  .addProduct(
                uniqueID: createUniqueId(),
                photoURL: photoUrl,
                barcode: barcode,
                name: name,
                category: category,
                quantity: quantity,
                numOfItemSold: 0,
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

              showToast(msg: "Product Added");
              Get.back();
            }
          }
        } catch (e) {
          showToast(msg: 'An error has occured');
        }
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
