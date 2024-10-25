import 'package:flutter/material.dart';
import 'package:flutter_jingdong/pages/Cart/CartItem.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/provider/CheckOut.dart';
import 'package:flutter_jingdong/services/CartServices.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // 是否编辑
  bool _isEdit = true;

  var checkOutProvider;

  //去结算
  doCheckOut() async {
    //1、获取购物车选中的数据
    List checkoutData = await CartServices.getCheckOutData();
    //2、保存购物车选中的数据
    checkOutProvider.changeCheckOutListData(checkoutData);
    //3、购物车有没有选中的数据
    if (checkoutData.isNotEmpty) {
      //4、判断用户有没有登录
      var loginState = await UserServices.getUserLoginState();
      if (loginState) {
        Navigator.pushNamed(context, '/checkOut');
      } else {
        Fluttertoast.showToast(
          msg: '您还没有登录，请登录以后再去结算',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pushNamed(context, '/login');
      }
      return;
    }
    Fluttertoast.showToast(
      msg: '购物车没有选中的数据',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    // 获取购物车数据
    var cartProvider = Provider.of<Cart>(context);
    // 结算数据
    checkOutProvider = Provider.of<CheckOut>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('购物车'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  _isEdit = !_isEdit;
                });
              },
              child: const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.launch,
                    color: Colors.black54,
                  )),
            )
          ],
        ),
        body: cartProvider.cartList.isNotEmpty
            ? SafeArea(
                child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ListView(
                      children: cartProvider.cartList.map((value) {
                        return CartItem(value);
                      }).toList(),
                    ),
                  ),
                  Positioned(
                      width: ScreenAdapter.width(750),
                      height: ScreenAdapter.height(100),
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(width: 1, color: Colors.black12)),
                          color: Colors.white,
                        ),
                        width: ScreenAdapter.width(750),
                        height: ScreenAdapter.height(100),
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: ScreenAdapter.width(60),
                                    child: Checkbox(
                                        value: cartProvider.isCheckedAll,
                                        activeColor: Colors.pink,
                                        onChanged: (val) {
                                          cartProvider.changeCheckAll(val!);
                                        }),
                                  ),
                                  const Text('全选'),
                                  SizedBox(
                                    width: ScreenAdapter.width(20),
                                  ),
                                  const Text('合计'),
                                  Text('${cartProvider.allPrice}',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.size(20),
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _isEdit
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        fixedSize: const Size(100, 40)),
                                      onPressed: doCheckOut,
                                      child: Text(
                                        '去结算',
                                        style: TextStyle(color: Colors.white, fontSize: ScreenAdapter.size(20)),
                                      ))
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        fixedSize: const Size(100, 40),
                                      ),
                                      child: const Text(
                                        '删除',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        cartProvider.removeItem();
                                      }),
                            )
                          ],
                        ),
                      ))
                ],
              ))
            : const Center(
                child: Text('购物车为空'),
              ));
  }
}
