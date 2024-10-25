import 'package:flutter/material.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:provider/provider.dart';

class CartNum extends StatefulWidget {
  final Map _itemData;
  const CartNum(this._itemData, {super.key});

  @override
  State<CartNum> createState() => _CartNumState();
}

class _CartNumState extends State<CartNum> {
  Map _itemData = {};

  var cartProvider;

  @override
  void initState() {
    super.initState();
    _itemData = widget._itemData;
  }

  Widget _leftBtn() {
    return InkWell(
      onTap: () {
        if (_itemData['count'] > 1) {
          setState(() {
            _itemData["count"]--;
          });
          cartProvider.changeItemCount();
        } else {
          setState(() {
            _itemData["count"]++;
          });
          cartProvider.changeItemCount();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: ScreenAdapter.width(45),
        height: ScreenAdapter.height(45),
        child: const Text("-"),
      ),
    );
  }

  Widget _centerArea() {
    return Container(
      alignment: Alignment.center,
      width: ScreenAdapter.width(70),
      decoration: const BoxDecoration(
          border: Border(
        left: BorderSide(width: 1, color: Colors.black12),
        right: BorderSide(width: 1, color: Colors.black12),
      )),
      height: ScreenAdapter.height(45),
      child: Text("${_itemData["count"]}"),
    );
  }

  Widget _rightBtn() {
    return InkWell(
      onTap: () {
        setState(() {
          _itemData["count"]++;
        });
        cartProvider.changeItemCount();
      },
      child: Container(
        alignment: Alignment.center,
        width: ScreenAdapter.width(45),
        height: ScreenAdapter.height(45),
        child: const Text("+"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    cartProvider = Provider.of<Cart>(context);
    return Container(
      width: ScreenAdapter.width(164),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black12)
      ),
      child: Row(
        children: <Widget>[
          _leftBtn(), _centerArea(), _rightBtn()
        ],
      ),
    );
  }
}