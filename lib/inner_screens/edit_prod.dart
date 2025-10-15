import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hgocery_web/Screens/loading_manager.dart';
import 'package:hgocery_web/controllers/MenuController.dart';
import 'package:hgocery_web/services/global_method.dart';
import 'package:hgocery_web/services/utils.dart';
import 'package:hgocery_web/widgets/buttons.dart';
import 'package:hgocery_web/widgets/header.dart';
import 'package:hgocery_web/widgets/side_menu.dart';
import 'package:hgocery_web/widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../responsive.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.price,
    required this.salePrice,
    required this.productCat,
    required this.imageUrl,
    required this.isOnSale,
    required this.isPiece,
  }) : super(key: key);

  final String id, title, price, productCat, imageUrl;
  final bool isPiece, isOnSale;
  final double salePrice;

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController, _priceController;
  late String _catValue;
  String? _salePercent;
  late String percToShow;
  late double _salePrice;
  late bool _isOnSale;
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;
  late int val;
  late bool _isPiece;
  bool _isLoading = false;

  @override
  void initState() {
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _salePrice = widget.salePrice;
    _catValue = widget.productCat;
    _isOnSale = widget.isOnSale;
    _isPiece = widget.isPiece;
    val = _isPiece ? 2 : 1;
    _imageUrl = widget.imageUrl;

    percToShow =
        (100 - (_salePrice * 100) / double.parse(widget.price))
            .round()
            .toString() +
        '%';
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    try {
      setState(() => _isLoading = true);
      Uri? imageUri;

      // Agar rasm yangilansa — yangisini upload qilamiz
      if (_pickedImage != null) {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('productsImages')
            .child('${widget.id}.jpg');

        firebase_storage.UploadTask uploadTask;
        if (kIsWeb) {
          uploadTask = ref.putData(webImage);
        } else {
          uploadTask = ref.putFile(_pickedImage!);
        }

        final snapshot = await uploadTask.whenComplete(() {});
        imageUri = Uri.parse(await snapshot.ref.getDownloadURL());
      }

      final double parsedPrice =
          double.tryParse(_priceController.text.trim()) ?? 0.0;
      final double updatedSalePrice = _isOnSale ? _salePrice : 0.0;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .update({
            'title': _titleController.text.trim(),
            'price': parsedPrice,
            'salePrice': updatedSalePrice,
            'imageUrl': _pickedImage == null
                ? widget.imageUrl
                : imageUri.toString(),
            'productCategoryName': _catValue,
            'isOnSale': _isOnSale,
            'isPiece': _isPiece,
          });

      Fluttertoast.showToast(
        msg: "✅ Product has been updated successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    } catch (e) {
      GlobalMethods.errorDialog(subtitle: e.toString(), context: context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    GlobalMethods.warningDialog(
      title: 'Delete?',
      subtitle: 'Are you sure you want to delete this product?',
      fct: () async {
        Navigator.pop(context);
        try {
          setState(() => _isLoading = true);

          // Firestore’dan o‘chir
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.id)
              .delete();

          // Storage’dan rasmni o‘chir
          final ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('productsImages')
              .child('${widget.id}.jpg');
          await ref.delete();

          Fluttertoast.showToast(
            msg: "🗑️ Product deleted successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );

          Navigator.pop(context); // Edit sahifadan chiqish
        } catch (e) {
          GlobalMethods.errorDialog(subtitle: e.toString(), context: context);
        } finally {
          setState(() => _isLoading = false);
        }
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = theme ? Colors.white : Colors.black;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.0),
      ),
    );

    return Scaffold(
      key: context.read<MenuController>().getEditProductscaffoldKey,
      drawer: const SideMenu(),
      body: Row(
        children: [
          if (Responsive.isDesktop(context)) const Expanded(child: SideMenu()),
          Expanded(
            flex: 5,
            child: LoadingManager(
              isLoading: _isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Header(
                      showTexField: false,
                      fct: () => context
                          .read<MenuController>()
                          .controlEditProductsMenu(),
                      title: 'Edit this product',
                    ),
                    Container(
                      width: size.width > 650 ? 650 : size.width,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Product title*',
                              color: color,
                              isTitle: true,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _titleController,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter a Title'
                                  : null,
                              decoration: inputDecoration,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Price*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: _priceController,
                                            keyboardType: TextInputType.number,
                                            validator: (value) => value!.isEmpty
                                                ? 'Enter price'
                                                : null,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]'),
                                              ),
                                            ],
                                            decoration: inputDecoration,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Product category*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          color: scaffoldColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: catDropDownWidget(color),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Measure unit*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            TextWidget(
                                              text: 'Kg',
                                              color: color,
                                            ),
                                            Radio(
                                              value: 1,
                                              groupValue: val,
                                              onChanged: (value) {
                                                setState(() {
                                                  val = 1;
                                                  _isPiece = false;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                            TextWidget(
                                              text: 'Piece',
                                              color: color,
                                            ),
                                            Radio(
                                              value: 2,
                                              groupValue: val,
                                              onChanged: (value) {
                                                setState(() {
                                                  val = 2;
                                                  _isPiece = true;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _isOnSale,
                                              onChanged: (newValue) => setState(
                                                () => _isOnSale = newValue!,
                                              ),
                                            ),
                                            TextWidget(
                                              text: 'On Sale',
                                              color: color,
                                              isTitle: true,
                                            ),
                                          ],
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          child: !_isOnSale
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    TextWidget(
                                                      text:
                                                          "\$${_salePrice.toStringAsFixed(2)}",
                                                      color: color,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    salePourcentageDropDownWidget(
                                                      color,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      height: size.width > 650
                                          ? 350
                                          : size.width * 0.45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: scaffoldColor,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: _pickedImage == null
                                            ? Image.network(
                                                _imageUrl,
                                                fit: BoxFit.cover,
                                              )
                                            : (kIsWeb)
                                            ? Image.memory(
                                                webImage,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: _pickImage,
                                    child: TextWidget(
                                      text: 'Update image',
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ButtonsWidget(
                                  onPressed: _deleteProduct,
                                  text: 'Delete',
                                  icon: IconlyBold.danger,
                                  backgroundColor: Colors.red.shade700,
                                ),
                                ButtonsWidget(
                                  onPressed: _updateProduct,
                                  text: 'Update',
                                  icon: IconlyBold.setting,
                                  backgroundColor: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownButtonHideUnderline salePourcentageDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem(value: '10', child: Text('10%')),
          DropdownMenuItem(value: '15', child: Text('15%')),
          DropdownMenuItem(value: '25', child: Text('25%')),
          DropdownMenuItem(value: '50', child: Text('50%')),
          DropdownMenuItem(value: '75', child: Text('75%')),
        ],
        onChanged: (value) {
          setState(() {
            _salePercent = value;
            _salePrice =
                double.parse(widget.price) -
                (double.parse(value!) * double.parse(widget.price) / 100);
          });
        },
        hint: Text(_salePercent ?? percToShow),
        value: _salePercent,
      ),
    );
  }

  DropdownButtonHideUnderline catDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem(value: 'Vegetables', child: Text('Vegetables')),
          DropdownMenuItem(value: 'Fruits', child: Text('Fruits')),
          DropdownMenuItem(value: 'Grains', child: Text('Grains')),
          DropdownMenuItem(value: 'Nuts', child: Text('Nuts')),
          DropdownMenuItem(value: 'Fish', child: Text('Fish')),
          DropdownMenuItem(value: 'Savr', child: Text('Savr')),
        ],
        onChanged: (value) => setState(() => _catValue = value!),
        value: _catValue,
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _pickedImage = File(image.path));
    } else {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final f = await image.readAsBytes();
        setState(() {
          _pickedImage = File("web_image");
          webImage = f;
        });
      }
    }
  }
}
