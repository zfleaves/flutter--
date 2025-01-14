import 'dart:convert';

import 'package:flutter_jingdong/services/Storage.dart';


class CartServices {
  static addCart(item) async {
    //把对象转换成Map类型的数据
    item = CartServices.formatCartData(item);
    try {
      List cartListData = json.decode(await Storage.getString('cartList') as String);
      bool hasData = cartListData.any((value) {
        return value['id'] == item['id'] && value['selectedAttr'] == item['selectedAttr'];
      });

      // 有数据
      if (hasData) {
        for (var i = 0; i < cartListData.length; i++) {
          if (cartListData[i]['id'] == item['id'] &&
              cartListData[i]['selectedAttr'] == item['selectedAttr']) {
            cartListData[i]['count'] = cartListData[i]['count'] + 1;
          }
        }
      } else {
        cartListData.add(item);
      }
      await Storage.setString('cartList', json.encode(cartListData));
    } catch (e) {
      // 临时变量
      List tempList = [];
      tempList.add(item);
      await Storage.setString('cartList', json.encode(tempList));
    }
  }

  //过滤数据
  static formatCartData(item) {
    // 处理图片
    final Map data = <String, dynamic>{};
    data['id'] = item.id;
    data['title'] = item.title;
    if (item.price is int || item.price is double) {
      data['price'] = item.price;
    } else {
      data['price'] = double.parse(item.price);
    }
    data['selectedAttr'] = item.selectedAttr;
    data['count'] = item.count;
    data['pic'] = item.pic;
    //是否选中
    data['checked'] = true;
    return data;
  }

  //获取购物车选中的数据
  static getCheckOutData<list>() async {
    List cartListData = [];
    List tempCheckOutData = [];
    try {
      cartListData = json.decode(await Storage.getString('cartList') as String);
    } catch (e) {
      cartListData = [];
    }
    for (var i = 0; i < cartListData.length; i++) {
      if (cartListData[i]["checked"] == true) {
        tempCheckOutData.add(cartListData[i]);
      }
    }
    return tempCheckOutData;
  }
}