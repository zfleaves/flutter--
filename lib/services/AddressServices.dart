import 'dart:convert';

import 'package:flutter_jingdong/services/Storage.dart';

class AddressServices {
  static addItem(item) async {
    //把对象转换成Map类型的数据
    item = AddressServices.formatCartData(item);
    try {
      List addressListData =
          json.decode(await Storage.getString('addressList') as String);
      int index = addressListData.indexWhere((value) {
        return value['id'] == item['id'] || value['key'] == item['key'];
      });
      if (index >= 0) {
        addressListData[index] = item;
      } else {
        addressListData.add(item);
      }
      // print(addressListData);
      await Storage.setString('addressList', json.encode(addressListData));
    } catch (e) {
      // 临时变量
      List tempList = [];
      tempList.add(item);
      await Storage.setString('addressList', json.encode(tempList));
    }
  }

  static formatCartData(item) {
    final Map data = <String, dynamic>{};
    data['provinceName'] = item['provinceName'];
    data['cityName'] = item['cityName'];
    data['areaName'] = item['areaName'];
    data['locationCode'] = item['locationCode'];
    data['key'] = item['key'];
    data['id'] = item['id'];
    return data;
  }

  // 获取某个地址
  static getAddressItem(String key, String id) async {
    try {
      List addressListData =
          json.decode(await Storage.getString('addressList') as String);
      var item = addressListData.firstWhere(
          (val) => val['id'] == id || val['key'] == key,
          orElse: () => {
                'provinceName': '',
                'cityName': '',
                'areaName': '',
                'locationCode': ''
              });
      return item;
    } catch (e) {
      return {
        'provinceName': '',
        'cityName': '',
        'areaName': '',
        'locationCode': ''
      };
    }
  }
}
