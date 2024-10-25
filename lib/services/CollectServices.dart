import 'dart:convert';

import 'package:flutter_jingdong/model/ProductContentModel.dart';
import 'package:flutter_jingdong/services/Storage.dart';

class CollectServices {
  static toggleCollect(item) async {
    //把对象转换成Map类型的数据
    item = CollectServices.formatCartData(item);
    try {
      List collectListData = json.decode(await Storage.getString('collectList') as String);
      var index = collectListData.indexWhere((val) {
        return val['id'] == item['id'];
      });
      if (index >= 0) {
        collectListData.removeAt(index);
      } else {
        collectListData.add(item);
      }
      Storage.setString('collectList', json.encode(collectListData));
    } catch (e) {
      List tempList = [];
      tempList.add(item);
      Storage.setString('collectList', json.encode(tempList));
    }
  }

  //过滤数据
  static formatCartData(item) {
    final Map data = <String, dynamic>{};
    data['id'] = item.id;
    data['title'] = item.title;
    data['cid'] = item.cid;
    data['price'] = item.price;
    data['oldPrice'] = item.oldPrice;
    data['isBest'] = item.isBest;
    data['isHot'] = item.isHot;
    data['isNew'] = item.isNew;
    data['status'] = item.status;
    data['pic'] = item.pic;
    // data['content'] = item.content;
    data['cname'] = item.cname;
    data['attr'] = item.attr;
    data['subTitle'] = item.subTitle;
    data['salecount'] = item.salecount;
    data['count'] = 1;
    data['checked'] = false;
    var list = item.attr;
    List tempArr = [];
    for (var i = 0; i < list.length; i++) {
      if (list[i].attrList.length > 0) {
        tempArr.add(list[i].attrList[0]["title"]);
      }
    }
    data['selectedAttr'] = tempArr.join('，');
    return data;
  }

  // 删除所选商品
  static deleteCollect(List ids) async {
    try {
      if (ids.isEmpty) return;
      List collectListData = json.decode(await Storage.getString('collectList') as String);
      for (var i = 0; i < ids.length; i++) {
        int index = collectListData.indexWhere((val) => val['id'] == ids[i]);
        if (index >= 0) {
          collectListData.removeAt(index);
        }
      }
      Storage.setString('collectList', json.encode(collectListData));
    } catch (e) {
      print(e);
    }
  }

  // 删除所以
  static removeCollect() async {
    Storage.remove('collectList');
  }
}