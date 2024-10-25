import 'package:flutter/material.dart';
import 'package:flutter_jingdong/model/Product.dart';
import 'package:flutter_jingdong/model/ProductContentModel.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';

class CartNum extends StatefulWidget {
  final ProductItemModel _productContent;

  const CartNum(this._productContent, {super.key});

  @override
  State<CartNum> createState() => _CartNumState();
}

class _CartNumState extends State<CartNum> {
  late ProductItemModel _productContent;

  @override
  void initState() {
    super.initState();
    _productContent = widget._productContent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenAdapter.width(164),
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.black12)),
      child: Row(
        children: [_leftBtn(), _centerArea(), _rightBtn()],
      ),
    );
  }

  //左侧按钮
  Widget _leftBtn() {
    return InkWell(
      onTap: () {
        if (_productContent.count > 1) {
          setState(() {
            _productContent.count = _productContent.count - 1;
          });
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

  //左侧按钮
  Widget _rightBtn() {
    return InkWell(
      onTap: () {
        setState(() {
          _productContent.count = _productContent.count + 1;
        });
      },
      child: Container(
        alignment: Alignment.center,
        width: ScreenAdapter.width(45),
        height: ScreenAdapter.height(45),
        child: const Text("+"),
      ),
    );
  }

  // 中间输入
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
      child: Text('${_productContent.count}'),
    );
  }
}
