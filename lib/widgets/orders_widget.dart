import 'package:flutter/material.dart';
import 'package:hgocery_web/services/utils.dart';

import 'text_widget.dart';

class OrdersWidget extends StatefulWidget {
  const OrdersWidget({Key? key}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    Color color = theme == true ? Colors.white : Colors.black;
    Size size = Utils(context).getScreenSize;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: size.width < 650 ? 3 : 1,
                child: Image.network(
                  'data:image/jpeg;base64,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',

                  fit: BoxFit.fill,
                  // height: screenWidth * 0.15,
                  // width: screenWidth * 0.15,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: '12x For \$19.9',
                      color: color,
                      textSize: 16,
                      isTitle: true,
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          TextWidget(
                            text: 'By',
                            color: Colors.blue,
                            textSize: 16,
                            isTitle: true,
                          ),
                          TextWidget(
                            text: '  Hadi K.',
                            color: color,
                            textSize: 14,
                            isTitle: true,
                          ),
                        ],
                      ),
                    ),
                    const Text('20/03/2022'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
