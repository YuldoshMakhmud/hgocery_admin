import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../inner_screens/edit_prod.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import 'text_widget.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  String title = '';
  String productCat = '';
  String? imageUrl;
  double price = 0.0;
  double salePrice = 0.0;
  bool isOnSale = false;
  bool isPiece = false;

  @override
  void initState() {
    getProductsData();
    super.initState();
  }

  Future<void> getProductsData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .get();

      if (!doc.exists) return;

      setState(() {
        title = doc.get('title') ?? '';
        productCat = doc.get('productCategoryName') ?? '';
        imageUrl = doc.get('imageUrl');
        price = double.tryParse(doc.get('price')?.toString() ?? '0') ?? 0.0;
        salePrice = (doc.get('salePrice') ?? 0.0).toDouble();
        isOnSale = doc.get('isOnSale') ?? false;
        isPiece = doc.get('isPiece') ?? false;
      });
    } catch (e) {
      GlobalMethods.errorDialog(subtitle: '$e', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    final color = Utils(context).color;

    final formatCurrency = NumberFormat('#,##0', 'en_US');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditProductScreen(
                  id: widget.id,
                  title: title,
                  price: price.toString(),
                  salePrice: salePrice,
                  productCat: productCat,
                  imageUrl:
                      imageUrl ??
                      'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png',
                  isOnSale: isOnSale,
                  isPiece: isPiece,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl ??
                              'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png',
                          fit: BoxFit.cover,
                          height: size.width * 0.12,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              height: size.width * 0.12,
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 1, child: Text('Edit')),
                        const PopupMenuItem(
                          value: 2,
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 1) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(
                                id: widget.id,
                                title: title,
                                price: price.toString(),
                                salePrice: salePrice,
                                productCat: productCat,
                                imageUrl:
                                    imageUrl ??
                                    'https://www.lifepng.com/wp-content/uploads/2020/11/Apricot-Large-Single-png-hd.png',
                                isOnSale: isOnSale,
                                isPiece: isPiece,
                              ),
                            ),
                          );
                        } else if (value == 2) {
                          GlobalMethods.warningDialog(
                            title: 'Delete?',
                            subtitle:
                                'Are you sure you want to delete this product?',
                            context: context,
                            fct: () async {
                              Navigator.pop(context);
                              try {
                                await FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(widget.id)
                                    .delete();
                              } catch (e) {
                                GlobalMethods.errorDialog(
                                  subtitle: '$e',
                                  context: context,
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    TextWidget(
                      text: isOnSale
                          ? '₩${formatCurrency.format(salePrice)}'
                          : '₩${formatCurrency.format(price)}',
                      color: color,
                      textSize: 18,
                    ),
                    const SizedBox(width: 7),
                    Visibility(
                      visible: isOnSale,
                      child: Text(
                        '₩${formatCurrency.format(price)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextWidget(
                      text: isPiece ? 'Piece' : '1Kg',
                      color: color,
                      textSize: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                TextWidget(
                  text: title,
                  color: color,
                  textSize: 20,
                  isTitle: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
