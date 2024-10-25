import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/pages/Cart/CartNum.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  final Map _itemData;
  const CartItem(this._itemData, {super.key});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  // 购物车数据
  late Map _itemData = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<Cart>(context);

    _itemData = widget._itemData;
    //处理图片
    String pic = _itemData["pic"];
    pic = Config.domain  + pic.replaceAll('\\', '/');
    return Container(
      height: ScreenAdapter.height(200),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.black12),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: ScreenAdapter.width(60),
            child: Checkbox(
              value: _itemData['checked'], 
              onChanged: (val) {
                cartProvider.itemChangeCheck(_itemData['id'], val);
              },
              activeColor: Colors.red,
            ),
          ),
          SizedBox(
            width: ScreenAdapter.width(160),
            child: Image.network(pic, fit: BoxFit.cover,),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${_itemData['title']}', maxLines: 2,),
                  Text('${_itemData['selectedAttr']}', maxLines: 1,),
                  Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("￥${_itemData["price"]}",
                            style: const TextStyle(color: Colors.red)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CartNum(_itemData),
                      )
                    ],
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}