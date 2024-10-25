import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jingdong/config/Config.dart';
import 'package:flutter_jingdong/pages/Address/AddressList.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/provider/CheckOut.dart';
import 'package:flutter_jingdong/services/AddressServices.dart';
import 'package:flutter_jingdong/services/CheckOutServices.dart';
import 'package:flutter_jingdong/services/EventBus.dart';
import 'package:flutter_jingdong/services/ScreenAdapter.dart';
import 'package:flutter_jingdong/services/SignServices.dart';
import 'package:flutter_jingdong/services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CheckOutPage extends StatefulWidget {
  final Map? arguments;
  const CheckOutPage({super.key, this.arguments});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  List _addressList = [];

  var cartProvider;
  var checkOutProvider;

  @override
  void initState() {
    super.initState();
    _getDefaultAddress();

    eventBus.on<AddressEvent>().listen((event) {
      _getDefaultAddress();
    });
    // eventBus.on<CheckOutEvent>().listen((event) {
    //   print(event.str);
    //   _getDefaultAddress();
    // });
  }

  // 获取默认收货地址
  _getDefaultAddress() async {
    List userInfo = await UserServices.getUserInfo();
    var tempJson = {"uid": userInfo[0]['_id'], "salt": userInfo[0]["salt"]};
    var sign = SignServices.getSign(tempJson);
    var api =
        '${Config.domain}api/oneAddressList?uid=${userInfo[0]["_id"]}&sign=$sign';
    var response = await Dio().get(api);
    for (var i = 0; i < response.data['result'].length; i++) {
      var id = response.data['result'][i]['_id'];
      var val = response.data['result'][i];
      var key = '${val['name']}-${val['phone']}-${val['address']}';
      var item = await AddressServices.getAddressItem(key, id);
      if (item['locationCode'] != '') {
        response.data['result'][i]['addressInfo'] =
            '${item['provinceName']} ${item['cityName']} ${item['areaName']} ${response.data['result'][i]['address']}';
      } else {
        response.data['result'][i]['addressInfo'] =
            '${response.data['result'][i]['address']}';
      }
      response.data['result'][i]['locationCode'] = item['locationCode'];
    }
    setState(() {
      print(response.data['result']);
      _addressList = response.data['result'];
    });
  }

  // 立即下单
  _doPay() async {
    if (_addressList.isEmpty) {
      return Fluttertoast.showToast(
        msg: '请填写收货地址',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    List userInfo = await UserServices.getUserInfo();
    var allPrice =
        CheckOutServices.getAllPrice(checkOutProvider.checkOutListData)
            .toStringAsFixed(1);

    //获取签名
    var sign = SignServices.getSign({
      "uid": userInfo[0]["_id"],
      "phone": _addressList[0]["phone"],
      "address": _addressList[0]["address"],
      "name": _addressList[0]["name"],
      "all_price": allPrice,
      "products": json.encode(checkOutProvider.checkOutListData),
      "salt": userInfo[0]["salt"] //私钥
    });
    //请求接口
    var api = '${Config.domain}api/doOrder';
    var response = await Dio().post(api, data: {
      "uid": userInfo[0]["_id"],
      "phone": _addressList[0]["phone"],
      "address": _addressList[0]["address"],
      "name": _addressList[0]["name"],
      "all_price": allPrice,
      "products": json.encode(checkOutProvider.checkOutListData),
      "sign": sign
    });
    print(response);
    if (response.data["success"]) {
      //删除购物车选中的商品数据
      await CheckOutServices.removeUnSelectedCartItem();
      //调用CartProvider更新购物车数据
      cartProvider.updateCartList();
      //跳转到支付页面
      Navigator.pushNamed(context, '/pay');
    }
  }

  void _navigateToNextPage() async {
    var uid = _addressList[0]["_id"];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AddressListPage(arguments: {"uid": _addressList[0]["_id"]})),
    );
    // 处理返回的数据
    if (result != null) {
      // _handleReturnedData(result);
      List userInfo = await UserServices.getUserInfo();
      var tempJson = {"uid": userInfo[0]['_id'], "salt": userInfo[0]["salt"]};
      var sign = SignServices.getSign(tempJson);
      var api =
          '${Config.domain}api/addressList?uid=${userInfo[0]['_id']}&sign=${sign}';
      var response = await Dio().get(api);
      var tempList = [];
      for (var i = 0; i < response.data['result'].length; i++) {
        var id = response.data['result'][i]['_id'];
        if (id == result) {
          var val = response.data['result'][i];
          var key = '${val['name']}-${val['phone']}-${val['address']}';
          var item = await AddressServices.getAddressItem(key, id);
          if (item['locationCode'] != '') {
            response.data['result'][i]['addressInfo'] =
                '${item['provinceName']} ${item['cityName']} ${item['areaName']} ${response.data['result'][i]['address']}';
          } else {
            response.data['result'][i]['addressInfo'] =
                '${response.data['result'][i]['address']}';
          }
          response.data['result'][i]['locationCode'] = item['locationCode'];
          tempList.add(response.data['result'][i]);
        }
      }
      setState(() {
        _addressList = tempList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    cartProvider = Provider.of<Cart>(context);
    checkOutProvider = Provider.of<CheckOut>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("结算"),
        ),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            ListView(children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(height: ScreenAdapter.height(10)),
                    _addressList.isNotEmpty
                        ? ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    '${_addressList[0]['name']}  ${_addressList[0]['phone']}'),
                                SizedBox(height: ScreenAdapter.height(10)),
                                Text('${_addressList[0]['addressInfo']}')
                              ],
                            ),
                            trailing: const Icon(Icons.navigate_next),
                            onTap: _navigateToNextPage)
                        : ListTile(
                            leading: const Icon(Icons.add_location),
                            title: const Center(
                              child: Text("请添加收货地址"),
                            ),
                            trailing: const Icon(Icons.navigate_next),
                            onTap: () {
                              Navigator.pushNamed(context, '/addressAdd');
                            },
                          ),
                    SizedBox(height: ScreenAdapter.height(10)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(ScreenAdapter.width(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("商品总金额:￥${cartProvider.allPrice}"),
                    const Divider(),
                    const Text("立减:￥5"),
                    const Divider(),
                    const Text("运费:￥0"),
                  ],
                ),
              )
            ]),
            Positioned(
                bottom: 0,
                width: ScreenAdapter.width(750),
                height: ScreenAdapter.height(100),
                child: Container(
                  width: ScreenAdapter.width(750),
                  height: ScreenAdapter.height(100),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(width: 1, color: Colors.black26))),
                  child: Stack(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("总价:￥140",
                            style: TextStyle(color: Colors.red)),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.red)),
                              onPressed: _doPay,
                              child: const Text(
                                '立即下单',
                                style: TextStyle(color: Colors.white),
                              ))),
                    ],
                  ),
                ))
          ],
        )));
  }
}
